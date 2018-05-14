//
//  AUTRoute.h
//  AUTRouting
//
//  Created by Engin Kurutepe on 03/11/15.
//  Copyright © 2015 Automatic Labs. All rights reserved.
//

@import Foundation;
@import ReactiveObjC;

@protocol AUTRoutable;

NS_ASSUME_NONNULL_BEGIN

/// Defines a route and the handler that is invoked when routing occurs.
///
/// A route consists of one or more string path components that are
/// matched against the path components of a URL.
///
/// For example, the route path components to match the URL
/// "custom:/country/state/city/" would be the following array of path
/// components: [ "country", "state", "city" ].
///
/// Route path components may contain tokenized strings that represent a dynamic
/// path component. Dynamic components are denoted by a leading colon, e.g.
/// ":user_id".
///
/// For example, the route [ "user", ":user_id" ] would match the URL
/// "custom:/user/1234/", where "1234" would be the value for the "user_id" key
/// passed into the handler block.
///
/// Routes may also require a context object that contains additional data that
/// is not encoded into the URL as a string. If a context object is required to
/// handle a specific route, it can be specified when building a route. The
/// handler will not be invoked unless a context object of the provided class is
/// present.
@interface AUTRoute : NSObject

- (instancetype)init NS_UNAVAILABLE;

/// Like initWithComponents:handler:, but with a cold signal rather than a
/// block that returns a signal.
- (instancetype)initWithComponents:(NSArray<NSString *> *)components signal:(RACSignal<id<AUTRoutable>> *)signal;

/// Like AUTRouteWithContextHandlerBlock but without a context.
///
/// @see AUTRouteWithContextHandlerBlock
typedef RACSignal<id<AUTRoutable>> * _Nonnull (^AUTRouteWithoutContextHandlerBlock)(NSDictionary<NSString *, NSString *> *, NSURL *url);

/// Like -initWithComponents:contextClass:handler: but without a context object.
///
/// @see -initWithComponents:contextClass:handler:
- (instancetype)initWithComponents:(NSArray<NSString *> *)components handler:(AUTRouteWithoutContextHandlerBlock)handler;

/// Like AUTRouteWithoutContextHandlerBlock, but with a single dynamic token
/// segment instead of a dictionary of parameters.
///
/// @see AUTRouteWithoutContextHandlerBlock
typedef RACSignal<id<AUTRoutable>> * _Nonnull (^AUTRouteWithSingleTokenHandlerBlock)(NSString *, NSURL *url);

/// Initializes a route with the given parameters.
///
/// The pattern provided should not contain any tokens (nothing should be
/// prefixed with ":"). The pattern matcher will match against any patterns that
/// contain the components with a token after it that will be passed into
/// the handler block.
///
/// For example: components of @[ @"identifier" ] would match a url with
/// path components @[ @"identifier", @"1234" ] where @"1234" would be passed
/// into the handler block.
///
/// @param components The route pattern to be matched. An exception is thrown if
///        a zero-element array is provided.
///
/// @param handler block returning a signal which completes when the route has
///        been handled or errors out otherwise
- (instancetype)initWithComponents:(NSArray<NSString *> *)components singleTokenHandler:(AUTRouteWithSingleTokenHandlerBlock)handler;

/// A block used to handle routes, with the parameters:
/// - A dictionary where the keys are the names of the keys found in the token
///   (e.g. for the pattern @[ @"identifier", @":id" ] the key would be @"id")
/// - An optional context object that was provided to the route
/// - The URL that is being routed to.
///
///
/// @return A signal that sends the next routable in the routing chain if there
///         is one, or else completes with no value if routing is compete after
///         this route is handled. If an error occurs during routing, should
///         error.
typedef RACSignal<id<AUTRoutable>> * _Nonnull (^AUTRouteWithContextHandlerBlock)(NSDictionary<NSString *, NSString *> *, id _Nullable, NSURL *url);

/// Initializes a route with the given parameters.
///
/// If a route is matched but the context object's class is not contextClass, a
/// signal sending an error with a domain of AUTRoutingErrorDomain and a code of
/// AUTRoutingErrorCodeWrongContextObjectClass will be used in place of the
/// handler block's return value.
///
/// @param components The route pattern to be matched. An exception is thrown if
///        a zero-element array is provided.
///
/// @param contextClass the class that the context is expected to be. The signal
///        returned in handleComponents:context: will error if the context
///        found for this route is not inherit from this class.
///
/// @param handler block returning a signal which completes when the route has
///        been handled or errors out otherwise
- (instancetype)initWithComponents:(NSArray<NSString *> *)components contextClass:(Class)contextClass handler:(AUTRouteWithContextHandlerBlock)handler;

/// The path components that make up the receiver's route.
///
/// Contains at least one component.
@property (nonatomic, copy, readonly) NSArray<NSString *> *components;

@end

NS_ASSUME_NONNULL_END
