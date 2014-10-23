
!function(){

// native暴露给JS的接口对象
    var bridge = (window.bridgeIOS ? window.bridgeIOS : window.bridgeIOS);
        
    
    window.app = window.app || {};

    var app = window.app;

//当前渲染页面对应的ID，通过ID来找到该页面内要显示的数据
    var currentID = '';
//当前所在书籍的ID
    var bookID = '';
//当前所在书籍的名字
    var bookName = '';

    //书籍首页的统计事件
    var eventName = 'politics_book_top_page';
    //夜间模式的 class
    var pageDisplayMode = 'page-mode-night';

//渲染书籍列表
    function renderChildList( data ){
        var bookListEl = document.querySelector('#child-list-con');

        data = data.subcolumn_arr;

        var html = '';

        data.forEach( function( item, index ){

            html += '<li class="topic-item common-hoverable-item common-split-border arrow-parent clearfix" ' +
                ' data-page_id="' + item.page_id + '" ' +
                ' data-data_id="' + item.id + '" ' +
                ' data-book_name_ch="' + bookName + '" ' +
                ' data-name_ch="' + item.name_ch + '">' +
                '<span class="topic-knowledge-num">' + item.kaodian_num + '个</span>' +
                '<div class="topic-text-wrap">' + item.name_ch + '</div>' +
                '<span class="right-arrow"></span>' +
                '</li>';
        });

        bookListEl.innerHTML = html;

        //绑定书籍点击事件
        bookListEl.addEventListener( 'click', function(e){
            e.preventDefault();
            var target  = e.target;
            while( target && target != bookListEl && ! target.classList.contains( 'topic-item') ){
                target = target.parentNode;
            }
            if( target && target != bookListEl ){
                var pageID = target.getAttribute('data-page_id');
                var id = target.getAttribute('data-data_id');
                var bookName = target.getAttribute('data-book_name_ch');
                var nodeName = target.getAttribute('data-name_ch');
                var args = {
                    book_id : encodeURIComponent( bookID ),
                    book_name_ch : encodeURIComponent( bookName ),
                    data_id : encodeURIComponent( id ),
                    topic_id : encodeURIComponent( id ),
                    topic_name_ch : encodeURIComponent( nodeName )
                };
                args = utils.json2Query( args );
                bridgeIOS.showPageById( pageID, args, '{}' );
            }

        }, false );
    }


//页面启动入口函数
    app.run = function(){
        document.documentElement.classList.add( pageDisplayMode);
        utils.initPageHeader();
        var searchConf = utils.getSearchConf();

        //获取数据ID
        currentID = searchConf.data_id;

        if( ! currentID ){
            bridgeIOS.pageError('页面迷路了，找不到ID');
            return;
        }

        var data = bridgeIOS.getNodeDataById( currentID, function(data){

            try{
                data = JSON.parse( data );
            }catch(e){
                console.error(e.message);
                bridgeIOS.pageError( '数据出错！');
                return;
            }

            bookID = searchConf.book_id;
            bookName = data.book_name_ch;
            if( bookName ){
                var titleEl = document.querySelector('.page-header .page-title');
                if( titleEl ){
                    titleEl.innerText = bookName;
                }
            }

            renderChildList( data );

            //统计页面展现PV
            var args = {
                type : 'pv',
                book_name : bookName
            };
            args = JSON.stringify( args );
            bridgeIOS.pageStatistic( eventName, args );
        
        } );
        
    };

    app.stop = function(){};

}();
