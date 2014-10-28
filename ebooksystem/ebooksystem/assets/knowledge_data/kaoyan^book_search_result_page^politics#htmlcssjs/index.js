
!function(){

// native暴露给JS的接口对象
    var bridge = window.bridgeIOS ;
        
    
    window.app = window.app || {};

    var app = window.app;

//当前渲染页面对应的ID，通过ID来找到该页面内要显示的数据
    var currentID = '';
//当前所在书籍的ID
    var bookID = '';
//当前所在书籍的名字
    var bookName = '';

    //书籍首页的统计事件
    var eventName = 'politics_book_search_page';
    //夜间模式的 class
    var pageDisplayMode = 'page-mode-night';

    var searchInput;
    var clearInputBtn;
    var searchBtn;
    var searchResult;

    var currentQuery = '';


//绑定事件
function setupEvent(){
    
    //点击清空输入框按钮
    clearInputBtn.addEventListener('touchend', function(e){
        searchInput.value = '';
        searchBtn.innerText = '取消';
        clearInputBtn.style.visibility = 'hidden';
    }, false );

    var updateSearchUI = function(){
        var val = searchInput.value;
        val = val.trim();
        if( val ){
            searchBtn.innerText = '搜索';
            clearInputBtn.style.visibility = 'visible';
        }else{
            searchBtn.innerText = '取消';
            clearInputBtn.style.visibility = 'hidden';
        }
        searchInput.focus();
    };

    //输入框内容变化，改变按钮的提示
    searchInput.addEventListener( 'focus', updateSearchUI, false );
    searchInput.addEventListener( 'change', updateSearchUI, false );
    searchInput.addEventListener( 'keyup', updateSearchUI, false );

    //点击 “搜索/取消” 按钮
    searchBtn.addEventListener( 'click', function(e){
        var val = searchInput.value.trim();
        if( val ){
            //当前输入框有内容，执行搜索
            doSearch( val );
        }else{
            //如果当前没有输入内容，则退出搜索页面
            bridge.finish();
        }
    }, false );

    //点击搜索结果，进入对应详情页
    searchResult.addEventListener( 'click', function(e){
        var target = e.target;
        var itemClass = 'search-result-item';
        while( target && target != searchResult && ! target.classList.contains(itemClass) ){
            target = target.parentNode;
        }
        if( target && target != searchResult && target.classList.contains( itemClass) ){
            //跳转到对应知识点详情页
            var pageID = target.getAttribute('data-page_id');
            var dataID = target.getAttribute('data-data_id');
            var queryID = target.getAttribute('data-query_id');
            var bookID = target.getAttribute('data-book_id');
            var bookQueryID = target.getAttribute('data-book_query_id');
            var topicID = target.getAttribute('data-topic_id');
            var topicQueryID = target.getAttribute('data-topic_query_id');
            var searchArgs = {
                data_id : encodeURIComponent( dataID ),
                query_id : encodeURIComponent( queryID),
                book_id : encodeURIComponent( bookID ),
                book_query_id : encodeURIComponent( bookQueryID ),
                topic_id : encodeURIComponent( topicID ),
                topic_query_id : encodeURIComponent(topicQueryID)
            };
            searchArgs = utils.json2Query( searchArgs );
            bridge.showPageById( pageID, searchArgs, '{}' );
        }
    }, false );
}

//执行搜索
function doSearch(query){
    if( query === currentQuery ){
        return;
    }
    currentQuery = query;
    bridge.searchData( currentQuery, function(data){
        if( query !== currentQuery ){
            return;
        }
        showSearchResult( data );
    } );
}
//显示搜索结果
function showSearchResult(data){
    try{
        data = JSON.parse( data );
    }catch(e){
        alert('查询结果失败');
        currentQuery = '';
        return;
    }
    var html = '';
    if( ! data || data.length < 1 ){
        html = '<div class="no-result-wrap">无结果<br />请确认已下载《选择题难点微课》和《易混淆考点》，且编号输入正确。</div>';
    }else{
        data.forEach(function(obj){
            html += '<div class="search-result-item common-split-border" ' 
                    + ' data-book_id="' + obj.id + '" '
                    + ' data-book_query_id="' + obj.path + '" '
                    + ' data-topic_id="' + obj.id + '" '
                    + ' data-topic-query_id="' + obj.topic_query_id + '" '
                    + ' data-data_id="' + obj.id + '" '
                    + ' data-query_id="' + obj.query_id + '" '
                    + ' data-page_id="' + obj.page_id + '" >' 
                    + '<h3 class="search-title">' + obj.title + '</h3>'
                    + '<div class="search-desc">' + obj.title + '</div>'
                    + '<span class="right-arrow"></span>'
                 + '</div>';
        });    
    }

    searchResult.innerHTML = html;
    
}

//页面启动入口函数
    app.run = function(){
//        document.documentElement.classList.add( pageDisplayMode);
        utils.initPageHeader();
        var searchConf = utils.getSearchConf();

        searchInput = document.querySelector('#search-input');
        clearInputBtn = document.querySelector('#clear-input-btn');
        searchBtn = document.querySelector('#search-btn');
        searchResult = document.querySelector('#search-result-con');
        
        setupEvent();
        // var data = bridgeIOS.getNodeDataById( currentID, function(data){

        //     try{
        //         data = JSON.parse( data );
        //     }catch(e){
        //         console.error(e.message);
        //         bridgeIOS.pageError( '数据出错！');
        //         return;
        //     }

        //     bookID = searchConf.book_id;
        //     bookName = '搜索政治知识点';
        //     if( bookName ){
        //         var titleEl = document.querySelector('.page-header .page-title');
        //         if( titleEl ){
        //             titleEl.innerText = bookName;
        //         }
        //     }

        //     renderChildList( data );

            
        
        // } );

        searchInput.focus();
        
        //统计页面展现PV
        var args = {
            type : 'pv',
            book_name : bookName
        };
        args = JSON.stringify( args );
        bridgeIOS.pageStatistic( eventName, args );
        
    };

    app.stop = function(){};

}();
