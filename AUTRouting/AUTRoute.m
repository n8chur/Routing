//
//  AUTRoute.m
//  AUTRouting
//
//  Created by Engin Kurutepe on 03/11/15.
//  Copyright © 2015 Automatic Labs. All rights reserved.
//

@import ReactiveObjC;

#import "AUTExtObjC.h"
#import "AUTRoutingErrors.h"

#import "AUTRoute_Private.h"

NS_ASSUME_NONNULL_BEGIN

static let DynamicPrefix = @":";

@implementation AUTRoute

#pragma mark - Lifecycle

- (instancetype)initWithComponents:(NSArray<NSString *> *)components routeHandler:(AUTRouteHandlerBlock)handler {
    AUTAssertNotNil(components, handler);
    NSAssert([[components componentsJoinedByString:@""] rangeOfString:@"/"].location == NSNotFound, @"Pattern components must contain no slashes");

    self = [super init];

    _components = [components copy];
    _handler = [handler copy];

    return self;
}

- (instancetype)initWithComponents:(NSArray<NSString *> *)components signal:(RACSignal<id<AUTRoutable>> *)signal {
    AUTAssertNotNil(components, signal);

    return [self
        initWithComponents:components
        handler:^(NSDictionary<NSString *, NSString *> *_1, NSURL *_2) {
            return signal;
        }];
}

static let SingleTokenKey = @"single-token";

- (instancetype)initWithComponents:(NSArray<NSString *> *)components singleTokenHandler:(AUTRouteWithSingleTokenHandlerBlock)handler {
    AUTAssertNotNil(components, handler);
    
    AUTRouteWithSingleTokenHandlerBlock copiedHandler = [handler copy];
    
    let tokenPattern = [DynamicPrefix stringByAppendingString:SingleTokenKey];
    let componentsWithToken = [components arrayByAddingObject:tokenPattern];

    return [self
        initWithComponents:componentsWithToken
        routeHandler:^(NSDictionary<NSString *, NSString *> *parameters, id _Nullable context, NSArray<NSString *> *remainingComponents, NSURL *url){
            // We are guaranteed to have a token at this point so there is no
            // need to validate the the token is nonnull.
            let token = parameters[SingleTokenKey];

            let routables = copiedHandler(token, url);

            return [routables combineLatestWith:[RACSignal return:remainingComponents]];
        }];
}

- (instancetype)initWithComponents:(NSArray<NSString *> *)components handler:(AUTRouteWithoutContextHandlerBlock)handler {
    AUTAssertNotNil(components, handler);
    
    AUTRouteWithoutContextHandlerBlock copiedHandler = [handler copy];

    return [self
        initWithComponents:components
        routeHandler:^(NSDictionary<NSString *, NSString *> *parameters, id _Nullable context, NSArray<NSString *> *remainingComponents, NSURL *url){
            let routables = copiedHandler(parameters, url);
            return [routables combineLatestWith:[RACSignal return:remainingComponents]];
        }];
}

- (instancetype)initWithComponents:(NSArray<NSString *> *)components contextClass:(Class)contextClass handler:(AUTRouteWithContextHandlerBlock)handler {
    AUTAssertNotNil(components, contextClass, handler);
    
    AUTRouteWithContextHandlerBlock copiedHandler = [handler copy];

    @weakify(self);
    
    return [self
        initWithComponents:components
        routeHandler:^ RACSignal<RACTwoTuple<id<AUTRoutable>, NSArray<NSString *> *> *> * (NSDictionary<NSString *, NSString *> *parameters, id _Nullable context, NSArray<NSString *> *remainingComponents, NSURL *url){
            if (context == nil || ![context isKindOfClass:contextClass]) {
                let description = [NSString stringWithFormat:@"%@ matched a pattern and expected context object %@ to be a kind of class %@.", self_weak_, context, NSStringFromClass(contextClass)];

                let userInfo = (NSMutableDictionary<NSString *, id> *)[NSMutableDictionary dictionaryWithDictionary:@{
                   NSLocalizedDescriptionKey: description,
                    AUTRoutingErrorRemainingComponentsKey: remainingComponents,
                    AUTRoutingErrorURLKey: url,
                }];

                if (context != nil) {
                    userInfo[AUTRoutingErrorContextKey] = context;
                }

                let error = [NSError errorWithDomain:AUTRoutingErrorDomain code:AUTRoutingErrorCodeWrongContextObjectClass userInfo:userInfo];
                return [RACSignal error:error];
            }
            
            let routables = copiedHandler(parameters, AUTNotNil(context), url);
            
            return [routables combineLatestWith:[RACSignal return:remainingComponents]];
        }];
}

#pragma mark - AUTRoute

- (NSInteger)matchingCountWithComponents:(NSArray<NSString *> *)components {
    AUTAssertNotNil(components);
    NSAssert(components.count > 0, @"Unable to handle zero components, this is programmer error");

    NSInteger matchLength = 0;

    // No match if there's more components than input components
    if (self.components.count > components.count) return 0;

    for (NSUInteger index = 0; index < components.count; index++) {
        if (index == self.components.count) return self.components.count;

        let patternComponent = self.components[index];
        let component = components[index];

        if ([patternComponent isEqualToString:component]) {
            matchLength++;
            continue;
        } else if ([patternComponent hasPrefix:DynamicPrefix]) {
            matchLength++;
            continue;
        } else {
            return matchLength;
        }
    }

    return matchLength;
}

- (RACSignal<RACTwoTuple<id<AUTRoutable>, NSArray<NSString *> *> *> *)handleComponents:(NSArray<NSString *> *)components context:(nullable id)context URL:(NSURL *)url {
    AUTAssertNotNil(components, url);
    NSAssert(components.count > 0, @"Unable to handle zero components, this is programmer error");

    let matchLength = [self matchingCountWithComponents:components];

    NSMutableDictionary<NSString *, NSString *> *parameters = [NSMutableDictionary dictionary];

    for (NSInteger index = 0; index < matchLength; index++) {
        let pattern = self.components[index];

        if ([pattern hasPrefix:DynamicPrefix]) {
            let key = [pattern substringFromIndex:1];
            parameters[key] = components[index];
        }
    }

    let remainingComponents = [components.rac_sequence skip:matchLength].array;

    return self.handler(parameters, context, remainingComponents, url);
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    if (![object isKindOfClass:AUTRoute.class]) return NO;
    return [self.components isEqualToArray:((AUTRoute *)object).components];
}

- (NSUInteger)hash {
    return self.components.hash;
}

@end

NS_ASSUME_NONNULL_END
