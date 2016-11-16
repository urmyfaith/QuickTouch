//
//  CommandSender.m
//  QuickTouchClient
//
//  Created by TsuiYuenHong on 09/11/2016.
//  Copyright © 2016 TsuiYuenHong. All rights reserved.
//

#import "CommandSender.h"

@implementation CommandSender

+ (instancetype)sharedInstance{
    static CommandSender *sharedInstance = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CommandSender alloc] init];
        sharedInstance.socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:sharedInstance delegateQueue:dispatch_get_main_queue()];
    });
    return sharedInstance ;
}

- (void)sendCommandDict:(NSDictionary *)commandDict{
    NSData *commandData = [NSJSONSerialization dataWithJSONObject:commandDict options:NSJSONWritingPrettyPrinted error:nil];
   [self.socket sendData:commandData toHost:self.host port:self.sendPort withTimeout:1.0 tag:0];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    NSDictionary *macInfos = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
}

- (void)configHostAndPort:(NSArray *)array{
    self.host = array[0];
    self.sendPort = [array[1] intValue];
    self.RecePort = [array[2] intValue];
}

@end
