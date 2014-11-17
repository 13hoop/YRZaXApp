//
//  MyURLProtocol.h
//  ebooksystem
//
//  Created by zhenghao on 11/17/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface CustomURLProtocol : NSURLProtocol

+ (void) register;
+ (void) injectURL:(NSString*) urlString cookie:(NSString*)cookie;

@end
