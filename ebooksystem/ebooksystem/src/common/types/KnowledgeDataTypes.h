//
//  KnowledgeDataTypes.h
//  ebooksystem
//
//  Created by zhenghao on 10/2/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#ifndef ebooksystem_KnowledgeDataTypes_h
#define ebooksystem_KnowledgeDataTypes_h

// types
// 数据初始化模式
typedef enum {
    KNOWLEDGE_DATA_INIT_MODE_NONE = 0, // 不做初始化
    KNOWLEDGE_DATA_INIT_MODE_ASYNC, // 异步初始化
    KNOWLEDGE_DATA_INIT_MODE_SYNC // 同步初始化
} KnowledgeDataInitMode;

#endif
