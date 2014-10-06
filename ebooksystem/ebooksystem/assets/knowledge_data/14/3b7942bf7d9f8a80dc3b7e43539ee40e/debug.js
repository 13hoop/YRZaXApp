/**
 * 这个JS，仅仅是为了在开发调试阶段使用，上线的时候，需要删除！！
 * Created by jess on 14-9-16.
 */

console.info( 'debug.js loaded');

var bridgeAndroid = window.bridgeAndroid || {};


//页面内部错误消息
bridgeAndroid.pageError = function( msg ){
    alert( msg );
};

//用户点击页面的 “返回”
bridgeAndroid.finish = function(){
    history.back();
};

//通过 parentID 来获取该页面内需要显示的数据
bridgeAndroid.getNodeDataById = function( parentID ){

    var out = [
        {
            id : '000',
            page_id : '000',
            update_id : '000-2',
            book_cover : 'dagangxinzengkaodian',
            name_ch : '大纲新增考点',
            is_online : '1',
            name_en : '',
            desc : '书籍描述'
        },
        {
            id : '002',
            page_id : '002',
            update_id : '002-2',
            book_cover : 'fenxitibibeikaodian',
            name_ch : '分析题必备考点xx个',
            is_online : '1',
            name_en : '',
            desc : '书籍描述'
        },
        {
            id : '004',
            page_id : '004',
            update_id : '003-2',
            book_cover : 'kaodianzhongdiannandian',
            name_ch : '考点重点难点900题',
            is_online : '1',
            name_en : '',
            desc : '书籍描述'
        },
        {
            id : '005',
            page_id : '005',
            update_id : '003-2',
            book_cover : 'kaodianbibeiganhuo',
            name_ch : '考点必背干货',
            is_online : '',
            name_en : '',
            desc : '书籍描述'
        },
        {
            id : '001',
            page_id : '000',
            update_id : '000-2',
            book_cover : 'xuanzetinandian',
            name_ch : '选择题难点',
            is_online : '',
            name_en : '',
            desc : '书籍描述'
        },
        {
            id : '003',
            page_id : '003',
            update_id : '003-2',
            book_cover : 'yihunxiaokaodian',
            name_ch : '易混淆考点',
            is_online : '',
            name_en : '',
            desc : '书籍描述'
        }
    ];

    out = {
        book_arr : out
    };

    return JSON.stringify( out );
};

//跳转到搜索页面
bridgeAndroid.goSearchPage = function(){
    alert('进入搜索页面');
};

//点击了某个子节点ID，进入对应页面
bridgeAndroid.showPageById = function( id, args ){
//    alert( '点击了ID： ' + id + ' ; 参数： ' + args );
    var path = '../book_top_page/index.html?id=' + id + '&' + args + '&debug=1' ;
    location.href = path;
};

//统计函数
bridgeAndroid.pageStatistic = function( eventName, jsonArgsStr ){
    var json = JSON.parse( jsonArgsStr );
    console.info( '点击统计参数: ' + eventName, json );
};

//检查一本书是否已经下载到本地了
bridgeAndroid.hasNodeDownloaded = function(id){
    return "1";
};

//尝试下载id对应的节点
bridgeAndroid.tryDownloadNodeById = function( id, nodeName ){
    alert( '准备下载节点： ' + nodeName );
};

//
bridgeAndroid.getDownloadProgress = function(id){
    return '56';
};