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
bridgeIOS.getNodeDataById = function( parentID, callback ){

    var searchConf = utils.getSearchConf();

    var out = [
        {
            id : '100',
            page_id : '100',
            name_ch : '马原',
            name_en : '',
            kaodian_num : '99',
            desc : '书籍描述'
        },
        {
            id : '101',
            page_id : '101',
            name_ch : '毛特',
            name_en : '',
            kaodian_num : '3',
            desc : '书籍描述'
        },
        {
            id : '102',
            page_id : '102',
            name_ch : '史纲',
            name_en : '',
            kaodian_num : '76',
            desc : '书籍描述'
        },
        {
            id : '103',
            page_id : '103',
            name_ch : '思修',
            name_en : '',
            kaodian_num : '23',
            desc : '书籍描述'
        },
        {
            id : '104',
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
    var path = '../book_detail_page/index.html?id=' + id + '&' + args + '&debug=1'  ;
    location.href = path;
};

//统计函数
bridgeIOS.pageStatistic = function( eventName, jsonArgsStr ){
    var json = JSON.parse( jsonArgsStr );
    console.info( '点击统计参数: ' + eventName, json );
};
//搜索接口
bridgeIOS.searchData = function( query, callback ){
    var out = '[{"id":"8dddf50ffe8c67b2fac8d386d68c82f5","page_id":"107377e7d488fd109f4b4c2e44a3f283","search_index":"210210","title":"12.\u9636\u6bb5\u6027\u90e8\u5206\u8d28\u53d8\u548c\u5c40\u90e8\u6027\u90e8\u5206\u8d28\u53d8\u5c5e\u4e8e\u91cf\u53d8\u8fd8\u662f\u8d28\u53d8\uff1f\u4e3a\u4ec0\u4e48\uff1f","desc":"","mingti_xingshi":"","mingti_jiaodu":"","analysis":"","weike_url":"http:\/\/sdata.zaxue100.com\/kaoyan\/politics\/video\/politics-video\/d3ba82aca44b0ab918b5d0dc035d7407_210210.mp4","exercise_page_id":"","exercise_data_id":"","book_id":"9f89cd04742796be0f82b47aaea8d938","book_name_ch":"\u9009\u62e9\u9898\u96be\u70b9\u5fae\u8bfe","topic_id":"558f72206798a131cfdec7122dab575e","pre_sibling_id":"d4c731f0357bb46172dd462c0cb19682","next_sibling_id":"a0d8abae5624864e372602dece55cc6a"}]';
    if( typeof callback === 'function' ){
        callback( out );
    }
};