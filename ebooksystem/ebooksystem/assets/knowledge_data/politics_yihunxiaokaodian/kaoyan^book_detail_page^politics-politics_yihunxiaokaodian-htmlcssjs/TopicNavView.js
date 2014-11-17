/**
 * 渲染知识点详情页顶部的 topic 切换列表
 * Created by jess on 14-9-23.
 */



function TopicNavView(args){
    this.el = document.querySelector(args.el);

    //css class of normal topic item
    this.TOPIC_ITEM_CLASS = 'nav-topic-item';
    //css class of current selected topic item
    this.TOPIC_ITEM_SELECTED = 'nav-topic-item-selected';

    this._setupEvent();

    //点击切换topic的回调
    this.onchange = args.onchange;
}

TopicNavView.prototype = {

    constructor : TopicNavView,

    //渲染所有的topic
    render : function( topicArray ){

        var normalClass = this.TOPIC_ITEM_CLASS;

        var html = '';
        for( var i = 0, len = topicArray.length; i < len; i++ ){
            var obj = topicArray[i];
            html += '<li class="' + normalClass + '" ' + 
                    ' data-query_id="' + obj.query_id + '" ' + 
                    ' data-id="' + obj.id + '">' + obj.name_ch + '</li>';
        }

        this.el.innerHTML = html;
    },

    _setupEvent : function(){
        var that = this;
        this.el.addEventListener( 'touchend', function(e){
            e.preventDefault();
            var target = e.target;
            var normalClass = that.TOPIC_ITEM_CLASS;
            while( target && target != that.el && ! target.classList.contains(normalClass) ){
                target = target.parentNode;
            }
            if( target && target.classList.contains(normalClass) ){
                var queryID = target.getAttribute('data-query_id');
                that.selectById( target.getAttribute('data-id'), queryID, true );
            }
        }, false );
    },

    selectById : function( topicID, queryID, isTrigger ){
        //是否触发change事件，默认FALSE
        isTrigger = isTrigger === true;
        var selectedClass = this.TOPIC_ITEM_SELECTED;
        var target = this.el.querySelector('.' + this.TOPIC_ITEM_CLASS + '[data-query_id="' + queryID + '"]');
        var currentSelect = this.el.querySelector('.' + selectedClass );
        if( ! target || target == currentSelect ){
            return;
        }

        if( isTrigger ){
            var topicName = target.innerText;
            if( typeof this.onchange === 'function' ){
                this.onchange({
                    data_id : topicID,
                    query_id : queryID, 
                    topic_name : topicName
                });
            }
            return;
        }

        if( currentSelect ){
            currentSelect.classList.remove( selectedClass );
        }
        target.classList.add( selectedClass );

    }
};