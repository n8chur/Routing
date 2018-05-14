//
//  AUTRouterSpec.m
//  AUTRouting
//
//  Created by Eric Horacek on 11/22/16.
//  Copyright © 2016 Automatic Labs. All rights reserved.
//

#import <specta/specta.h>
#import <expecta/expecta.h>
#import <AUTRouting/AUTRouting.h>

#import "AUTExtObjC.h"
#import "AUTStubRoutable.h"

SpecBegin(AUTRouter)

__block BOOL success;
__block NSError *error;
__block AUTStubRoutable *routable;
__block AUTRouter *router;

beforeEach(^{
    success = NO;
    error = nil;

    routable = [[AUTStubRoutable alloc] init];
    router = [[AUTRouter alloc] initWithRootRoutes:routable.routes];
});

describe(@"routing to URLs", ^{
    context(@"with a single routable", ^{
        beforeEach(^{
            [routable.routes addRoute:@[ @"state", @"city" ] withSignal:[RACSignal empty]];
            [routable.routes addRoute:@[ @"automatic.com", @"app" ] withSignal:[RACSignal empty]];
        });

        it(@"should handle a URL with a single slash and no host", ^{
            let url = [[NSURL alloc] initWithString:@"custom:/state/city"];
            let tuple = [[router.handleURL execute:RACTuplePack(url, nil)] asynchronousFirstOrDefault:nil success:&success error:&error];
            expect(tuple).to.haveCountOf(2);
            expect(tuple.first).to.equal(url);
            expect(tuple.last).to.beNil();
        });

        it(@"should handle a URL with a double slash and a host", ^{
            let url = [[NSURL alloc] initWithString:@"https://automatic.com/app"];
            let tuple = [[router.handleURL execute:RACTuplePack(url, nil)] asynchronousFirstOrDefault:nil success:&success error:&error];
            expect(tuple).to.haveCountOf(2);
            expect(tuple.first).to.equal(url);
            expect(tuple.last).to.beNil();
        });

        it(@"should error if no match is found for a valid URL", ^{
            let url = [[NSURL alloc] initWithString:@"custom:/state"];

            let tuple = [[router.handleURL execute:RACTuplePack(url, nil)] asynchronousFirstOrDefault:nil success:&success error:&error];

            expect(tuple).to.beNil();

            expect(error.domain).to.equal(AUTRoutingErrorDomain);
            expect(error.code).to.equal(AUTRoutingErrorCodeNoMatchFound);
            expect(error.userInfo[AUTRoutingErrorURLKey]).to.equal(url);
            expect(error.userInfo[AUTRoutingErrorRemainingComponentsKey]).to.equal(@[ @"state" ]);
        });

        it(@"should error if a https URL has no path components", ^{
            let url = [[NSURL alloc] initWithString:@"https://"];

            let tuple = [[router.handleURL execute:RACTuplePack(url, nil)] asynchronousFirstOrDefault:nil success:&success error:&error];

            expect(tuple).to.beNil();

            expect(error.domain).to.equal(AUTRoutingErrorDomain);
            expect(error.code).to.equal(AUTRoutingErrorCodeInvalidURL);
            expect(error.userInfo[AUTRoutingErrorURLKey]).to.equal(url);
        });

        it(@"should error if a custom URI URL has no path components", ^{
            let url = [[NSURL alloc] initWithString:@"custom:/"];

            let tuple = [[router.handleURL execute:RACTuplePack(url, nil)] asynchronousFirstOrDefault:nil success:&success error:&error];

            expect(tuple).to.beNil();

            expect(error.domain).to.equal(AUTRoutingErrorDomain);
            expect(error.code).to.equal(AUTRoutingErrorCodeInvalidURL);
            expect(error.userInfo[AUTRoutingErrorURLKey]).to.equal(url);
        });
    });

    context(@"with a single route that errors", ^{
        __block NSError *routeError;

        beforeEach(^{
            routeError = [NSError errorWithDomain:@"AUTRouterSpec" code:-1 userInfo:nil];

            [routable.routes addRoute:@[ @"state", @"city" ] withSignal:[RACSignal error:routeError]];
        });

        it(@"should error with the correct error", ^{
            let url = [[NSURL alloc] initWithString:@"custom:/state/city"];

            let tuple = [[router.handleURL execute:RACTuplePack(url, nil)] asynchronousFirstOrDefault:nil success:&success error:&error];
            expect(tuple).to.beNil();

            expect(error.domain).to.equal(AUTRoutingErrorDomain);
            expect(error.code).to.equal(AUTRoutingErrorCodeRouteHandlerFailed);
            expect(error.userInfo[NSUnderlyingErrorKey]).to.beIdenticalTo(routeError);
            expect(error.userInfo[AUTRoutingErrorURLKey]).to.equal(url);
            expect(error.userInfo[AUTRoutingErrorRemainingComponentsKey]).to.equal(@[ @"state", @"city" ]);
        });
    });

    context(@"with an unregistered route", ^{
        it(@"should error with the correct error", ^{
            let url = [[NSURL alloc] initWithString:@"custom:/atlantis"];

            let tuple = [[router.handleURL execute:RACTuplePack(url, nil)] asynchronousFirstOrDefault:nil success:&success error:&error];
            expect(tuple).to.beNil();

            expect(error.domain).to.equal(AUTRoutingErrorDomain);
            expect(error.code).to.equal(AUTRoutingErrorCodeNoMatchFound);
            expect(error.userInfo[AUTRoutingErrorURLKey]).to.equal(url);
            expect(error.userInfo[AUTRoutingErrorRemainingComponentsKey]).to.equal(@[ @"atlantis" ]);
        });
    });

    context(@"with a route that requires a context", ^{
        beforeEach(^{
            [routable.routes addRoute:@[ @"context-route" ] withContextClass:NSNumber.class handler:^(NSDictionary<NSString *,NSString *> *dictionary, id _Nullable context, NSURL *url) {
                return [RACSignal empty];
            }];
        });

        context(@"with a context of the correct class", ^{
            it(@"should route", ^{
                let url = [[NSURL alloc] initWithString:@"custom:/context-route"];
                let context = @1;

                let tuple = [[router.handleURL execute:RACTuplePack(url, context)] asynchronousFirstOrDefault:nil success:&success error:&error];
                expect(tuple).to.haveCountOf(2);
                expect(tuple.first).to.equal(url);
                expect(tuple.last).to.equal(context);

                expect(error).to.beNil();
            });
        });

        context(@"with a context of the incorrect class", ^{
            it(@"should error", ^{
                let url = [[NSURL alloc] initWithString:@"custom:/context-route"];
                let context = @"invalid";

                let tuple = [[router.handleURL execute:RACTuplePack(url, context)] asynchronousFirstOrDefault:nil success:&success error:&error];
                expect(tuple).to.beNil();

                expect(error.domain).to.equal(AUTRoutingErrorDomain);
                expect(error.code).to.equal(AUTRoutingErrorCodeWrongContextObjectClass);
                expect(error.userInfo[AUTRoutingErrorURLKey]).to.equal(url);
                expect(error.userInfo[AUTRoutingErrorRemainingComponentsKey]).to.equal(@[]);
                expect(error.userInfo[AUTRoutingErrorContextKey]).to.equal(context);
            });
        });
    });

    context(@"with nested routables", ^{
        it(@"should handle a URL", ^{
            RACSubject<NSString *> *handledTokens = [RACReplaySubject subject];

            RACSignal<id<AUTRoutable>> *routeToCity = [RACSignal defer:^{
                let routable = [[AUTStubRoutable alloc] init];

                [routable.routes addRoute:@[ @"city" ] withSingleTokenHandler:^(NSString *city, NSURL *url) {
                    [handledTokens sendNext:city];
                    return [RACSignal empty];
                }];

                return [RACSignal return:routable];
            }];

            RACSignal<id<AUTRoutable>> *routeToState = [RACSignal defer:^{
                let routable = [[AUTStubRoutable alloc] init];

                [routable.routes addRoute:@[ @"state" ] withSingleTokenHandler:^(NSString *state, NSURL *url) {
                    [handledTokens sendNext:state];
                    return routeToCity;
                }];

                return [RACSignal return:routable];
            }];

            [routable.routes addRoute:@[ @"country" ] withSingleTokenHandler:^(NSString *country, NSURL *url) {
                [handledTokens sendNext:country];
                return routeToState;
            }];

            let url = [[NSURL alloc] initWithString:@"https://country/united-states/state/california/city/san-francisco/"];
            let tuple = [[router.handleURL execute:RACTuplePack(url, nil)] asynchronousFirstOrDefault:nil success:&success error:&error];
            expect(tuple).to.haveCountOf(2);
            expect(tuple.first).to.equal(url);
            expect(tuple.last).to.beNil();

            [handledTokens sendCompleted];
            NSArray<NSString *> *tokens = [[handledTokens collect] asynchronousFirstOrDefault:nil success:&success error:&error];
            expect(tokens).to.equal(@[ @"united-states", @"california", @"san-francisco" ]);
        });
    });
});

SpecEnd
