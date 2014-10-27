
!function(){
    
    //native暴露给JS的接口对象
    var bridgeIOS = window.bridgeIOS;
    
    window.app = window.app || {};
    var app = window.app;
    
    //当前渲染页面对应的ID，通过ID来找到该页面内要显示的数据
    var currentID = '';
    //当前所在书籍的ID
    var bookID = '';
    //当前书籍列表页数据所对应的query_id
    var bookQueryID = '';
    //当前所在书籍的名字
    var bookName = '';
    //当前所在子科目的ID，比如 马原、毛特等
    var topicID = '';
    //
    var topicQueryID = '';
    
    //政治知识点列表页统计名
    var eventName = 'politics_knowledge_list';
    //夜间模式的 class
    var pageDisplayMode = 'page-mode-night';
    
    //渲染书籍列表
    function renderChildList(data ){
        var bookListEl = document.querySelector('#child-list-con');
        
        data = data.subcolumn_arr;
        
        var html = '';
        
        data.forEach( function( item, index ){
                     
                     html += '<li class="knowledge-item common-hoverable-item common-split-border arrow-parent clearfix" ' +
                     ' data-page_id="' + item.page_id + '" ' +
                     ' data-data_id="' + item.id + '" ' +
                     ' data-query_id="' + item.query_id + '" ' +
                     ' data-book_name_ch="' + bookName + '" ' +
                     ' data-index="' + index + '" ' +
                     ' data-name_ch="' + item.name_ch + '">' +
                     '<span class="knowledge-index">' + ( index + 1 ) + '.</span>' +
                     '<div class="knowledge-text-wrap">' + item.name_ch + '</div>' +
                     '<span class="right-arrow"></span>' +
                     '</li>';
                     });
        
        bookListEl.innerHTML = html;
        
        //绑定item点击事件
        bookListEl.addEventListener( 'click', function(e){
                                    e.preventDefault();
                                    var target  = e.target;
                                    while( target && target != bookListEl && ! target.classList.contains( 'knowledge-item') ){
                                    target = target.parentNode;
                                    }
                                    if( target && target != bookListEl ){
                                    var pageID = target.getAttribute('data-page_id');
                                    var id = target.getAttribute('data-data_id');
                                    var queryID = target.getAttribute('data-query_id');
                                    var bookName = target.getAttribute('data-book_name_ch');
                                    var args = {
                                    book_id : encodeURIComponent( bookID ),
                                    book_query_id : encodeURIComponent( bookQueryID ),
                                    book_name_ch : encodeURIComponent( bookName ),
                                    data_id : encodeURIComponent( id ),
                                    query_id : encodeURIComponent(queryID),
                                    topic_id : encodeURIComponent( topicID ),
                                    topic_query_id : encodeURIComponent( topicQueryID )
                                    };
                                    args = utils.json2Query( args );
                                    bridgeIOS.showPageById( pageID, args, '' );
                                    }
                                    
                                    }, false );
    }
    
    
    //页面启动入口函数
    app.run = function(){
        document.documentElement.classList.add( pageDisplayMode);
        utils.initPageHeader();
        
        var searchConf = utils.getSearchConf();
        //获取数据ID
        bookQueryID = searchConf.book_query_id;
        currentID = searchConf.data_id;
        var queryID = searchConf.query_id;
        
        topicQueryID = searchConf.query_id;
        
        if( ! currentID  ){
            bridgeIOS.pageError('页面迷路了，找不到ID');
            return;
        }
        
        bridgeIOS.getNodeDataByIdAndQueryId( {
                                            dataId : currentID,
                                            queryId : queryID
                                            }, function(data){
                                            
                                            try{
                                            data = JSON.parse( data );
                                            }catch(e){
                                            console.error( data );
                                            console.error(e.message);
                                            bridgeIOS.pageError( '数据出错！');
                                            return;
                                            }
                                            bookID = searchConf.book_id;
                                            //bookQueryID = queryID;
                                            bookName = searchConf.book_name_ch;
                                            topicID = searchConf.topic_id;
                                            var nodeName = data.topic_name_ch;
                                            if( nodeName ){
                                            var titleEl = document.querySelector('.page-header .page-title');
                                            if( titleEl ){
                                            titleEl.innerText = nodeName;
                                            }
                                            }
                                            
                                            renderChildList( data );
                                            
                                            //统计页面展现PV
                                            var args = {
                                            type : 'pv',
                                            book_name : bookName,
                                            topic_name : data.topic_name_ch
                                            };
                                            args = JSON.stringify( args );
                                            bridgeIOS.pageStatistic( eventName, args );
                                            } );
        
    };
    
    app.stop = function(){};
    
}();
