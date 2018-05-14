//
//  NSURL+AUTRouting.h
//  AUTRouting
//
//  Created by Eric Horacek on 5/8/17.
//  Copyright © 2017 Automatic Labs. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (AUTRouting)

/// Returns the routable component strings in the receiver.
///
/// If the URL includes a host (e.g. https://automatic.com/app ), the host
/// "automatic.com" will be the first component, and "app" will be the second
/// component.
@property (readonly, nonatomic, copy) NSArray<NSString *> *aut_routingComponents;

/// Returns whether the receiver has at least one routing component.
@property (readonly, nonatomic) BOOL aut_isRoutable;

@end

NS_ASSUME_NONNULL_END
