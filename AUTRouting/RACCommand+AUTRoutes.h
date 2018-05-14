//
//  RACCommand+AUTRoutes.h
//  Automatic
//
//  Created by Eric Horacek on 1/16/17.
//  Copyright © 2017 Automatic Labs. All rights reserved.
//

@import ReactiveObjC;

#import <AUTRouting/AUTRoutes.h>

NS_ASSUME_NONNULL_BEGIN

@interface RACCommand<__contravariant InputType, __covariant ValueType> (AUTRoutes)

/// When the provided route is handled, executes the receiver with the given
/// input value.
///
/// The reciever should be a command that handles the matching route components
/// and then sends the next view model that should attempt to handle the
/// remaining components. If the command's execution signal sends a view model
/// that conforms to AUTRoutable it will be sent the remaining route components
/// to be handled.
- (nullable AUTRoute *)aut_execute:(nullable InputType)input whenRoutes:(AUTRoutes *)routes handleRoute:(NSArray<NSString *> *)routeComponents;

@end

NS_ASSUME_NONNULL_END
