/**
 * 代表 “我的书包” 上，单个书籍
 * Created by jess on 15/1/16.
 */


! function( window ){

    var $ = window.Zepto;

    var EventEmitter = window.EventEmitter;

    var Dialog = window.Dialog;

    //var artTemplate = window.template;

    //书籍未下载
    var notOfflineClass = 'book-not-offline';
    //书籍正在下载中的样式
    var downloadingClass = 'book-downloading';
    //书籍有更新
    var bookCanUpdateClass = 'book-can-update';
    //书籍正在更新中的样式
    var updatingClass = 'book-updating';

    //一本书可以处于的不同状态
    var BOOK_STATUS = samaConfig.BOOK_STATUS;

    function BookItem( args ){
        var $el = $( document.querySelector('#book-item-tpl').innerHTML );
        this.$coverImage = $el.find('.cover-img');
        this.$downloadProgress = $el.find('.progress');
        this.$downloadProgressBg = $el.find('.progress-bg');
        this.$downloadStep = $el.find('.downloading-step');
        this.$bookName = $el.find('.book-name');
        this.$bookEditor = $el.find('.book-editor');

        this.$el = $el;

        this._data = null;
        this._metaJSON = null;

        this._setupEvent();
    }

    $.extend( BookItem.prototype, EventEmitter.prototype );

    $.extend( BookItem.prototype, {

        _setupEvent : function(){
            this.$el.on( 'tap', '.download-btn', this.beginDownload.bind(this) );
            this.$el.on( 'tap', '.cover-img', this._bookClick.bind( this ) );
        },

        render : function( data ){
            if( ! data || ! data.book_meta_json ){
                return;
            }


            this.$el.attr( 'data-book-id', data.book_id );

            var metaJSON = data.book_meta_json;

            this._data = data;
            this._metaJSON = metaJSON;

            var conWidth = data.width;
            var conHeight = data.height;

            //封面区域的高度
            var imgViewHeight = 129;
            var imgViewWidth = conWidth ;

            var imgWidth = metaJSON.cover_img_width;
            var imgHeight = metaJSON.cover_img_height;

            var offset = utils.zoomLimitMax( imgViewWidth, imgViewHeight, imgWidth, imgHeight );
            offset.height = 116;
            this.$coverImage.parent().css({
                left : offset.left + 'px',
                top : '0',
                width : offset.width + 'px',
                height : offset.height + 'px'
            });
            this.$coverImage.css({
                width : '100%',
                height : '100%'
            });

            this.$bookName.text( metaJSON.book_name );
            this.$bookEditor.text( metaJSON.book_editor );

            this.$el.css({
                width : conWidth + 'px',
                height : conHeight + 'px',
                left : data.left + 'px',
                top : data.top + 'px'
            });

            var bookStatus = data.book_status;

            var className = '';

            if( bookStatus === BOOK_STATUS.BOOK_NOT_DOWNLOAD || bookStatus === BOOK_STATUS.DOWNLOAD_FAIL ){
                //书籍未下载
                className = notOfflineClass;
            }else if( this.isBookDownloading() ){
                //下载中
                className = downloadingClass;
            }else if( bookStatus === BOOK_STATUS.BOOK_NEED_UPDATE ){
                //有更新
                className = bookCanUpdateClass;
            }

            this.$el.addClass( className );

            return true;
        },

        resize : function( args ){
            var width = args.width;
            this.$el.css( args );
        },

        getBookID : function(){
            if( this._data ){
                return this._data.book_id;
            }
            return null;
        },

        getElement : function(){
            return this.$el[0];
        },

        //设置封面图片的 src
        setCoverImageSrc : function(coverSrc){
            this.$coverImage.attr( 'src', coverSrc );
        },

        beginDownload : function(){
            if( ! this._data ){
                return;
            }
            this.trigger('beginDownload', [ this ]);
            this._data.book_status = BOOK_STATUS.BOOK_IS_DOWNLOADING;
            this.$el.addClass( downloadingClass );
        },
        //设置书籍下载中的进度
        setDownloadProgress : function( state ){
            if( ! this._data || ! state || this._data.book_id !== state.book_id ){
                return;
            }
            var progress = parseInt( state.book_status_detail, 10 );
            progress = Math.min( 100, progress );
            //TODO 添加下载错误的处理
            this.$downloadProgress.text( progress + '%');
            this.$downloadProgressBg.css({
                height : progress + '%'
            });
            this.$downloadStep.text( state.book_status );

            if( state.book_status === BOOK_STATUS.BOOK_READY && progress >= 100 ){
                //书籍已经下载、解压、更新数据库索引完成，可以访问了
                this._data.book_status = BOOK_STATUS.BOOK_READY;
                this.$el.removeClass( downloadingClass + ' ' + notOfflineClass + ' ' + bookCanUpdateClass );
            }

            this._data.download_progress = progress;
        },

        //书籍是否已经成功下载
        isBookReady : function(){
            return this._data.book_status === BOOK_STATUS.BOOK_READY ;
        },

        //正在下载中、正在更新中，都属于书籍处于 “下载进程”，需要轮训新的进度
        isBookDownloading : function(){
            return this._data.book_status === BOOK_STATUS.BOOK_IS_DOWNLOADING || this._data.book_status === BOOK_STATUS.BOOK_IS_UPDATING;
        },

        //是否上一次下载进程，被异常中断，如果异常中断，需要在进入“我的书包”页时，自动重启下载进程
        isLastDownloadInterrupted : function(){
            return this._data.book_status === BOOK_STATUS.LAST_DOWNLOAD_INTERRUPTED;
        },

        _bookClick : function(){
            var status = this._data.book_status;
            if( this.isBookReady() ){
                //书籍已经离线到本地，可以正常进入学习
                this.trigger( 'enterBook', [this]);
                return;
            }
            var that = this;
            if( status === BOOK_STATUS.BOOK_NOT_DOWNLOAD ){
                //var out = window.confirm('书籍尚未下载到本地，是否立即下载？');
                //if( out ){
                //    this.beginDownload();
                //    return;
                //}
                Dialog.confirm({
                    content : '书籍尚未下载到本地，是否立即下载？',
                    onOK : function(){
                        that.beginDownload();
                    }
                });
                return;
            }else if( status === BOOK_STATUS.BOOK_NEED_UPDATE ){
                //var out = window.confirm('书籍有更新，是否立即更新？');
                //if( out ){
                //    this.beginDownload();
                //}else{
                //    this.trigger( 'enterBook', [this]);
                //}
                Dialog.confirm({
                    content : '书籍有更新，是否立即更新？',
                    onOK : function(){
                        that.beginDownload();
                    },
                    onCancel : function(){
                        that.trigger( 'enterBook', [that]);
                    }
                });
                return;
            }
            //TODO 针对APP版本和书籍版本不对应，提示
        }

    } );

    window.BookItem = BookItem;

}( window );
