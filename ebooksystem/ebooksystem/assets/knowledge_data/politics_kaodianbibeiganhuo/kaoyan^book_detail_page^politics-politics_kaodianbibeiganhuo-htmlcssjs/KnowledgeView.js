/**
 * 负责渲染单个知识点的详情
 * Created by jess on 14-9-17.
 */


function KnowledgeView( args ){

    this.el = document.querySelector(args.el);

    //用户点击微课图片的回调
    this.onVideoClick = args.onVideoClick;
    //用户点击做练习按钮
    this.onDoExercise = args.onDoExercise;

    //知识点本身描述
    this.descWrap = null;
    this.descInner = null;

    //命题形式
    this.examTypeWrap = null;
    this.examTypeInner = null;

    //命题角度
    this.examPointWrap = null;
    this.examPointInner = null;

    //知识点解析
    this.analysisWrap = null;
    this.analysisInner = null;

    //微课视频
    this.weikeWrap = null;
    this.weikeInner = null;

    //做练习 按钮
    this.exerciseBtn = null;

    //当前知识点obj
    this.currentObj = null;

    //左右手势翻页的相关属性
    this.onKnowledgeSwitch = args.onKnowledgeSwitch;
    this.touchStartX = 0;                   //触摸开始的屏幕X坐标
    this.touchStartY = 0;                   //触摸开始的屏幕Y坐标
    this.touchStartTime = 0;                //点击开始时间戳
    this.SWIPE_SPEED_SENSOR = 30;           //水平滑动速率，超过这个值，认为是切换
    this.SWIPE_SENSOR_HORIZONTAL = 20;                 //水平超过这个距离，才算做切换
    this.SWIPE_SENSOR_VERTICAL = 10;        //如果Y轴超过这个值，则不认为是水平swipe

    this._setupDOM();
    this._setupEvent();
}


KnowledgeView.prototype = {

    constructor : KnowledgeView,

    _setupDOM : function(){

        var el = this.el;

        this.descWrap = el.querySelector('.knowledge-desc-wrap');
        this.descInner = el.querySelector('.knowledge-desc-wrap .knowledge-section-content');

        this.weikeWrap = el.querySelector('.knowledge-weike-wrap');
        this.weikeInner = el.querySelector('.knowledge-weike-wrap .knowledge-section-content');

        this.examTypeWrap = el.querySelector('.knowledge-exam-type-wrap');
        this.examTypeInner = el.querySelector('.knowledge-exam-type-wrap .knowledge-section-content');

        this.examPointWrap = el.querySelector('.knowledge-exam-point-wrap');
        this.examPointInner = el.querySelector('.knowledge-exam-point-wrap .knowledge-section-content');

        this.analysisWrap = el.querySelector('.knowledge-analysis-wrap');
        this.analysisInner = el.querySelector('.knowledge-analysis-wrap .knowledge-section-content');

        this.exerciseBtn = el.querySelector('#go-exercise-btn');
    },

    _setupEvent : function(){

        var that = this;

        //点击微课图片。播放微课视频
        this.weikeInner.addEventListener('click', function(e){
            var target = e.target;
            if( target.classList.contains('weike-img') ){
                that.weikeImgClick();
            }
        }, false );

        //点击 做练习 按钮
        this.exerciseBtn.addEventListener( 'click', function(e){
            that.exerciseClick();
        }, false );

        //手势翻页效果
//        this.el.addEventListener('touchstart', function(e){
//            that._handleTouchStart(e);
//        }, false );
//        this.el.addEventListener('touchend', function(e){
//            that._handleTouchEnd(e);
//        }, false );
//        this.el.addEventListener('touchcancel', function(e){
//            that._handleTouchEnd(e);
//        }, false );
    },

    //用户点击微课图片
    weikeImgClick : function(){
        var url = this.currentObj.weike_url;
        if( url ){
            if( typeof  this.onVideoClick === 'function' ){
                this.onVideoClick( url );
            }
        }
    },

    //点击做练习按钮
    exerciseClick : function(){
        if( ! this._hasExercise() ){
            return;
        }
        var obj = this.currentObj;
        if( typeof this.onDoExercise === 'function' ){
            this.onDoExercise( obj.exercise_page_id, obj.exercise_data_id, obj.id );
        }
    },

    //判断当前知识点是否有练习题
    _hasExercise : function(){
        //临时关闭练习题入口
        return false;
        var obj = this.currentObj;
        if( obj._hasExercise ){
            return true;
        }
        if( obj.exercise_page_id && obj.exercise_data_id  ){
            var pageDownloaded = bridgeIOS.hasNodeDownloaded( obj.exercise_page_id );
            if( pageDownloaded === '1' ){
                obj._hasExercise = true;
                return true;
            }
        }
        return false;
    },

    render : function( obj ){

        if( ! obj ){
            return;
        }
        this.currentObj = obj;

        //渲染知识点本身描述
        if( obj.kaodian_explain ){
            this.descInner.innerHTML = obj.kaodian_explain;
            this.descWrap.style.display = 'block';
        }else{
            this.descWrap.style.display = 'none';
        }

        //渲染知识点微课
        if( obj.weike_url ){
            var html = '<img class="weike-img" style="width: 290px; height:180px; " src="./assets/politics_weike_img.png" />';
            this.weikeInner.innerHTML = html;
            this.weikeWrap.style.display = 'block';
        }else{
            this.weikeWrap.style.display = 'none';
        }

        //渲染命题形式
        if( obj.mingti_xingshi ){
            this.examTypeInner.innerText = obj.mingti_xingshi;
            this.examTypeWrap.style.display = 'block';
        }else{
            this.examTypeWrap.style.display = 'none';
        }

        //渲染命题角度
        if( obj.mingti_jiaodu ){
            this.examPointInner.innerText = obj.mingti_jiaodu;
            this.examPointWrap.style.display = 'block';
        }else{
            this.examPointWrap.style.display = 'none';
        }

        //知识点解析
        if( obj.analysis ){
            this.analysisInner.innerText = obj.analysis;
            this.analysisWrap.style.display = 'block';
        }else{
            this.analysisWrap.style.display = 'none';
        }

        //是否显示 做练习 按钮
        if( this._hasExercise() ){
            this.exerciseBtn.style.display = 'block';
        }else{
            this.exerciseBtn.style.display = 'none';
        }
    },

    _handleTouchStart : function(e){
        var touch = e.touches[0];
        if( touch ){
            this.touchStartX = touch.clientX;
            this.touchStartY = touch.clientY;
            this.touchStartTime = (new Date()).getTime();
        }else{
            this.touchStartX = null;
            this.touchStartY = null;
            this.touchStartTime = null;
        }
    },
    _handleTouchEnd : function(e){
        var touch = e.changedTouches[0];
        if( ! touch || this.touchStartX === null || this.touchStartY === null ){
            return;
        }
        var endTime = (new Date()).getTime();
        var endX = touch.clientX;
        var endY = touch.clientY;
        var deltaX = endX - this.touchStartX;
        var deltaY = endY - this.touchStartY;
        this.touchStartX = null;
        this.touchStartY = null;
        if( Math.abs( deltaY) >= this.SWIPE_SENSOR_VERTICAL ){
            //用户当前是在Y轴滚动，不触发知识点切换
            return;
        }
        var speed = Math.abs(deltaX) * 1000 / ( endTime - this.touchStartTime );
        if( Math.abs( deltaX) < this.SWIPE_SENSOR_HORIZONTAL && speed < this.SWIPE_SPEED_SENSOR ){
            //用户在X轴滑动距离太小，不触发知识点切换
            return;
        }
        var direction = deltaX > 0 ? 'pre' : 'next';
        var id;
        if( direction === 'pre' ){
            id = this.currentObj.pre_sibling_id;
        }else{
            id = this.currentObj.next_sibling_id;
        }
        if( id ){
            if( typeof this.onKnowledgeSwitch == 'function' ){
                this.onKnowledgeSwitch( id, direction );
            }
        }

    }

};