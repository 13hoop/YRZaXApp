/**
 * Created by jess on 14-9-28.
 */

function ExerciseSwitchView(args){
    this.el = document.querySelector(args.el);
    //当前进度
    this.indicatorWrap = null;
    this.switchPreBtn = null;
    this.switchNextBtn = null;

    this.onIndexChange = args.onIndexChange;
    this.onSubmitAnswer = args.onSubmitAnswer;

    this.totalNum = 0;
    this.currentIndex = 0;

    //模式点击  提交 按钮，执行提交选项操作
    this.forwardAction = ExerciseSwitchView.SUBMIT_ANSWER;

    this._setupDOM();
    this._setupEvent();
}

ExerciseSwitchView.prototype = {
    constructor : ExerciseSwitchView,
    _setupDOM : function(){
        var el = this.el;
        this.indicatorWrap = el.querySelector('.current-exercise-indicator');
        this.switchPreBtn = el.querySelector('.exercise-switch-pre');
        this.switchNextBtn = el.querySelector('.exercise-switch-next');
    },
    _setupEvent : function(){
        var that = this;

        var switchClick = function(e){
            var target = e.target;
            var action = target.getAttribute('data-action');
            var delta = action === 'next' ? 1 : -1;
            that.switchByIndex( that.currentIndex + delta );
        };
        this.switchPreBtn.addEventListener( 'click', switchClick, false );
        //下一题 按钮，包含了 提交答案 和  切换下一题  两种情况，要单独处理
        this.switchNextBtn.addEventListener( 'click', function(e){
            that.onNextBtnClick();
        }, false );
    },
    render : function( exerciseIndex ){
        this.currentIndex = exerciseIndex;
        this.indicatorWrap.innerHTML = '进度：<span class="current-index-num">'
            + ( exerciseIndex + 1 ) + '</span>/' + this.totalNum;
        if( exerciseIndex > 0 ){
            this.switchPreBtn.style.display = 'block';
        }else{
            this.switchPreBtn.style.display = 'none';
        }
        if( exerciseIndex < this.totalNum ){
            this.switchNextBtn.style.display = 'block';
        }else{
            this.switchNextBtn.style.display = 'none';
        }
    },
    //设置总的练习题数目
    setTotalNum : function(num){
        num = parseInt( num, 10 ) || 0;
        this.totalNum = num;
    },
    switchByIndex : function(index){
        if( index < 0 || index >= this.totalNum ){
            return;
        }
        if( typeof this.onIndexChange === 'function' ){
            this.onIndexChange( index );
        }
    },
    setForwardAction : function(action){
        this.forwardAction = action;
        if( action === ExerciseSwitchView.SUBMIT_ANSWER ){
            this.switchNextBtn.innerText = '提交';
        }else{
            if( this.currentIndex === this.totalNum - 1 ){
                this.switchNextBtn.style.display = 'none';
            }
            this.switchNextBtn.innerText = '下一题';
        }

    },
    onNextBtnClick : function(){
        if( this.forwardAction === ExerciseSwitchView.SUBMIT_ANSWER ){
            if( typeof  this.onSubmitAnswer === 'function' ){
                this.onSubmitAnswer();
            }
        }else{
            this.switchByIndex( this.currentIndex + 1 );
        }
    }
};

//提交选项，看答案
ExerciseSwitchView.SUBMIT_ANSWER = 'submit_answer';
//切换到下一题
ExerciseSwitchView.FORWARD = 'go_next_exercise';