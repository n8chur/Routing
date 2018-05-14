//
//  AUTRoutes.h
//  AUTRouting
//
//  Created by Engin Kurutepe on 29/10/15.
//  Copyright © 2015 Automatic Labs. All rights reserved.
//

@import Foundation;
@import ReactiveObjC;

#import <AUTRouting/AUTRoute.h>

NS_ASSUME_NONNULL_BEGIN

/// A collection of routes representing the paths that an object can handle.
@interface AUTRoutes : NSObject

/// Adds a route without a context object.
///
/// @see The corresponding route initializer: -[AUTRoute initWithComponents:
///      handler:].
///
/// @return The added route, or else nil if the route was already added to the
///         receiver.
- (nullable AUTRoute *)addRoute:(NSArray<NSString *> *)routeComponents withHandler:(AUTRouteWithoutContextHandlerBlock)handler;

/// Like -addRoute:withHandler:, but uses the provided signal instead of a block
/// that generates a signal.
///
/// @see The corresponding route initializer: -[AUTRoute initWithComponents:
///      signal:].
///
/// @return The added route, or else nil if the route was already added to the
///         receiver.
- (nullable AUTRoute *)addRoute:(NSArray<NSString *> *)routeComponents withSignal:(RACSignal<id<AUTRoutable>> *)signal;

/// Adds a "single token" route.
///
/// @see The corresponding route initializer: -[AUTRoute initWithComponents:
///      singleTokenHandler:].
///
/// @return The added route, or else nil if the route was already added to the
///         receiver.
- (nullable AUTRoute *)addRoute:(NSArray<NSString *> *)routeComponents withSingleTokenHandler:(AUTRouteWithSingleTokenHandlerBlock)handler;

/// Adds a route that requires a context object of the given class.
///
/// @see The corresponding route initializer: -[AUTRoute initWithComponents:
///      contextClass:handler:].
///
/// @return The added route, or else nil if the route was already added to the
///         receiver.
- (nullable AUTRoute *)addRoute:(NSArray<NSString *> *)routeComponents withContextClass:(Class)contextClass handler:(AUTRouteWithContextHandlerBlock)handler;

/// The collection of routes that the receiver represents.
@property (readonly, atomic, copy) NSSet<AUTRoute *> *routes;

/// Removes the provided route from the receiver.
- (void)removeRoute:(AUTRoute *)route;

/// Adds the provided route to the receiver.
///
/// @return The added route, or else nil if the route has already been added to
///         the receiver.
- (nullable AUTRoute *)addRoute:(AUTRoute *)route;

@end

NS_ASSUME_NONNULL_END
