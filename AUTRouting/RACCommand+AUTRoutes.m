//
//  RACCommand+AUTRoutes.m
//  Automatic
//
//  Created by Eric Horacek on 1/16/17.
//  Copyright © 2017 Automatic Labs. All rights reserved.
//

#import "AUTExtObjC.h"
#import "AUTRoutable.h"

#import "RACCommand+AUTRoutes.h"

NS_ASSUME_NONNULL_BEGIN

@implementation RACCommand (AUTRoutes)

- (nullable AUTRoute *)aut_execute:(nullable id)input whenRoutes:(AUTRoutes *)routes handleRoute:(NSArray<NSString *> *)routeComponents {
    AUTAssertNotNil(routes, routeComponents);
    
    @weakify(self);

    let execute = [[[RACSignal
        defer:^{
            @strongifyOr(self) return [RACSignal empty];
            
            return [self execute:input];
        }]
        // Take just the first presented routable in case the execution signal
        // has a longer lifecycle.
        take:1]
        filter:^(id routable) {
            return [routable conformsToProtocol:@protocol(AUTRoutable)];
        }];

    return [routes addRoute:routeComponents withSignal:execute];
}

@end

NS_ASSUME_NONNULL_END
