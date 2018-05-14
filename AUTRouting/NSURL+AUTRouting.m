//
//  NSURL+AUTRouting.m
//  AUTRouting
//
//  Created by Eric Horacek on 5/8/17.
//  Copyright © 2017 Automatic Labs. All rights reserved.
//

#import "AUTExtObjC.h"

#import "NSURL+AUTRouting.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSURL (AUTRouting)

- (NSArray<NSString *> *)aut_routingComponents {
    let host = self.host;
    var pathComponents = self.pathComponents;

    if (pathComponents.count == 0) {
        return (host != nil) ? @[ host ] : @[];
    }

    if ([pathComponents[0] isEqualToString:@"/"]) {
        pathComponents = [pathComponents subarrayWithRange:NSMakeRange(1, pathComponents.count - 1)];
    }

    if (host != nil) {
        pathComponents = [@[ host ] arrayByAddingObjectsFromArray:pathComponents];
    }

    return pathComponents;
}

- (BOOL)aut_isRoutable {
    return self.aut_routingComponents.count > 0;
}

@end

NS_ASSUME_NONNULL_END
