/**
 * Created by jess on 14-9-28.
 */

function ExerciseView(args){
    this.el = document.querySelector(args.el);
    this.questionWrap = null;
    this.questionTitle = null;
    this.questionInner = null;
    this.analysisWrap = null;
    this.analysisInner = null;

    this.optionList = null;

    this.currentObj = null;
    this.answerArray = [];
    //默认显示模式为  做题模式
    this.displayMode = args.displayMode || ExerciseView.DO_EXERCISE;

    this.OPTION_ITEM_CLASS = 'option-item';                   //
    this.OPTION_RIGHT_ANSWER = 'option-right-answer';       //正确选项
    this.OPTION_WRONG_ANSWER = 'option-wrong-answer';       //错误选项

    this.OPTION_SELECTED_CLASS = 'option-selected';         //当前选中的选项

    this._setupDOM();
    this._setupEvent();
}

ExerciseView.prototype = {

    constructor : ExerciseView,

    _setupDOM : function(){
        var el = this.el;
        this.questionWrap = el.querySelector('.question-desc-wrap');
        this.questionTitle = el.querySelector('.question-desc-wrap .exercise-section-title');
        this.questionInner = el.querySelector('.question-desc-wrap .exercise-section-content');
        this.analysisWrap = el.querySelector('.answer-analysis-wrap');
        this.analysisInner = el.querySelector('.answer-analysis-wrap .exercise-section-content');
        this.optionList = el.querySelector('#option-list');
    },

    _setupEvent : function(){

        var that = this;
        //点击选项
        this.optionList.addEventListener( 'click', function(e){
            var target = e.target;
            var itemClass = that.OPTION_ITEM_CLASS;
            var con = that.optionList;
            while( target && target != con && ! target.classList.contains( itemClass) ){
                target = target.parentNode;
            }
            if( target && target.classList.contains(itemClass) ){
                if( ! that.canSelect() ){
                    return;
                }
                var selectedClass = that.OPTION_SELECTED_CLASS;
                if( target.classList.contains(selectedClass) ){
                    //如果点击的选项已经选中，则取消选中状态
                    target.classList.remove( selectedClass );
                }else{
                    //如果是单选，先清除掉上次选中的选项
                    if( that.isSingleChoice() ){
                        var lastSelect = con.querySelector('.' + selectedClass);
                        if( lastSelect ){
                            lastSelect.classList.remove( selectedClass );
                        }
                    }
                    target.classList.add( selectedClass );
                }
            }
        }, false );
    },

    render : function(obj){
        if( ! obj ){
            return;
        }
        this.currentObj = obj;
        var answerArray = obj.answers;
        this.answerArray = answerArray;
        var title = '单项选择';
        if( answerArray.length > 1 ){
            title = '多项选择';
        }
        this.questionTitle.innerText = title;
        this.questionInner.innerText = obj.question;
        //渲染答案及解析
        this.analysisWrap.style.display = 'none';
        var analysis = '<div>【正确答案】' + obj.answers.join('') + '</div>';
        analysis += '<div>【题目解析】' + obj.analysis + '</div>';
        this.analysisInner.innerHTML = analysis;
        //渲染选项
        var optionsHTML = '';
        var options = obj.options;
        var charCodeOfA = 'A'.charCodeAt(0);
        var itemClass = this.OPTION_ITEM_CLASS;
        for( var i = 0, len = options.length; i < len; i++ ){
            var optionContent = options[i];
            var optionChar = String.fromCharCode( charCodeOfA + i );
            optionsHTML += '<li class="' + itemClass + ' common-split-border " data-char="' + optionChar + '">' +
                '<span class="option-char-wrap">' + optionChar + '.</span>' +
                '<div class="option-content">' + optionContent + '</div>' +
                '<span class="option-result-indicator"></span>' +
                '</li>';
        }
        this.optionList.innerHTML = optionsHTML;
    },

    showAnswer : function(){
        //切换为看答案模式
        this.setDisplayMode( ExerciseView.SHOW_ANSWER );

        this.analysisWrap.style.display = 'block';
        var answers = this.answerArray;
        var answerClass = this.OPTION_RIGHT_ANSWER;
        var selectedClass = this.OPTION_SELECTED_CLASS;
        var wrongClass = this.OPTION_WRONG_ANSWER;
        var childs = this.optionList.querySelectorAll('.' + this.OPTION_ITEM_CLASS );
        for( var i = 0, len = childs.length; i < len; i++ ){
            var li = childs[i];
            var char = li.getAttribute('data-char');
            var isAnswer = answers.indexOf( char ) >= 0;
            if( isAnswer ){
                li.classList.add( answerClass );
            }else{
                if( li.classList.contains(selectedClass) ){
                    li.classList.add( wrongClass );
                }
            }
        }
    },
    onItemClick : function(){},
    canSelect : function(){
        return this.displayMode !== ExerciseView.SHOW_ANSWER;
    },
    setDisplayMode : function(mode){
        this.displayMode = mode;
    },
    //是否单选题
    isSingleChoice : function(){
        return this.answerArray.length === 1;
    }
};

//看答案模式，不允许点击选项
ExerciseView.SHOW_ANSWER = 'show_answer';
//做题模式
ExerciseView.DO_EXERCISE = 'do_exercise';