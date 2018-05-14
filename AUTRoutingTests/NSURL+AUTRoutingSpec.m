//
//  NSURL+AUTRoutingSpec.m
//  AUTRouting
//
//  Created by Eric Horacek on 5/8/17.
//  Copyright © 2017 Automatic Labs. All rights reserved.
//

#import <specta/specta.h>
#import <expecta/expecta.h>
#import <AUTRouting/AUTRouting.h>

#import "AUTExtObjC.h"

SpecBegin(NSURL_AUTRouting)

it(@"should convert a URL into components with the host included", ^{
    let url = AUTNotNil([NSURL URLWithString:@"https://mobile.automatic.com/vehicles/C_123/timeline/location"]);

    expect(url.aut_routingComponents).to.equal(@[ @"mobile.automatic.com", @"vehicles", @"C_123", @"timeline", @"location" ]);
});

it(@"should indicate that url with no host or components is not routable", ^{
    let url = AUTNotNil([NSURL URLWithString:@"https://"]);

    expect(url.aut_isRoutable).to.beFalsy();
});

it(@"should indicate that url with no host or components is not routable", ^{
    let url = AUTNotNil([NSURL URLWithString:@"comautomaticcore:"]);

    expect(url.aut_isRoutable).to.beFalsy();
});

it(@"should indicate that url with a host is routable", ^{
    let url = AUTNotNil([NSURL URLWithString:@"https://mobile.automatic.com"]);

    expect(url.aut_isRoutable).to.beTruthy();
});

it(@"should indicate that url with path components routable", ^{
    let url = AUTNotNil([NSURL URLWithString:@"comautomaticcore:/vehicles/C_123/timeline/location"]);

    expect(url.aut_isRoutable).to.beTruthy();
});

SpecEnd
