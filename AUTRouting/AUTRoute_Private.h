//
//  AUTRoute_Private.h
//  AUTRouting
//
//  Created by Eric Horacek on 11/22/16.
//  Copyright © 2016 Automatic Labs. All rights reserved.
//

#import <AUTRouting/AUTRoute.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUTRoute ()

typedef RACSignal<RACTwoTuple<id<AUTRoutable>, NSArray<NSString *> *> *> * _Nonnull (^AUTRouteHandlerBlock)(NSDictionary<NSString *, NSString *> *, id _Nullable, NSArray<NSString *> *, NSURL *);

- (instancetype)initWithComponents:(NSArray<NSString *> *)components routeHandler:(AUTRouteHandlerBlock)handler NS_DESIGNATED_INITIALIZER;

@property (nonatomic, copy, readonly) AUTRouteHandlerBlock handler;

/// Matches the given components array with the internal route pattern and
/// returns the length of the match. Returns 0 if the handler command is not
/// enabled, or if the internal components are longer than the input components.
///
/// An exception is thrown if a zero-element array is provided.
- (NSInteger)matchingCountWithComponents:(NSArray<NSString *> *)components;

/// Handles the given components.
///
/// @param components The components to handle. An exception is thrown if a
///        zero-element array is provided.
///
/// @param context An optional context object that can be used to assist in
///        routing (e.g. a local notification object).
///
/// @return Sends a tuple where the routable is the next routable that should
///         attempt to handle the remaining components and the array is the
///         remaining components after handling the route. If routing is
///         finished, should complete with no next values. If routing has
///         failed, will error with the cause of the failure.
- (RACSignal<RACTwoTuple<id<AUTRoutable>, NSArray<NSString *> *> *> *)handleComponents:(NSArray<NSString *> *)components context:(nullable id)context URL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
