/**
 * 渲染顶部的当前知识点简要文字及前后知识点切换
 * Created by jess on 14-9-23.
 */


function KnowledgeIndicator(args){

    this.el = document.querySelector(args.el);
    this.titleEl = null;
    this.previousArrow = null;
    this.nextArrow = null;

    this.onchange = args.onchange;

    //当前知识点
    this.currentObj = null;

    this._setupDOM();
    this._setupEvent();
}

KnowledgeIndicator.prototype = {

    constructor : KnowledgeIndicator,

    _setupDOM : function(){

        this.titleEl = this.el.querySelector('.current-knowledge-indicator');
        this.previousArrow = this.el.querySelector('.knowledge-switch-pre');
        this.nextArrow = this.el.querySelector('.knowledge-switch-next');
    },

    _setupEvent : function(){
        var that = this;
        this.el.addEventListener( 'touchend', function(e){
            e.preventDefault();
            var target = e.target;
            var switchBtnClass = 'knowledge-switch-btn';
            while( target && target != that.el && ! target.classList.contains(switchBtnClass) ){
                target = target.parentNode;
            }
            if( target && target.classList.contains(switchBtnClass) ){
                var action = target.getAttribute('data-action');
                that.switchBtnClick( action );
            }
        }, false );
    },

    render : function( obj ){
        if( ! obj ){
            return;
        }
        this.currentObj = obj;
        this.titleEl.innerHTML = obj.topic_name_ch + ' ' + obj.title + '<br />' + obj.kaodian_num + '. ' + obj.kaodian_name;
        if( obj.pre_sibling_id ){
            this.previousArrow.style.visibility = 'visible';
        }else{
            this.previousArrow.style.visibility = 'hidden';
        }
        if( obj.next_sibling_id ){
            this.nextArrow.style.visibility = 'visible';
        }else{
            this.nextArrow.style.visibility = 'hidden';
        }
    },

    switchBtnClick : function( direction ){
        if( ! this.currentObj ){
            return;
        }
        var newID = direction === 'next' ? this.currentObj.next_sibling_id : this.currentObj.pre_sibling_id;
        if( newID ){
            if( typeof this.onchange === 'function' ){
                this.onchange( newID, direction );
            }
        }
    }
};
