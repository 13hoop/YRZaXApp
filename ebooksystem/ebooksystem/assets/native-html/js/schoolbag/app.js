/**
 * 页面入口
 * Created by jess on 15/1/16.
 */


! function( window ){

    var utils = window.utils;
    var $ = window.Zepto;
    var Dialog = window.Dialog;
    var bridgeXXX = window.bridgeXXX;
    var BookItem = window.BookItem;

    var downloadManager = window.downloadManager;
    var deleteController = window.deleteController;

    //显示书籍相关的参数设置
    var bookConfig = {
        //一本书占据高度
        height : 236,
        //两本书之间的水平间距
        horizonMargin : 11,
        //书籍父级容器在水平两侧的间距(只包含一边的值)
        bookContainerHorizonPadding : ( 18 ),
        //
        bookContainerVerticalPadding : 15,
        //书籍显示的列数
        cols : 3
    };

    /////////添加书籍按钮，点击后切换到  发现  频道
    var addBtnHTML = '<li class="add-book-wrap">' +
        '<div class="add-book-inner">+</div>' +
        '</li>';
    var $addBtn = $( addBtnHTML );

    $addBtn.on( 'tap', function(){
        bridgeXXX.goDiscoverPage();
    } );


    var singleton = {
        //数据是否已经渲染
        dataRendered : false,

        $win : null,

        $bookList : null,

        studyType : '',

        bookViewList : [],

        init : function(){

            this.$win = $(window);

            this.$bookList = $('#book-list');

            deleteController.init({
                app : this
            });

            //var searchConf = utils.query2json( location.search );

            //this.studyType = searchConf.study_type;
            //android 4.0.3 不支持 assets 目录的HTML文件带 query parameter 加载，临时写死
            this.studyType = '0';

            this._setupEvent();

            bridgeXXX.getBookList( this.studyType, this.showBookList.bind( this ) );

        },

        _setupEvent : function(){

            var that = this;

            document.addEventListener('SamaPageShow', function(){
                that.handlePageShow();
            }, false );

            document.addEventListener('SamaPageHide', function(){

                that.handlePageHide();
            }, false );

            deleteController.on('enter-edit', function(){
                that.enterEditMode();
            } );
            deleteController.on('exit-edit', function(){
                that.exitEditMode();
            } );
            deleteController.on('select-all', function(){
                that.selectAllBooks();
            });
            deleteController.on('unselect-all', function(){
                that.unselectAllBooks();
            });

            deleteController.on('delete-success', function(){
                that.reset();
                that.refresh();
            });

            EventEmitter.eventCenter.on('book-select-toggle', function(){
                deleteController.updateDelBtn();
            });
        },

        handlePageShow : function(){
            console.log('schoolbag:SamaPageShow');
            this.refresh();
        },

        handlePageHide : function(){
            console.log('schoolbag:SamaPageHide');
            this.reset();
        },

        refresh : function(){
            if( this.dataRendered ){
                return;
            }

            bridgeXXX.getBookList( this.studyType, this.showBookList.bind( this ) );
        },

        reset : function(){
            downloadManager.stop();
            this.exitEditMode();
            this.$bookList.empty().css({
                height : 'auto'
            });
            this.dataRendered = false;
            this.bookViewList = [];
        },

        showBookList : function( bookArr ){

            var arr;
            if( utils.isString(bookArr) ){
                try{
                    arr = JSON.parse( bookArr );
                }catch(e){
                    alert('解析书籍列表数据失败！');
                    return;
                }
            }else if( utils.isArray(bookArr) ){
                arr = bookArr;
            }else{
                alert('书籍列表数据格式非法！');
                return;
            }

            var width = this.$win.width();

            var columnNum = bookConfig.cols;
            var bookViewHeight = bookConfig.height;
            var bookViewWidth = ( width - bookConfig.bookContainerHorizonPadding * 2 - bookConfig.horizonMargin * 2 ) / bookConfig.cols;

            var bookViewList = this.bookViewList;


            var docFrag = document.createDocumentFragment();

            var that = this;

            var addedNum = 0;

            for( var i = 0, len = arr.length; i < len; i++ ){
                var item = arr[i];
                try{
                    item.book_meta_json = JSON.parse( item.book_meta_json );
                }catch(e){
                    continue;
                }
                var left = bookConfig.bookContainerHorizonPadding + ( addedNum % columnNum ) * ( bookViewWidth + bookConfig.horizonMargin);
                var top = Math.floor( addedNum / columnNum ) * bookViewHeight + bookConfig.bookContainerVerticalPadding;
                var view = new BookItem();
                item.width = bookViewWidth;
                item.height = bookViewHeight;
                item.left = left;
                item.top = top;
                var out = view.render( item );
                if( ! out ){
                    continue;
                }
                addedNum++;
                view.on( 'beginDownload', this.downloadBook.bind( this ) );
                view.on( 'enterBook', this.enterBook.bind( this ) );

                bookViewList.push( view );

                if( view.isBookDownloading() ){
                    downloadManager.addDownloadingBook( view );
                }else if( view.isLastDownloadInterrupted() ){
                    //上一次下载进程被异常中断，自动重启下载
                    setTimeout( ( function(bookView){
                        return function(){
                            bookView.beginDownload();
                            bookView = null;
                        };
                    })(view), 15);
                }

                bridgeXXX.getCoverSrc( item.book_id, ( function(bookView){
                    return function( coverSrc ){
                        if( bookView && coverSrc ){
                            bookView.setCoverImageSrc( coverSrc );
                        }
                        bookView = null;
                    };
                })(view) );
                //view.css( {
                //    width : bookViewWidth + 'px',
                //    height : bookViewHeight + 'px',
                //    left : left + 'px',
                //    top : top + 'px'
                //});
                docFrag.appendChild( view.getElement() );
            }

            //加入 添加书籍 按钮
            var left = bookConfig.bookContainerHorizonPadding + ( addedNum % columnNum ) * ( bookViewWidth + bookConfig.horizonMargin);
            var top = Math.floor( addedNum / columnNum ) * bookViewHeight + bookConfig.bookContainerVerticalPadding;

            addedNum++;


            $addBtn.css({
                width : bookViewWidth + 'px',
                height : 116 + 'px',
                'line-height' : '116px',
                left : left + 'px',
                top : top + 'px'
            });
            $addBtn.appendTo( docFrag );


            var totalHeight = Math.ceil( addedNum / columnNum) * bookViewHeight + bookConfig.bookContainerVerticalPadding * 2;

            this.$bookList.append( docFrag).css({
                height : totalHeight + 'px'
            });

            downloadManager.startCheck();
            //书籍列表已经渲染了
            this.dataRendered = true;

            //检查当前类目的书籍是否有更新
            bridgeXXX.checkDataUpdate( this.studyType );
        },

        downloadBook : function( bookView ){
            if( bookView ){
                downloadManager.downloadBook( bookView );
            }

        },

        enterBook : function( bookView ){
            if( bookView ){
                var bookID = bookView.getBookID();
                var getArgs = {
                    book_id : bookID,
                    query_id : 'top_page'
                };
                getArgs = '?' + utils.json2query(getArgs);
                bridgeXXX.renderPage({
                    target : 'activity',
                    book_id : bookView.getBookID(),
                    page_type : 'index',
                    get_args : getArgs,
                    post_args : ''
                });
            }
        },

        enterEditMode : function(){
            deleteController.enterEditMode();

            var viewList = this.bookViewList;
            for( var i = 0, len = viewList.length; i < len; i++ ){
                viewList[i].enterEditMode();
            }
        },
        exitEditMode : function(){
            deleteController.exitEditMode();
            var viewList = this.bookViewList;
            for( var i = 0, len = viewList.length; i < len; i++ ){
                viewList[i].exitEditMode();
            }
        },
        selectAllBooks : function(){
            var viewList = this.bookViewList;
            for( var i = 0, len = viewList.length; i < len; i++ ){
                viewList[i].selectBook( false );
            }
            deleteController.updateDelBtn();
        },
        unselectAllBooks : function(){
            var viewList = this.bookViewList;
            for( var i = 0, len = viewList.length; i < len; i++ ){
                viewList[i].unselectBook( false );
            }
            deleteController.updateDelBtn();
        },
        getSelectedIDs : function(){
            var out = [];
            var viewList = this.bookViewList;
            for( var i = 0, len = viewList.length; i < len; i++ ){
                var view = viewList[i];
                if( view.isSelected() ){
                    out.push( view.getBookID() );
                }
            }
            return out;
        }

    };

    window.app = singleton;



}( window );
