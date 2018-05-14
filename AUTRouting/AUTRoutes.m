//
//  AUTRoutes.m
//  AUTRouting
//
//  Created by Engin Kurutepe on 29/10/15.
//  Copyright © 2015 Automatic Labs. All rights reserved.
//

#import "AUTExtObjC.h"
#import "AUTRoute_Private.h"
#import "AUTRoutingErrors.h"

#import "AUTRoutes_Private.h"

NS_ASSUME_NONNULL_BEGIN

@implementation AUTRoutes

#pragma mark - Lifecycle

- (instancetype) init {
    self = [super init];

    _routes = [NSMutableSet set];

    return self;
}

#pragma mark - AUTRoutes

#pragma mark Public

- (nullable AUTRoute *)addRoute:(NSArray<NSString *> *)routeComponents withHandler:(AUTRouteWithoutContextHandlerBlock)handler {
    AUTAssertNotNil(routeComponents, handler);

    let route = [[AUTRoute alloc] initWithComponents:routeComponents handler:handler];
    
    return [self addRoute:route];
}

- (nullable AUTRoute *)addRoute:(NSArray<NSString *> *)routeComponents withSignal:(RACSignal<id<AUTRoutable>> *)signal {
    AUTAssertNotNil(routeComponents, signal);
    
    let route = [[AUTRoute alloc] initWithComponents:routeComponents signal:signal];
    
    return [self addRoute:route];
}

- (nullable AUTRoute *)addRoute:(NSArray<NSString *> *)routeComponents withSingleTokenHandler:(AUTRouteWithSingleTokenHandlerBlock)handler {
    AUTAssertNotNil(routeComponents, handler);

    let route = [[AUTRoute alloc] initWithComponents:routeComponents singleTokenHandler:handler];

    return [self addRoute:route];
}

- (nullable AUTRoute *)addRoute:(NSArray<NSString *> *)routeComponents withContextClass:(Class)contextClass handler:(AUTRouteWithContextHandlerBlock)handler {
    AUTAssertNotNil(routeComponents, handler);

    let route = [[AUTRoute alloc] initWithComponents:routeComponents contextClass:contextClass handler:handler];

    return [self addRoute:route];
}

- (void)removeRoute:(AUTRoute *)route {
    AUTAssertNotNil(route);

    @synchronized(self) {
        [self->_routes removeObject:route];
    }
}

- (nullable AUTRoute *)addRoute:(AUTRoute *)route {
    AUTAssertNotNil(route);

    @synchronized(self) {
        if ([self->_routes containsObject:route]) return nil;
        [self->_routes addObject:route];
        return route;
    }
}

- (NSSet<AUTRoute *> *)routes {
    @synchronized(self) {
        return [self->_routes copy];
    }
}

#pragma mark - Private

- (nullable AUTRoute *)matchingRouteForComponents:(NSArray<NSString *> *)components {
    AUTAssertNotNil(components);
    NSAssert(components.count > 0, @"Unable to handle zero components, this is programmer error");

    NSInteger maximumMatchLength = 0;
    AUTRoute *matchingRoute;

    for (AUTRoute *route in self.routes) {
        NSInteger matchLength = [route matchingCountWithComponents:components];

        // Select the route with most specific match, for cases like:
        // `vehicles/:id` vs. `vehicles/:id/timeline`.
        if (matchLength > maximumMatchLength) {
            maximumMatchLength = matchLength;
            matchingRoute = route;
        }
    }

    return matchingRoute;
}

- (BOOL)canHandleComponents:(NSArray<NSString *> *)components {
    AUTAssertNotNil(components);

    return ([self matchingRouteForComponents:components] != nil);
}

- (RACSignal<RACTwoTuple<id<AUTRoutable>, NSArray<NSString *> *> *> *)handleComponents:(NSArray<NSString *> *)components context:(nullable id)context URL:(NSURL *)url {
    AUTAssertNotNil(components, url);
    NSAssert(components.count > 0, @"Unable to handle zero components, this is programmer error");

    return [RACSignal defer:^ RACSignal<RACTwoTuple<id<AUTRoutable>, NSArray<NSString *> *> *> * {
        let route = [self matchingRouteForComponents:components];

        if (route == nil) {
            NSMutableDictionary<NSString *, id> *userInfo = [NSMutableDictionary dictionaryWithDictionary:@{
                NSLocalizedDescriptionKey: @"Routing failed",
                NSLocalizedFailureReasonErrorKey: @"No matching route found",
                AUTRoutingErrorRemainingComponentsKey: components,
                AUTRoutingErrorURLKey: url,
            }];

            if (context != nil) {
                userInfo[AUTRoutingErrorContextKey] = context;
            }

            let error = [NSError errorWithDomain:AUTRoutingErrorDomain code:AUTRoutingErrorCodeNoMatchFound userInfo:userInfo];

            return [RACSignal error:error];
        }

        return [route handleComponents:components context:context URL:url];
    }];
}

@end

NS_ASSUME_NONNULL_END
