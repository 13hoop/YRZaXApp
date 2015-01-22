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

        $win : null,

        $bookList : null,

        studyType : '',

        bookViewList : [],

        init : function(){

            this.$win = $(window);

            this.$bookList = $('#book-list');

            var listEl = document.querySelector('#book-list');

            var searchConf = utils.query2json( location.search );

            //alert( '用户选择的考试类型： ' + searchConf.study_type );

            this.studyType = searchConf.study_type;


            ////测试修改 用户选择的 考试类型
            //setTypeWrap.addEventListener( 'click', function(e){
            //    var target = e.target;
            //    var type = target.getAttribute('data-type');
            //    if( type ){
            //        bridgeXXX.setCurStudyType( type, function( data ){
            //            if( data === bridgeXXX.constant.START_DOWNLOAD_SUCCESS ){
            //                alert('设置考试类型【' + type + '】成功');
            //            }else{
            //                alert('设置考试类型失败！');
            //            }
            //        } );
            //    }
            //}, false );

            //Dialog.alert({
            //    content : '测试看看范德萨发撒飞洒划分为我额uwfaosfadsfs我额urweur；撒合肥市大黄蜂'
            //});


            this._setupEvent();

            bridgeXXX.getBookList( this.studyType, this.showBookList.bind( this ) );

        },

        _setupEvent : function(){

            var $settingBtn = $('.setting-btn');
            $settingBtn.on( 'tap', function(){
                bridgeXXX.goUserSettingPage();
            } );
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

            var bookListView = this.bookViewList;


            var docFrag = document.createDocumentFragment();

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

                if( view.isBookDownloading() ){
                    downloadManager.addDownloadingBook( view );
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
                height : 129 + 'px',
                left : left + 'px',
                top : top + 'px'
            });
            $addBtn.appendTo( docFrag );


            var totalHeight = Math.ceil( addedNum / columnNum) * bookViewHeight + bookConfig.bookContainerVerticalPadding * 2;

            this.$bookList.append( docFrag).css({
                height : totalHeight + 'px'
            });

            downloadManager.startCheck();
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
                    getArgs : getArgs,
                    postArgs : ''
                });
            }
        }

    };

    window.app = singleton;



}( window );
