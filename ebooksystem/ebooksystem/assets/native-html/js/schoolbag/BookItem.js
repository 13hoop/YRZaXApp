/**
 * 代表 “我的书包” 上，单个书籍
 * Created by jess on 15/1/16.
 */


! function( window ){

    var $ = window.Zepto;

    var samaConfig = window.samaConfig;

    var EventEmitter = window.EventEmitter;

    var samaLog = window.samaLog;

    var Dialog = window.Dialog;

    //书籍未下载
    var notOfflineClass = 'book-not-offline';
    //书籍正在下载中的样式
    var downloadingClass = 'book-downloading';
    //书籍有更新
    var bookCanUpdateClass = 'book-can-update';
    //书籍正在更新中的样式
    var updatingClass = 'book-updating';
    //书籍处于选中模式的class，但是否选中，未知
    var selectModeClass = 'book-in-select-mode';
    //书籍选中的class
    var selectedClass = 'book-selected';

    //一本书可以处于的不同状态
    var BOOK_STATUS = samaConfig.BOOK_STATUS;
    var BOOK_UPDATE_STATUS = samaConfig.BOOK_UPDATE_STATUS;

    var NETWORK_TYPE = samaConfig.NETWORK_TYPE;
    //解压开始时，对应的总进度的百分比
    var EXTRACT_START = 85;
    //解压结束时，对应总进度的百分比
    var EXTRACT_END = 90;

    function BookItem( args ){
        var $el = $( document.querySelector('#book-item-tpl').innerHTML );
        this.$coverImage = $el.find('.cover-img');
        this.$downloadProgress = $el.find('.progress');
        this.$downloadProgressBg = $el.find('.progress-bg');
        this.$downloadStep = $el.find('.downloading-step');
        this.$bookName = $el.find('.book-name');
        this.$bookEditor = $el.find('.book-editor');

        this.$el = $el;

        //当前是否是 选中 模式
        this.selectMode = false;
        this._data = null;
        this._metaJSON = null;
        //上一次获取到解压进度的时间戳，单位 ms
        this.lastExtractTimestamp = null;

        this._setupEvent();
    }

    $.extend( BookItem.prototype, EventEmitter.prototype );

    $.extend( BookItem.prototype, {

        _setupEvent : function(){
            //this.$el.on( 'click', '.download-btn', this._bookClick.bind(this) );
            this.$el.on( 'click', '.cover-wrap', this._bookClick.bind( this ) );
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

            if( metaJSON.is_weike === '1' ){
                //书籍有微课
                this.$coverImage.before('<span class="has-weike-icon"></span>');
            }

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

            if( bookStatus === BOOK_STATUS.BOOK_NOT_DOWNLOAD || this.isBookFail( bookStatus) ){
                //书籍未下载
                className = notOfflineClass;
            }else if( this.isBookDownloading() ){
                //下载中
                className = downloadingClass;
            }else if( this.canUpdate( data.update_status ) ){
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
            var bookStatus = state.book_status;
            var progress = parseInt( state.book_status_detail, 10 );
            progress = Math.min( 100, progress );

            if( progress === EXTRACT_START  ){
                //针对解压过程时间过长，前端将进度自动+1
                var now = ( new Date() ).getTime();
                if( this.lastExtractTimestamp === null ){
                    this.lastExtractTimestamp = now;
                }else{
                    var timestamp = now - this.lastExtractTimestamp;
                    var seconds = Math.round( timestamp / 1000 );
                    var step = Math.round( seconds / 2);
                    progress  = Math.min( EXTRACT_END, EXTRACT_START + step );
                }
            }else{
                this.lastExtractTimestamp = null;
            }

            //下载错误的处理
            if( this.isBookFail( bookStatus ) ){
                this.lastExtractTimestamp = null;
                this.$el.removeClass( downloadingClass );
                Dialog.alert({
                    content : '书籍' + bookStatus
                });
            }

            if( state.book_cover ){
                this.setCoverImageSrc( state.book_cover );
            }


            this.$downloadProgress.text( progress + '%');
            this.$downloadProgressBg.css({
                width : progress + '%'
            });
            this.$downloadStep.text( bookStatus );

            this._data.book_status = bookStatus;
            this._data.update_status = state.update_status;
            var bookAvailable = this._data.book_avail = state.book_avail;

            if( bookStatus === BOOK_STATUS.BOOK_READY && progress >= 100 ){
                //书籍已经下载、解压、更新数据库索引完成，可以访问了
                this._data.book_status = BOOK_STATUS.BOOK_READY;
                this.$el.removeClass( downloadingClass + ' ' + notOfflineClass + ' ' + bookCanUpdateClass );
            }else if( ! this.isBookDownloading() && this.canUpdate( state.update_status) ){
                this.$el.removeClass( downloadingClass + ' ' + notOfflineClass).addClass( bookCanUpdateClass );
            }

            this._data.download_progress = progress;
        },

        //书籍是否已经成功下载
        isBookReady : function(){
            return this._data.book_status === BOOK_STATUS.BOOK_READY
            || this._data.book_avail === BOOK_STATUS.BOOK_AVAILABLE ;
        },
        isBookStatusReady : function(){
            return this._data.book_status === BOOK_STATUS.BOOK_READY;
        },
        //书籍是否下载失败
        isBookFail : function( status ){
            status = status || this._data.book_status;
            return status === BOOK_STATUS.DOWNLOAD_FAIL
                || status === BOOK_STATUS.EXTRACT_FAIL
                || status === BOOK_STATUS.INVALIDATE_FAIL
                || status === BOOK_STATUS.APPLY_FAIL;
        },

        //正在下载中、正在更新中，都属于书籍处于 “下载进程”，需要轮训新的进度
        isBookDownloading : function(){
            var status = this._data.book_status;
            return status === BOOK_STATUS.BOOK_IS_DOWNLOADING
            || status === BOOK_STATUS.EXTRACTING
                || status === BOOK_STATUS.INVALIDATING
                || status === BOOK_STATUS.APPLYING;
        },

        //是否上一次下载进程，被异常中断，如果异常中断，需要在进入“我的书包”页时，自动重启下载进程
        isLastDownloadInterrupted : function(){
            return this._data.book_status === BOOK_STATUS.LAST_DOWNLOAD_INTERRUPTED;
        },
        //书籍是否有更新
        canUpdate : function( status ){
            return status === BOOK_UPDATE_STATUS.BOOK_NEED_UPDATE;
        },

        _bookClick : function(){

            //下载中的书籍，不能做任何操作
            if( this.isBookDownloading() ){
                return;
            }

            if( this.selectMode ){

                //处于编辑模式下，禁用打开书籍功能
                this.toggleSelect( true );
                return;
            }

            var that = this;

            var status = this._data.book_status;
            var bookID = this.getBookID();

            if( this.canUpdate( this._data.update_status ) ){

                Dialog.confirm({
                    content : '书籍有更新，是否立即更新？',
                    okText : '立即更新',
                    cancelText : '暂时不更新',
                    onOK : function(){
                        //统计更新次数
                        samaLog.send({
                            t : 'update',
                            k : 'start',
                            v : '1',
                            book_id : bookID,
                            fr : 'schoolbag'
                        });

                        that.beginDownload();
                    },
                    onCancel : function(){

                        that.trigger( 'enterBook', [that]);
                    }
                });
                return;
            }

            if( status === BOOK_STATUS.BOOK_READY || this._data.book_avail === BOOK_STATUS.BOOK_AVAILABLE ){
                //书籍已经离线到本地，可以正常进入学习
                this.trigger( 'enterBook', [this]);
                return;
            }

            if( status === BOOK_STATUS.BOOK_NOT_DOWNLOAD || this.isBookFail() ){
                //var out = window.confirm('书籍尚未下载到本地，是否立即下载？');
                //if( out ){
                //    this.beginDownload();
                //    return;
                //}
                bridgeXXX.getNetworkType( function(data){
                    try{
                        data = JSON.parse( data );
                    }catch(e){
                        that.beginDownload();
                        return;
                    }
                    if( data.network_status === NETWORK_TYPE.OFFLINE ){
                        //没有网络
                        Dialog.alert({
                            content : '当前没有网络连接，请打开网络连接'
                        });

                    }else if( data.network_status === NETWORK_TYPE.WIFI ){
                        //统计下载次数
                        samaLog.send({
                            t : 'download',
                            k : 'start',
                            v : '1',
                            book_id : bookID,
                            net : 'wifi',
                            fr : 'schoolbag'
                        });
                        that.beginDownload();
                    }else{
                        //处于移动网络，提示用户是否确认下载
                        Dialog.confirm({
                            content : '您正在使用 3G 网络，开始下载将耗费您的流量，是否继续？',
                            onOK : function(){
                                //统计下载次数
                                samaLog.send({
                                    t : 'download',
                                    k : 'start',
                                    v : '1',
                                    book_id : bookID,
                                    net : '3g',
                                    fr : 'schoolbag'
                                });

                                that.beginDownload();
                            }
                        });
                    }
                } );

                return;
            }
            //TODO 针对APP版本和书籍版本不对应，提示
        },
        //切换到  选中书籍 模式，在选中模式下，禁用看书功能
        enterEditMode : function(){
            this.selectMode = true;
            this.$el.addClass( selectModeClass );
        },
        exitEditMode : function(){
            this.selectMode = false;
            this.$el.removeClass( selectModeClass + ' ' + selectedClass );
        },
        selectBook : function(isTriggerEvent){
            //下载中的书籍，不能删除
            if( this.isBookDownloading() ){
                return;
            }
            this.$el.addClass( selectedClass );
            if( isTriggerEvent ){
                EventEmitter.eventCenter.trigger('book-select-toggle');
            }
        },
        unselectBook : function(isTriggerEvent){
            //下载中的书籍，不能删除
            if( this.isBookDownloading() ){
                return;
            }
            this.$el.removeClass( selectedClass );
            if( isTriggerEvent ){
                EventEmitter.eventCenter.trigger('book-select-toggle');
            }
        },
        toggleSelect : function(isTriggerEvent){
            this.$el.toggleClass( selectedClass );
            if( isTriggerEvent ){
                EventEmitter.eventCenter.trigger('book-select-toggle');
            }
        },
        isSelected : function(){
            return this.$el.hasClass( selectedClass );
        }

    } );

    window.BookItem = BookItem;

}( window );
