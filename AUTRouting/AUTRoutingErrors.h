//
//  AUTRoutingErrors.h
//  AUTRouting
//
//  Created by Westin Newell on 8/25/16.
//  Copyright © 2016 Automatic Labs. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/// The domain for errors originating within AUTRouting.
extern NSString * const AUTRoutingErrorDomain;

typedef NS_ENUM(NSInteger, AUTRoutingErrorCode) {
    /// The context object does not match the provided contextClass.
    ///
    /// Its user info has the following keys populated:
    /// - AUTRoutingErrorURLKey
    /// - AUTRoutingErrorContextKey
    /// - AUTRoutingErrorRemainingComponentsKey
    AUTRoutingErrorCodeWrongContextObjectClass,
    
    /// No pattern could be found that matches the provided components.
    ///
    /// Its user info has the following keys populated:
    /// - AUTRoutingErrorURLKey
    /// - AUTRoutingErrorContextKey (if a context was provided to routing)
    /// - AUTRoutingErrorRemainingComponentsKey
    AUTRoutingErrorCodeNoMatchFound,

    /// No route path components could be extracted from the given URL.
    ///
    /// Its user info has the following keys populated:
    /// - AUTRoutingErrorURLKey
    AUTRoutingErrorCodeInvalidURL,

    /// Routing could not continue due to a non-routable object being sent in
    /// place of a routable.
    ///
    /// Its user info has the following keys populated:
    /// - AUTRoutingErrorURLKey
    /// - AUTRoutingErrorContextKey (if a context was provided to routing)
    /// - AUTRoutingErrorRemainingComponentsKey
    AUTRoutingErrorCodeNotRoutable,

    /// Routing failed due to a signal returned from a route handler block
    /// sending an error.
    ///
    /// The route handler error that caused the failure is populated as the
    /// underlying error on the error with this code.
    ///
    /// Its user info has the following keys populated:
    /// - AUTRoutingErrorURLKey
    /// - AUTRoutingErrorContextKey (if a context was provided to routing)
    /// - AUTRoutingErrorRemainingComponentsKey
    /// - NSUnderlyingErrorKey
    AUTRoutingErrorCodeRouteHandlerFailed,
};

/// The URL that was being routed to when a routing failure occurred.
extern NSString * const AUTRoutingErrorURLKey;

/// The context object that was being routed to when a routing failure occurred.
extern NSString * const AUTRoutingErrorContextKey;

/// The remaining components of routing to when a routing failure occurred.
extern NSString * const AUTRoutingErrorRemainingComponentsKey;

NS_ASSUME_NONNULL_END
