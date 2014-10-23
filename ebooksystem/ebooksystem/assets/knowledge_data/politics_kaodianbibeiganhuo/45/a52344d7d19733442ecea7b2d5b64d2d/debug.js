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
            id : '200',
            page_id : '200',
            name_ch : '马克思主义的含义。马克思主义产生的经济社会根源。',
            name_en : '',
            desc : '书籍描述'
        },
        {
            id : '201',
            page_id : '201',
            name_ch : '马克思主义科学性和革命性的统一',
            name_en : '',
            desc : '书籍描述'
        },
        {
            id : '202',
            page_id : '202',
            name_ch : '可能有一行的情况',
            name_en : '',
            desc : '书籍描述'
        },
        {
            id : '203',
            page_id : '203',
            name_ch : '当然，还有可能多行的情况，现在就来测试下，多行，多行是怎么显示的，要拉明了。。。再加几个字试试呢-估计还不够，再来',
            name_en : '',
            desc : '书籍描述'
        },
        {
            id : '204',
            page_id : '204',
            name_ch : '额，这个再看看两行的情况，是神马个情况呢，显示O不O啦',
            name_en : '',
            desc : '书籍描述'
        }
    ];

    out = out.concat( out );
    out = out.concat( out );

    out = {
        book_id : searchConf.book_id,
        book_name_ch : searchConf.book_name_ch,
        topic_name_ch : searchConf.topic_name_ch,
        subcolumn_arr : out
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
    var path = '../book_detail_page/index.html?id=' + id + '&' + args + '&debug=1' ;
    location.href = path;
};

//统计函数
bridgeIOS.pageStatistic = function( eventName, jsonArgsStr ){
    var json = JSON.parse( jsonArgsStr );
    console.info( '点击统计参数: ' + eventName, json );
};