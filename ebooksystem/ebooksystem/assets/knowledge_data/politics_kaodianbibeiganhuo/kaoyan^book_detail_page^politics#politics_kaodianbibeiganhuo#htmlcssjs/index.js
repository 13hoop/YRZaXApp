
!function(){

    //native暴露给JS的接口对象
    var bridgeIOS = window.bridgeIOS;

    window.app = window.app || {};


//当前书籍对应的节点ID
    var bookID = '';
//当前所在书籍的名字
    var bookName = '';
//当前所属小科目的ID，马原、毛特、思修等
    var topicID = '';
//当前渲染页面对应的ID，通过ID来找到该页面内要显示的数据
    var currentID = '';

    //顶部知识点切换栏
    var indicatorView;
    //知识点详情
    var knowledgeView;

    //当前页面统计事件的名字
    var eventName = 'politics_knowledge_detail';
    //夜间模式的 class
    var pageDisplayMode = 'page-mode-night';
    //是否已经显示了页面名
    var titleInited = false;

//页面启动入口函数
    app.run = function(){
        document.documentElement.classList.add( pageDisplayMode);
        utils.initPageHeader();
        var searchConf = utils.getSearchConf();
        //获取数据ID
        currentID = searchConf.data_id;
        var queryID = searchConf.query_id;

        if( ! currentID  ){
            bridgeIOS.pageError('页面迷路了，找不到ID');
            return;
        }

        bookID = searchConf.book_id;

        topicID = searchConf.topic_id;

        //顶部知识点切换栏
        indicatorView = new KnowledgeIndicator({
            el : '#knowledge-switch-con'
        });
        indicatorView.onchange = function( args ){
            var id = args.data_id;
            var queryID = args.query_id;
            var direction = args.direction;
            var args = {
                pos : 'indicator',
                type : 'knowledge_switch',
                direction : direction
            };
            args = JSON.stringify( args );
            bridgeIOS.pageStatistic( eventName, args );
            showKnowledgeById( id, queryID );
        };

        //知识点详情视图
        knowledgeView = new KnowledgeView({
            el : '#topic-detail-con'
        });
        //在知识点上的手势左右切换
        knowledgeView.onKnowledgeSwitch = function( id, direction ){
            var args = {
                pos : 'swipe',
                type : 'knowledge_switch',
                direction : direction
            };
            args = JSON.stringify( args );
            bridgeIOS.pageStatistic( eventName, args );
            showKnowledgeById( id );
        };
        //点击微课图片。播放视频
        knowledgeView.onVideoClick = function( url ){
            var args = {
                type : 'play_video',
                url : url
            };
            args = JSON.stringify( args );
            bridgeIOS.pageStatistic( eventName, args );
            bridgeIOS.playVideo( url );
        };
        //点击做练习按钮
        knowledgeView.onDoExercise = function( pageID, exerciseDataID, id  ){
            console.info( '点击做练习，page_id: ' + pageID + '; data_id: ' + exerciseDataID );
            var args = {
                type : 'do_exercise',
                knowledge_id : id
            };
            args = JSON.stringify( args );
            bridgeIOS.pageStatistic( eventName, args );
            var args2 = {
                data_id : exerciseDataID
            };
            args2 = utils.json2Query(args2);
            bridgeIOS.showPageById( pageID, args2, '{}' );
        };

        //渲染当前ID对应的知识点
        showKnowledgeById( currentID, queryID );

        //统计页面展现PV
        var args = {
            type : 'pv'
        };
        args = JSON.stringify( args );
        bridgeIOS.pageStatistic( eventName, args );
    };

    app.stop = function(){};

    //渲染 id 对应的知识点
    function showKnowledgeById( id, queryID ){
        console.info(id);
        bridgeIOS.getNodeDataByIdAndQueryId( {
            dataId : id,
            queryId : queryID
        }, function(knowledge){
            try{
                knowledge = JSON.parse( knowledge );
            }catch(e){
                knowledge = null;
                console.error(e.message);
            }
            if( ! knowledge ){
                alert('找不到知识点！');
                return;
            }

            currentID = id;

            showKnowledgeByData( knowledge );
        } );
    }

    function showKnowledgeByData(knowledge){
        if( ! titleInited ){
            bookName = knowledge.book_name_ch;
            if( bookName ){
                var titleEl = document.querySelector('.page-header .page-title');
                if( titleEl ){
                    titleEl.innerText = bookName;
                }
                titleInited = true;
            }
        }
        bookID = knowledge.book_id;
        indicatorView.render( knowledge );
        knowledgeView.render( knowledge );
    }

    function changeTopicById( id ){
        bridgeIOS.getNodeDataById( id, function(topicData){
            try{
                topicData = JSON.parse( topicData );
            }catch(e){
                console.error(e.message);
                topicData = null;
            }
            if( ! topicData ){
                bridgeIOS.pageError('未找到该科目数据！');
                return;
            }
            var data = topicData.subcolumn_arr;
            if( ! data || data.length < 1 ){
                bridgeIOS.pageError('未找到该科目下的知识点列表！');
                return;
            }
            topicID = id;
            var obj = data[0];
            showKnowledgeById( obj.id );
        } );
        
    }

}();
