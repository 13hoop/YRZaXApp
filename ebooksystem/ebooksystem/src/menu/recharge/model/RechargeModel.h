//
//  RechargeModel.h
//  ebooksystem
//
//  Created by wanghaoyu on 14-10-8.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol RechargeModelDelegate <NSObject>

-(void)getRechargeMessage:(NSString *)msg;

@end


@interface RechargeModel : NSObject

@property(nonatomic,weak)id<RechargeModelDelegate> recharge_delegate;
-(void)getRecharge:(NSString *)cardID;


@end
