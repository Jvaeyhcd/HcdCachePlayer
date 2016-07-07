//
//  NSString+MD5.h
//  hcdCachePlayerDemo
//
//  Created by polesapp-hcd on 16/7/4.
//  Copyright © 2016年 Polesapp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HCD)

- (NSString *)stringToMD5;
+ (NSString *)calculateTimeWithTimeFormatter:(long long)timeSecond;

@end
