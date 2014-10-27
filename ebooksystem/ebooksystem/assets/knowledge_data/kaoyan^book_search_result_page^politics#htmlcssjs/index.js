
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
    searchBtn.addEventListener( 'touchend', function(e){
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
            var bookID = target.getAttribute('data-book_id');
            var topicID = target.getAttribute('data-topic_id');
            var searchArgs = {
                data_id : encodeURIComponent( dataID ), 
                book_id : encodeURIComponent( bookID ), 
                topic_id : encodeURIComponent( topicID )
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
                    + ' data-book_id="' + obj.book_id + '" '
                    + ' data-topic_id="' + obj.topic_id + '" '
                    + ' data-data_id="' + obj.id + '" '
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
