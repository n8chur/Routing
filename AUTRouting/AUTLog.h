//
//  AUTLog.h
//  AUTRouting
//
//  Created by Eric Horacek on 11/21/16.
//  Copyright © 2016 Automatic Labs. All rights reserved.
//

@import AUTLogKit;

/// A context for logging events related to routing.
AUTLOGKIT_CONTEXT_DECLARE(AUTLogContextRouting);

#define AUTLogRoutingError(frmt, ...) AUTLogError(AUTLogContextRouting, frmt, ##__VA_ARGS__)
#define AUTLogRoutingInfo(frmt, ...)  AUTLogInfo(AUTLogContextRouting, frmt, ##__VA_ARGS__)
