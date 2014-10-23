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
            title : '子科目章节',
            chapter : '章节名字',
            name_en : '',
            kaodian_num : '99',
            desc : '书籍描述'
        },
        {
            id : '101',
            page_id : '101',
            title : '马原第一张第二节马原第一张第二节马原第一张第二节马原第一张第二节',
            chapter : '章节名字，这里显示该章节的描述文字，看看两行的情况，字数估计还不够，再来点试试，应该差不多了。',
            name_en : '',
            kaodian_num : '3',
            desc : '书籍描述'
        },
        {
            id : '102',
            page_id : '102',
            title : '马原第一张第 3 节',
            chapter : '章节名字，这里显示该章节的描述文字，看了。章节名字，这里显示该章节的描述文字，看了。',
            name_en : '',
            kaodian_num : '76',
            desc : '书籍描述'
        },
        {
            id : '103',
            page_id : '103',
            title : '马原第一张第 4 节',
            chapter : '章节名字，这里显示该章节的描述文字，看看两章节名字，这里显示该章节的描述文字，看看两行的情况，字数估计章节名字，这里显示该章节的描述文字，看看两行的情况，字数估计章节名字，这里显示该章节的描述文字，看看两行的情况，字数估计行的情况，字数估计还不够，再来点试试，应该差不多了。',
            name_en : '',
            kaodian_num : '23',
            desc : '书籍描述'
        },
        {
            id : '104',
            page_id : '104',
            title : '马原第一张第 5 节 马原第一张第 5 节  马原第一张第 5 节 马原第一张第 5 节 马原第一张第 5 节 ',
            chapter : '章节名字，这里显示该章节的描述文字，看看两行的情况，字数估计还不够，再来点试试，应该差不多了。',
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