/**
 * 这个JS，仅仅是为了在开发调试阶段使用，上线的时候，需要删除！！
 * Created by jess on 14-9-16.
 */

!function(){

console.info( 'debug.js loaded');

window.bridgeIOS = window.bridgeIOS || {};

var bridgeIOS = window.bridgeIOS;


//页面内部错误消息
bridgeIOS.pageError = function( msg ){
    alert( msg );
};

//用户点击页面的 “返回”
bridgeIOS.finish = function(){
    history.back();
};

//通过 parentID 来获取该页面内需要显示的数据
bridgeIOS.getNodeDataByIdAndQueryId = function( args,  callback ){
var parentID = args.dataId;
var queryID = args.queryId;
    var out = [
        {
            id : '000',
            query_id : '000', 
            page_id : '000',
            update_id : '000-2',
            book_cover : 'dagangxinzengkaodian',
            name_ch : '大纲新增考点',
            sub_name : 'sub name ',
            is_online : '1',
            name_en : '',
            desc : '书籍描述',
            file_size : '10'
        },
        {
            id : '002',
            query_id : '002', 
            page_id : '002',
            update_id : '002-2',
            book_cover : 'fenxitibibeikaodian',
            name_ch : '分析题必备考点xx个',
            sub_name : '激烈的萨芬三大类附件撒旦机锋网就范德萨发撒啊发松岛枫和是',
            is_online : '1',
            name_en : '',
            desc : '书籍描述',
            file_size : '3.5'
        },
        {
            id : '004',
            query_id : '004', 
            page_id : '004',
            update_id : '003-2',
            book_cover : 'kaodianzhongdiannandian',
            name_ch : '考点重点难点900题',
            sub_name : 'fdsfsankh l;h osdfh ohf;sdhfowe ffasdfu sadfshfh ',
            is_online : '1',
            name_en : '',
            desc : '书籍描述',
            file_size : '1.5'
        },
        {
            id : '005',
            query_id : '005', 
            page_id : '005',
            update_id : '003-2',
            book_cover : 'kaodianbibeiganhuo',
            name_ch : '考点必背干货',
            sub_name : '跟<strong>石磊老师</strong>学干活',
            is_online : '',
            name_en : '',
            desc : '书籍描述',
            file_size : '1.3'
        },
        {
            id : '001',
            query_id : '001', 
            page_id : '000',
            update_id : '000-2',
            book_cover : 'xuanzetinandian',
            name_ch : '选择题难点',
            sub_name : '',
            is_online : '',
            name_en : '',
            desc : '书籍描述',
            file_size : '5.6'
        },
        {
            id : '003',
            query_id : '003', 
            page_id : '003',
            update_id : '003-2',
            book_cover : 'yihunxiaokaodian',
            name_ch : '易混淆考点',
            sub_name : '',
            is_online : '',
            name_en : '',
            desc : '书籍描述',
            file_size : '8'
        },
        {
            id : '006',
            query_id : '006',
            page_id : '006',
            update_id : '006-2',
            book_cover : 'shizheng100ti',
            name_ch : '时政100题',
            sub_name : '',
            is_online : '0',
            name_en : '',
            desc : '书籍描述',
            file_size : '8'
        }
    ];

    out = {
        book_arr : out
    };

    if( typeof callback === 'function'){
        callback( JSON.stringify( out ) );
    }

    return JSON.stringify( out );
};

//跳转到搜索页面
bridgeIOS.goSearchPage = function(){
    alert('进入搜索页面');
};

//点击了某个子节点ID，进入对应页面
bridgeIOS.showPageById = function( id, args, postArgs ){
    if( id === '08713289f9a7eb4edf10e80b44fe3c1b'){
        var path = '../book_search_result_page/index.html?debug=1';
        location.href = path;
        return;
    }
//    alert( '点击了ID： ' + id + ' ; 参数： ' + args );
    var path = '../book_top_page/index.html?id=' + id + '&' + args + '&debug=1' ;
    location.href = path;
};

//统计函数
bridgeIOS.pageStatistic = function( eventName, jsonArgsStr ){
    var json = JSON.parse( jsonArgsStr );
    console.info( '点击统计参数: ' + eventName, json );
};

//检查一本书是否已经下载到本地了
bridgeIOS.hasNodeDownloaded = function(id){
    return "1";
};

//尝试下载id对应的节点
bridgeIOS.tryDownloadNodeById = function( id, nodeName ){
    alert( '准备下载节点： ' + nodeName );
};

//
bridgeIOS.getDownloadProgress = function(id){
    return '56';
};

//
bridgeIOS.getAnalyzeProgress = function(id){
    return '100';
};

bridgeIOS.getBookStatus = function(id){
    return '3';
};

bridgeIOS.getNetworkType = function(){
    return '4';
};

bridgeIOS.isUserLogin = function(){
    return '1';
};

bridgeIOS.isUserLogin = function(){
    return '1';
};

bridgeIOS.toast = function(msg, time){};

bridgeIOS.goLoginPage = function(){};

bridgeIOS.getBookArrayStatus = function( idArrayStr, callback ){
    var idArray = idArrayStr.split('##');
    var out = {};
    idArray.forEach( function(id){
        out[id] = '0';
    });

    if( typeof callback === 'function' ){
        callback( JSON.stringify(out) );
    }

    return out;
};
    bridgeIOS.showMenu = function(){
        alert('点击 菜单 按钮');
    };

}();
