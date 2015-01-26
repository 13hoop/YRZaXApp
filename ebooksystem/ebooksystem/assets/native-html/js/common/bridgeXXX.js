/**
 * 作为JS和native通信的中间层，处理好Android和IOS的不同通信方式，都统一以 异步回调  的方式暴露给上层JS
 * Created by jess on 15/1/16.
 */



! function( window ){
    
    window.bridgeXXX = window.bridgeXXX || {};
    
    var bridgeXXX = window.bridgeXXX;

    //常量
    bridgeXXX.constant = {

        //启动某本书的下载成功
        START_DOWNLOAD_SUCCESS : '1',
        //启动某本书的下载失败
        START_DOWNLOAD_FAIL : '0'

    };

    bridgeXXX.getBridge = function(){
        return window.bridgeAndroid || window.bridgeIOS;
    };

    bridgeXXX.isAndroid = function(){
        return !! window.bridgeAndroid;
    };

    bridgeXXX.isIOS = function(){
        return !! window.bridgeIOS;
    };


    /**
     * 调用native接口，获取对应的JSON数据
     * @param args {JSON}
     * @param args.book_id {String}  该数据所在的 书籍ID
     * @param args.query_id {String} 查询该数据需要的 query_id
     * @param callback {Function} 获取数据成功后的回调函数
     */
    bridgeXXX.getData = function( args, callback){

        var bridge = bridgeXXX.getBridge();

        args = JSON.stringify( args );

        if( bridgeXXX.isAndroid() ){
            var data = bridge.getData( args );
            if( typeof callback === 'function'){
                callback( data );
            }
        }else if( bridgeXXX.isIOS() ){
            bridge.getData( args, callback );
        }
    };

    /**
     * 调用native的渲染页面接口
     * @param args {JSON}
     * @param args.target  {String} 'activity' 代表用新的 activity 渲染新页面；'self' 表示在当前webview内渲染
     * @param args.book_id {String} 书籍的id
     * @param args.page_type {String} 页面需要的HTML文件的名字，用 page_type + '.html' 就可以拼出最终要渲染的HTML文件
     * @param args.get_args {String} 新页面的 URL 中的 search 部分参数，需要native拼接到 .html? 后面
     * @param args.post_args {String} 新页面需要的大量数据，可能通过这个参数来传递，一般不会用到
     */
    bridgeXXX.renderPage = function( args ){

        var bridge = bridgeXXX.getBridge();
        args = JSON.stringify( args );
        bridge.renderPage( args );
    };

    //获取当前用户选择的考试类型字符串，“考研”、“教师资格证”等 对应的 值
    bridgeXXX.getCurStudyType = function( callback ){
        var bridge = bridgeXXX.getBridge();
        if( bridgeXXX.isAndroid() ){
            var data = bridge.getCurStudyType();
            if( typeof callback === 'function' ){
                callback( data );
            }
        }else if( bridgeXXX.isIOS() ){
            bridge.getCurStudyType( callback );
        }
    };

    // 设置 当前用户选择的考试类型字符串，“考研”、“教师资格证”等 对应的 值
    bridgeXXX.setCurStudyType = function( type ){
        var bridge = bridgeXXX.getBridge();
        if( bridge ){
            bridge.setCurStudyType( type );
        }
    };

    //根据用户选择的 考试类型，获取当前书包内该类型下所有的书籍列表
    bridgeXXX.getBookList = function( type, callback ){
        var bridge = bridgeXXX.getBridge();
        if( bridgeXXX.isAndroid() ){
            var data = bridge.getBookList( type );
            if( typeof callback === 'function' ){
                callback( data );
            }
        }else if( bridgeXXX.isIOS() ){
            bridge.getBookList( type, callback );
        }
    };

    //检查用户选择的 考试类型 下面的书籍是否有更新
    bridgeXXX.checkUpdate = function( type ){
        var bridge = bridgeXXX.getBridge();
        if( bridge ){
            bridge.checkUpdate( type );
        }
    };

    //下载 bookID 对应的书籍到本地
    bridgeXXX.startDownload = function( bookID, callback ){
        var bridge = bridgeXXX.getBridge();
        if( bridgeXXX.isAndroid() ){
            var data = bridge.startDownload( bookID );
            if( typeof  callback === 'function' ){
                callback( data );
            }
        }else if( bridgeXXX.isIOS() ){
            bridge.startDownload( bookID, callback );
        }
    };

    //批量获取 bookIDArray 中的书籍对应的下载进度信息
    bridgeXXX.queryBookStatus = function( bookIDArray, callback ){
        if( ! bookIDArray || ! utils.isArray( bookIDArray) || bookIDArray.length < 1 ){
            if( typeof  callback === 'function' ){
                callback( [] );
            }
            return;
        }
        var args = JSON.stringify( bookIDArray );
        var bridge = bridgeXXX.getBridge();
        if( bridgeXXX.isAndroid() ){
            var data = bridge.queryBookStatus( args );
            if( typeof callback === 'function' ){
                callback( data );
            }
        }else if( bridgeXXX.isIOS() ){
            bridge.queryBookStatus( args, callback );
        }
    };

    //根据 书籍ID 获取对应的封面图片SRC
    bridgeXXX.getCoverSrc = function( bookID, callback ){
        var bridge = bridgeXXX.getBridge();
        if( bridgeXXX.isAndroid() ){
            var data = bridge.getCoverSrc( bookID );
            if( typeof  callback === 'function' ){
                callback( data );
            }
        }else if( bridgeXXX.isIOS() ){
            bridge.getCoverSrc( bookID, callback );
        }
    };

    //切换到用户设置页面
    bridgeXXX.goUserSettingPage = function(){
        var bridge = bridgeXXX.getBridge();
        if( bridge ){
            bridge.goUserSettingPage();
        }
    };

    //切换到   发现   频道
    bridgeXXX.goDiscoverPage = function(){
        var bridge = bridgeXXX.getBridge();
        if( bridge ){
            bridge.goDiscoverPage();
        }
    };

    /**
     * 获取用户信息
     * @param callback {Function}
     * @return {String}  { user_name : '用户名', avatar_src : '用户头像图片URL', balance : '用户的咋学币余额' }
     */
    bridgeXXX.getUserInfo = function( callback ){
        var bridge = bridgeXXX.getBridge();
        if( bridgeXXX.isAndroid() ){
            var data = bridge.getUserInfo(  );
            if( typeof  callback === 'function' ){
                callback( data );
            }
        }else if( bridgeXXX.isIOS() ){
            bridge.getCoverSrc( callback );
        }
    };

    /**
     * 在 个人中心  页面，点击不同icon，跳转到不同功能页面
     * @param args {JSON}
     * @param args.action {String} APP内不同功能页面的type
     *                             "modify_user_info" -> "修改账户信息"
     *                             "setting" -> "设置"
     *                             "note" -> "笔记"
     *                             "error_list" -> "错题集"
     * @param args.target {String}  activity 代表在 新的 activity  打开
     */
    bridgeXXX.showAppPageByAction = function( args ){
        var bridge = bridgeXXX.getBridge();
        args = JSON.stringify( args );
        bridge.showAppPageByAction( args );
    };

}( window );