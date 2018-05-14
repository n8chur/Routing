//
//  AUTRoutes_Private.h
//  AUTRouting
//
//  Created by Eric Horacek on 11/22/16.
//  Copyright © 2016 Automatic Labs. All rights reserved.
//

#import <AUTRouting/AUTRoutes.h>

@class AUTRoute;

NS_ASSUME_NONNULL_BEGIN

@interface AUTRoutes () {
    /// The registered routes.
    ///
    /// Should only be accessed when synchronized on self.
    NSMutableSet<AUTRoute *> *_routes;
}

/// Returns YES if the receiver has a matching route pattern to handle the given
/// route components, NO otherwise. Does not trigger any side effects.
- (BOOL)canHandleComponents:(NSArray<NSString *> *)components;

/// Forwards the given components to the handler for the matching route pattern,
/// else errors if no handler could be found to handle the components.
///
/// @param components The components to handle. An exception is thrown if a
///        zero-element array is provided.
///
/// @param context An optional context object that can be used to assist in
///        routing (e.g. a local notification object).
///
/// @return Sends a tuple where the routable is the next routable that should
///         attempt to handle the remaining components (if this item does not
///         conform to AUTRoutable routing will end and complete successfully),
///         and the array is the remaining components to handle.
- (RACSignal<RACTwoTuple<id<AUTRoutable>, NSArray<NSString *> *> *> *)handleComponents:(NSArray<NSString *> *)components context:(nullable id)context URL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
