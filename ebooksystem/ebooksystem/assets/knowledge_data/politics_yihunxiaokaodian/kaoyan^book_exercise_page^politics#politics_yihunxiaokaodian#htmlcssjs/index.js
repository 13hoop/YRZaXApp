
!function(){

    //native暴露给JS的接口对象
    var bridgeIOS = window.bridgeIOS;

    window.app = window.app || {};

    var app = window.app;


    //当前页面统计事件的名字
    var eventName = 'politics_exercise_page';
    //夜间模式的 class
    var pageDisplayMode = 'page-mode-night';
    //对应当前这一组练习题的节点ID，通过此ID来找到这一组练习题的 data.json
    var currentID = '';
    //练习题数组
    var exerciseArray;
    //当前显示的练习题的序号
    var exerciseIndex = 0;
    //渲染习题
    var exerciseView;
    //前后练习题切换
    var switchView;

    app.run = function(){
        if( false ){
            try{
                if( bridgeIOS.canFixedHeightBoxScroll() === '1' ){
                    document.documentElement.classList.add( 'j-overflow-scroll-ok' );
                    var main = document.querySelector('#main-wrap');
                    main.classList.add( 'flexbox');
                }else{
                    document.documentElement.classList.add( 'j-overflow-scroll-bug' );
                }
            }catch(e){
                document.documentElement.classList.add( 'j-overflow-scroll-ok' );
                var main = document.querySelector('#main-wrap');
                main.classList.add( 'flexbox');
            }

        }else{
            document.documentElement.classList.add( 'j-overflow-scroll-ok' );
            var main = document.querySelector('#main-wrap');
            main.classList.add( 'flexbox');
        }

        document.documentElement.classList.add( pageDisplayMode);
        utils.initPageHeader();

        var searchConf = utils.getSearchConf();
        currentID = searchConf.data_id;
        exerciseIndex = parseInt( searchConf.exercise_index, 10 ) || 0;
        var queryID = searchConf.query_id;

        bridgeIOS.getNodeDataByIdAndQueryId( {
            dataId : currentID,
            queryId : queryID
        }, function(str){
            var data;
            try{
                data = JSON.parse( str );
                exerciseArray = data.data;
            }catch(e){
                console.error(e.message);
                exerciseArray = [];
            }

            if( ! exerciseArray || exerciseArray.length < 1 ){
                alert('木有找到该组练习题');
                return;
            }

            exerciseView = new ExerciseView({
                el : '#exercise-detail-con'
            });

            switchView = new ExerciseSwitchView({
                el : '#exercise-switch-con'
            });
            switchView.onIndexChange = function(index){
                renderExercise( index );
                switchView.setForwardAction( ExerciseSwitchView.SUBMIT_ANSWER );
            };
            switchView.onSubmitAnswer = function(){
                exerciseView.showAnswer();
                switchView.setForwardAction( ExerciseSwitchView.FORWARD );
            };
            switchView.setTotalNum( exerciseArray.length );

            renderExercise( exerciseIndex );

            //统计页面展现PV
            var args = {
                type : 'pv'
            };
            args = JSON.stringify( args );
            bridgeIOS.pageStatistic( eventName, args );
        } );

    };

    app.stop = function(){};

    function renderExercise( index ){
        if( index < 0 || index >= exerciseArray.length || ! exerciseArray[index] ){
            alert('找不到练习题咯');
            return;
        }
        exerciseIndex = index;
        var obj = exerciseArray[index];
        //设置为 做练习 模式，允许用户点击 选项
        exerciseView.setDisplayMode( ExerciseView.DO_EXERCISE );
        switchView.setForwardAction( ExerciseSwitchView.SUBMIT_ANSWER );
        exerciseView.render( obj );
        switchView.render( index );
    }

}();
