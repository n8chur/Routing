//
//  AUTRouter.h
//  AUTRouting
//
//  Created by Engin Kurutepe on 23/11/15.
//  Copyright © 2015 Automatic Labs. All rights reserved.
//

@import ReactiveObjC;

@class AUTRoutes;

NS_ASSUME_NONNULL_BEGIN

/// Responsible for performing routing operations through a routing tree.
@interface AUTRouter : NSObject

- (instancetype)init NS_UNAVAILABLE;

/// @param routes The root routes in the tree of routes.
- (instancetype)initWithRootRoutes:(AUTRoutes *)routes NS_DESIGNATED_INITIALIZER;

/// When executed with a tuple, where the first is the URL to handle and
/// the second parameter is an optional context object, handles the provided
/// URL.
///
/// If the provided URL has no routable components, errors in the
/// AUTRoutingErrorDomain domain with the AUTRoutingErrorCodeInvalidURL code.
///
/// If a component of the provided URL is not able to be matched against a
/// registered handler block on an AUTRoutes instance, errors in the
/// AUTRoutingErrorDomain domain with the AUTRoutingErrorCodeNoMatchFound code.
///
/// If one of the handler blocks sends a value that does not conform to
/// AUTRoutable, errors in the AUTRoutingErrorDomain domain with the
/// AUTRoutingErrorCodeNotRoutable code.
///
/// If one of the handler blocks errors, errors in the AUTRoutingErrorDomain
/// domain with the AUTRoutingErrorCodeRouteHandlerFailed code, with the error
/// that caused the handler to fail populated as the error's underlying error.
///
/// Its execution signals either error if routing was unsuccessful, or else
/// sends the inputted tuple and completes if successful.
@property (readonly, nonatomic) RACCommand<RACTwoTuple<NSURL *, id> *, RACTwoTuple<NSURL *, id> *> *handleURL;

@end

NS_ASSUME_NONNULL_END
