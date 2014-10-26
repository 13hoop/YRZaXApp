/**
 * 这个JS，仅仅是为了在开发调试阶段使用，上线的时候，需要删除！！
 * Created by jess on 14-9-16.
 */

console.info( 'debug.js loaded');

var bridgeIOS = window.bridgeIOS || {};


//页面内部错误消息
bridgeIOS.pageError = function( msg ){
    alert( msg );
};

//用户点击页面的 “返回”
bridgeIOS.finish = function(){
    history.back();
};

//通过 parentID 来获取该页面内需要显示的数据
bridgeIOS.getNodeDataByIdAndQueryId = function( args, callback ){
var parentID = args.dataId;
var queryID = args.queryId;
    var searchConf = utils.getSearchConf();

    var out = [
        {
            id : '100',
            query_id : '100', 
            page_id : '100',
            name_ch : '马原',
            name_en : '',
            kaodian_num : '99',
            desc : '书籍描述'
        },
        {
            id : '101',
            query_id : '101', 
            page_id : '101',
            name_ch : '毛特',
            name_en : '',
            kaodian_num : '3',
            desc : '书籍描述'
        },
        {
            id : '102',
            query_id : '102', 
            page_id : '102',
            name_ch : '史纲',
            name_en : '',
            kaodian_num : '76',
            desc : '书籍描述'
        },
        {
            id : '103',
            query_id : '103', 
            page_id : '103',
            name_ch : '思修',
            name_en : '',
            kaodian_num : '23',
            desc : '书籍描述'
        },
        {
            id : '104',
            query_id : '104', 
            page_id : '104',
            name_ch : '当代',
            name_en : '',
            kaodian_num : '10',
            desc : '书籍描述'
        }
    ];

    out = {
        subcolumn_arr : out,
        book_id : searchConf.book_id,
        book_name_ch : searchConf.book_name_ch
    };

    if( typeof callback === 'function' ){
        callback( JSON.stringify( out ) );
    }

    return JSON.stringify( out );
};

//跳转到搜索页面
bridgeIOS.goSearchPage = function(){
    alert('进入搜索页面');
};

//点击了某个子节点ID，进入对应页面
bridgeIOS.showPageById = function( id, args ){
//    alert( '点击了ID： ' + id + ' ; 参数： ' + args );
    var path = '../book_channel_page_1th/index.html?id=' + id + '&' + args + '&debug=1'  ;
    location.href = path;
};

//统计函数
bridgeIOS.pageStatistic = function( eventName, jsonArgsStr ){
    var json = JSON.parse( jsonArgsStr );
    console.info( '点击统计参数: ' + eventName, json );
};