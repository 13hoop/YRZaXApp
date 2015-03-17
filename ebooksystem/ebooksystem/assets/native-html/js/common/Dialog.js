/**
 * 自定义对话框相关类
 * Created by jess on 15/1/19.
 */



! function( window ){

    'use strict';

    var $ = window.Zepto;

    var EventEmitter = window.EventEmitter;


    var html = '<div class="dialog-wrap dialog-mask">' +
                '<div class="dialog">' +
                    '<div class="dialog-content"></div>' +

                    '<div class="dialog-btns"></div>' +
                '</div>' +
        '</div>';

    function Dialog( args ){
        args = $.extend( {
            showClass : 'dialog-show'
        }, args || {} );
        this.config = args;
        var $el = $( html );
        this.$dialogBody = $el.find('.dialog');
        this.$dialogContent = $el.find('.dialog-content');
        this.$dialogBtnCon = $el.find('.dialog-btns');

        this.$el = $el;

        $el.appendTo( document.body );

        this._setupDOM();

        this._setupEvent();
    }

    $.extend( Dialog.prototype, EventEmitter.prototype );

    $.extend( Dialog.prototype, {

        _setupDOM : function(){},

        _setupEvent : function(){

            this.$dialogBody.on( 'click', function(e){
                e.stopPropagation();
            }, false );

            this.$el.on( 'click', this.maskClick.bind( this ) );
        },

        show : function(){
            this.$el.addClass( this.config.showClass );
            this.trigger('show', [ this ]);
        },
        hide : function(){
            this.$el.removeClass( this.config.showClass );
            this.trigger('hide', [ this ]);
        },
        isVisible : function(){
            return this.$el.hasClass( this.config.showClass );
        },
        setContentHTML : function( html ){
            this.$dialogContent.html( html );
        },
        maskClick : function(e){
            e && e.stopImmediatePropagation();
            this.hide();
        }
    } );


    ///////////////////////  AlertDialog  单例存在  ///////////

    function AlertDialog( args ){

        this.$btnOK = null;

        Dialog.apply( this, arguments );

        this.onOK = this.config.onOK || null;

    }

    $.extend( AlertDialog.prototype, Dialog.prototype );

    $.extend( AlertDialog.prototype, {
        _setupDOM : function(){

            Dialog.prototype._setupDOM.call( this );

            this.$dialogBtnCon.html( '<span class="btn btn-ok">确定</span>');
            this.$btnOK = this.$dialogBtnCon.find('.btn-ok');
        },
        _setupEvent : function(){

            Dialog.prototype._setupEvent.call( this );

            if( this.$btnOK ){
                this.$btnOK.on( 'click', this.ok.bind( this ) );
            }
        },
        ok : function(e){
            e && e.stopImmediatePropagation();
            if( typeof this.onOK === 'function' ){
                this.onOK();
            }
            this.hide();
        },
        setOKText : function(str){
            str = str || '确定';
            this.$btnOK.text( str );
        }
    } );

    var alertDialog;

    /**
     * 显示一个 alert  对话框
     * @param args {JSON}
     * @param args.content {String} 要显示的HTML字符串
     * @returns {boolean}
     */
    Dialog.alert = function( args ){
        if( ! alertDialog ){
            alertDialog = new AlertDialog();
        }
        if( alertDialog.isVisible() ){
            return false;
        }

        alertDialog.setContentHTML( args.content );
        alertDialog.setOKText( args.okText );
        alertDialog.show();
    };


    //////////////////////////////////  ConfirmDialog  单例 ///////
    function ConfirmDialog( args ){

        this.$btnCancel = null;

        AlertDialog.call( this , args );

        this.onCancel = this.config.onCancel || null;


    }

    $.extend( ConfirmDialog.prototype, AlertDialog.prototype );

    $.extend( ConfirmDialog.prototype, {
        _setupDOM : function(){

            AlertDialog.prototype._setupDOM.call( this );

            this.$btnCancel = $('<span class="btn btn-cancel">取消</span>');
            this.$btnOK.before( this.$btnCancel );
        },
        _setupEvent : function(){
            AlertDialog.prototype._setupEvent.call( this );

            this.$btnCancel.on( 'click', this.cancel.bind( this ) );
        },
        cancel : function(e){
            e && e.stopImmediatePropagation();
            if($.isFunction( this.onCancel ) ){
                this.onCancel();
            }
            this.hide();
        },
        maskClick : function(e){
            e && e.stopImmediatePropagation();
            this.cancel();
        },
        setCancelText : function(str){
            str = str || '取消';
            this.$btnCancel.text( str );
        }
    } );

    var confirmDialog;

    Dialog.confirm = function( args ){
        if( ! args ){
            return false;
        }
        if( ! confirmDialog ){
            confirmDialog = new ConfirmDialog({});
        }
        if( confirmDialog.isVisible() ){
            return false;
        }
        confirmDialog.onOK = args.onOK;
        confirmDialog.onCancel = args.onCancel;
        confirmDialog.setContentHTML( args.content );
        confirmDialog.setOKText( args.okText );
        confirmDialog.setCancelText( args.cancelText );
        confirmDialog.show();

        return true;
    };


    /////////////////////////////////////

    window.Dialog = Dialog;


}( window );
