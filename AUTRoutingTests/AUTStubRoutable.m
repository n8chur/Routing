//
//  AUTStubRoutable.m
//  AUTRouting
//
//  Created by Eric Horacek on 11/22/16.
//  Copyright © 2016 Automatic Labs. All rights reserved.
//

#import "AUTStubRoutable.h"

NS_ASSUME_NONNULL_BEGIN

@implementation AUTStubRoutable

- (instancetype)init {
    self = [super init];

    _routes = [[AUTRoutes alloc] init];

    return self;
}

@synthesize routes = _routes;

@end

NS_ASSUME_NONNULL_END
