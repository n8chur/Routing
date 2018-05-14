//
//  AUTRouter.m
//  AUTRouting
//
//  Created by Engin Kurutepe on 23/11/15.
//  Copyright © 2015 Automatic Labs. All rights reserved.
//

#import "NSURL+AUTRouting.h"

#import "AUTExtObjC.h"
#import "AUTRoutes_Private.h"
#import "AUTLog.h"
#import "AUTRoutable.h"
#import "AUTRoutingErrors.h"

#import "AUTRouter.h"

NS_ASSUME_NONNULL_BEGIN

static inline NSString *ComponentsDescription(NSArray<NSString *> *components) {
    return [components componentsJoinedByString:@"/"];
}

static inline NSError *RoutingFailedError(NSString *failureReason, AUTRoutingErrorCode code, NSArray<NSString *> * _Nullable components, id _Nullable context, NSURL *url, NSError * _Nullable underlyingError) {
    AUTCAssertNotNil(failureReason, url);

    let userInfo = (NSMutableDictionary<NSString *, id> *)[NSMutableDictionary dictionaryWithDictionary:@{
        NSLocalizedDescriptionKey: @"Routing failed",
        NSLocalizedFailureReasonErrorKey: failureReason,
        AUTRoutingErrorURLKey: url,
    }];

    if (components != nil) {
        userInfo[AUTRoutingErrorRemainingComponentsKey] = components;
    }

    if (context != nil) {
        userInfo[AUTRoutingErrorContextKey] = context;
    }

    if (underlyingError != nil) {
        userInfo[NSUnderlyingErrorKey] = underlyingError;
    }

    return [NSError errorWithDomain:AUTRoutingErrorDomain code:code userInfo:userInfo];
}

@interface AUTRouter ()

@property (readonly, nonatomic) AUTRoutes *routes;

@end

@implementation AUTRouter

#pragma mark - Lifecycle

- (instancetype)init AUT_UNAVAILABLE_DESIGNATED_INITIALIZER;

- (instancetype)initWithRootRoutes:(AUTRoutes *)routes {
    AUTAssertNotNil(routes);

    self = [super init];

    _routes = routes;
    _handleURL = [self createHandleURLCommand];

    return self;
}

#pragma mark - AUTRouter

- (RACCommand<RACTwoTuple<NSURL *, id> *, RACTwoTuple<NSURL *, id> *> *)createHandleURLCommand {
    @weakify(self);
    
    return [[RACCommand alloc] initWithSignalBlock:^(RACTwoTuple<NSURL *, id> *urlAndContext) {
        @strongifyOr(self) return [RACSignal empty];
        let url = AUTNotNil(urlAndContext.first);
        id context = urlAndContext.second;

        if (!url.aut_isRoutable) {
            AUTLogRoutingError(@"%@ unable to handle route to %@, no components could be extracted", self_weak_, url);

            return [RACSignal error:RoutingFailedError(@"URL is not routable", AUTRoutingErrorCodeInvalidURL, nil, context, url, nil)];
        }

        let components = url.aut_routingComponents;

        return [[[[[self handleComponents:components withRoutes:self.routes context:context URL:url]
            initially:^{
                AUTLogRoutingInfo(@"%@ started routing to %@ (components: %@), context: %@", self_weak_, url, ComponentsDescription(components), context);
            }]
            doCompleted:^{
                AUTLogRoutingInfo(@"%@ finished routing to %@ (components: %@), context: %@", self_weak_, url, ComponentsDescription(components), context);
            }]
            doError:^(NSError *error) {
                AUTLogRoutingError(@"%@ error routing to %@ (components: %@), context: %@, error: %@", self_weak_, url, ComponentsDescription(components), context, error);
            }]
            then:^{
                return [RACSignal return:urlAndContext];
            }];
    }];
}

- (RACSignal *)handleComponents:(NSArray<NSString *> *)components withRoutes:(AUTRoutes *)routes context:(nullable id)context URL:(NSURL *)url {
    AUTAssertNotNil(components, routes, url);
    NSAssert(components.count > 0, @"Unable to handle zero components, this is programmer error");

    @weakify(self);

    return [RACSignal defer:^{
        AUTLogRoutingInfo(@"%@ handling components %@", self, ComponentsDescription(components));

        return [[[[[routes handleComponents:components context:context URL:url]
            take:1]
            catch:^(NSError *underlyingError) {
                AUTLogRoutingError(@"%@ error routing to %@: %@", self_weak_, ComponentsDescription(components), underlyingError);

                // If the error is already a routing error, just forward it.
                if ([underlyingError.domain isEqualToString:AUTRoutingErrorDomain]) return [RACSignal error:underlyingError];

                return [RACSignal error:RoutingFailedError(@"An error occurred", AUTRoutingErrorCodeRouteHandlerFailed, components, context, url, underlyingError)];
            }]
            reduceEach:^(id<AUTRoutable> routable, NSArray<NSString *> *remainingComponents) {
                @strongifyOr(self) return [RACSignal empty];
                AUTCAssertNotNil(routable, remainingComponents);

                // If there are no remaining components, we're done.
                if (remainingComponents.count == 0) return [RACSignal empty];

                if (![routable conformsToProtocol:@protocol(AUTRoutable)]) {
                    AUTLogRoutingError(@"%@ unable to route to %@, %@ does not conform to %@", self_weak_, ComponentsDescription(components), routable.class, NSStringFromProtocol(@protocol(AUTRoutable)));

                    let description = [NSString stringWithFormat:@"%@ is not routable", routable.class];
                    return [RACSignal error:RoutingFailedError(description, AUTRoutingErrorCodeNotRoutable, components, context, url, nil)];
                }
                
                NSMutableArray<NSString *> *handledComponents = [components mutableCopy];
                [handledComponents removeObjectsInArray:remainingComponents];

                AUTLogRoutingInfo(@"%@ routed to %@", self_weak_, ComponentsDescription(handledComponents));
                
                return [self handleComponents:remainingComponents withRoutes:routable.routes context:context URL:url];
            }]
            flatten];
    }];
}

@end

NS_ASSUME_NONNULL_END
