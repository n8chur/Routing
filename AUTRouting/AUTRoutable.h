//
//  AUTRoutable.h
//  AUTRouting
//
//  Created by Engin Kurutepe on 29/10/15.
//  Copyright © 2015 Automatic Labs. All rights reserved.
//

@import Foundation;

@class AUTRoutes;

NS_ASSUME_NONNULL_BEGIN

/// Describes an object that can participate in routing by declaring the set of
/// routes that it can handle.
///
/// In a view model based application, each of the view models that could be
/// routed to would implement this protocol.
@protocol AUTRoutable <NSObject>

/// The routes that the receiver can handle.
@property (readonly, nonatomic) AUTRoutes *routes;

@end

NS_ASSUME_NONNULL_END
