//
//  AUTRoutesSpec.m
//  AUTRouting
//
//  Created by Engin Kurutepe on 03/11/15.
//  Copyright © 2015 Automatic Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <ReactiveObjC/ReactiveObjC.h>

#import "AUTExtObjC.h"
#import "AUTStubRoutable.h"

#import <AUTRouting/AUTRouting.h>
#import <AUTRouting/AUTRoutes_Private.h>

SpecBegin(AUTRoutes)

__block BOOL success;
__block NSError *error;
__block AUTRoutes *routes;
__block AUTStubRoutable *routable;
__block AUTRouteWithoutContextHandlerBlock emptyHandler;

describe(@"AUTRoutes", ^{
    beforeEach(^{
        success = NO;
        error = nil;

        routes = [[AUTRoutes alloc] init];
        routable = [[AUTStubRoutable alloc] init];

        emptyHandler = ^(NSDictionary *parameters, NSURL *url) {
            return [RACSignal empty];
        };
    });

    describe(@"adding routes", ^{
        it(@"should correctly add routes", ^{
            expect(routes.routes).to.haveCountOf(0);

            let route1 = [routes addRoute:@[ @"road", @"to", @":city" ] withHandler:emptyHandler];
            expect(routes.routes).to.haveCountOf(1);
            expect(routes.routes).to.contain(route1);

            let route2 = [routes addRoute:@[ @"road" ] withHandler:emptyHandler];
            expect(routes.routes).to.haveCountOf(2);
            expect(routes.routes).to.contain(route2);

            let route3 = [routes addRoute:@[ @"user", @":user_id" ] withHandler:emptyHandler];
            expect(routes.routes).to.haveCountOf(3);
            expect(routes.routes).to.contain(route3);
        });

        it(@"should not allow identical routes", ^{
            expect(routes.routes).to.haveCountOf(0);

            let route1 = [routes addRoute:@[ @"road", @"to", @":city" ] withHandler:emptyHandler];
            expect(routes.routes).to.haveCountOf(1);
            expect(routes.routes).to.contain(route1);

            let route2 = [routes addRoute:@[ @"road", @"to", @":city" ] withHandler:emptyHandler];
            expect(routes.routes).to.haveCountOf(1);
            expect(route2).to.beNil();
        });
    });

    describe(@"route removal", ^{
        it(@"should remove a previously added route", ^{
            expect(routes.routes).to.haveCountOf(0);

            let route = [routes addRoute:@[ @"road", @"to", @":city" ] withHandler:emptyHandler];
            expect(routes.routes).to.haveCountOf(1);
            expect(routes.routes).to.contain(route);

            [routes removeRoute:route];

            expect(routes.routes).to.haveCountOf(0);
        });

        it(@"should disregard routes that were never added", ^{
            expect(routes.routes).to.haveCountOf(0);

            let route = [[AUTRoute alloc] initWithComponents:@[ @"road", @"to", @":city" ] handler:emptyHandler];
            [routes removeRoute:route];

            expect(routes.routes).to.haveCountOf(0);
        });
    });

    it(@"should report if it can handle the given components", ^{
        [routes addRoute:@[ @"road" ] withHandler:emptyHandler];

        expect([routes canHandleComponents:@[@"road"]]).to.beTruthy();
        expect([routes canHandleComponents:@[@"location"]]).to.beFalsy();
    });

    describe(@"route handling", ^{
        describe(@"route selection", ^{
            let longRoute = @[ @"road", @"to", @":city" ];
            let shortRoute = @[ @"road" ];
            let differentRoute = @[ @"user", @":user_id" ];

            __block RACSubject<NSArray<NSString *> *> *handledRoute;
            __block RACSubject<NSDictionary<NSString *, NSString *> *> *handledParameters;

            beforeEach(^{
                handledRoute = [RACReplaySubject subject];
                handledParameters = [RACReplaySubject subject];

                [routes addRoute:longRoute withHandler:^(NSDictionary<NSString *, NSString *> *parameters, NSURL *url) {
                    [handledRoute sendNext:longRoute];
                    [handledParameters sendNext:parameters];
                    return [RACSignal empty];
                }];

                [routes addRoute:shortRoute withHandler:^(NSDictionary<NSString *, NSString *> *parameters, NSURL *url) {
                    [handledRoute sendNext:shortRoute];
                    [handledParameters sendNext:parameters];
                    return [RACSignal empty];
                }];

                [routes addRoute:differentRoute withHandler:^(NSDictionary<NSString *, NSString *> *parameters, NSURL *url) {
                    [handledRoute sendNext:differentRoute];
                    [handledParameters sendNext:parameters];
                    return [RACSignal empty];
                }];
            });

            it(@"should select the longest matching route", ^{
                let url = [NSURL URLWithString:@"https://road/to/berlin"];
                success = [[routes handleComponents:url.aut_routingComponents context:nil URL:url] asynchronouslyWaitUntilCompleted:&error];
                expect(success).to.beTruthy();
                expect(error).to.beNil();

                [handledRoute sendCompleted];
                let selectedRoute = [handledRoute asynchronousFirstOrDefault:nil success:&success error:&error];
                expect(selectedRoute).to.equal(longRoute);
                expect(success).to.beTruthy();
                expect(error).to.beNil();

                [handledParameters sendCompleted];
                let selectedParameters = [handledParameters asynchronousFirstOrDefault:nil success:&success error:&error];
                expect(selectedParameters).to.haveCountOf(1);
                expect(selectedParameters[@"city"]).to.equal(@"berlin");
            });

            it(@"should not select a matching route longer than the given components", ^{
                let url = [NSURL URLWithString:@"https://road"];
                success = [[routes handleComponents:url.aut_routingComponents context:nil URL:url] asynchronouslyWaitUntilCompleted:&error];
                expect(success).to.beTruthy();
                expect(error).to.beNil();

                [handledRoute sendCompleted];
                let selectedRoute = [handledRoute asynchronousFirstOrDefault:nil success:&success error:&error];
                expect(selectedRoute).to.equal(shortRoute);
                expect(success).to.beTruthy();
                expect(error).to.beNil();

                [handledParameters sendCompleted];
                let selectedParameters = [handledParameters asynchronousFirstOrDefault:nil success:&success error:&error];
                expect(selectedParameters).to.haveCountOf(0);
            });
        });

        context(@"with a single token handler", ^{
            __block RACSubject<NSString *> *handledParameter;

            beforeEach(^{
                handledParameter = [RACReplaySubject subject];

                [routes addRoute:@[ @"city" ] withSingleTokenHandler:^(NSString *parameter, NSURL *url) {
                    [handledParameter sendNext:parameter];
                    return [RACSignal empty];
                }];
            });

            it(@"should select the longest matching route", ^{
                let url = [NSURL URLWithString:@"https://city/berlin"];
                success = [[routes handleComponents:url.aut_routingComponents context:nil URL:url] asynchronouslyWaitUntilCompleted:&error];
                expect(success).to.beTruthy();
                expect(error).to.beNil();

                [handledParameter sendCompleted];
                let selectedParameter = [handledParameter asynchronousFirstOrDefault:nil success:&success error:&error];
                expect(selectedParameter).to.equal(@"berlin");
            });
        });

        context(@"with a signal", ^{
            beforeEach(^{
                [routes addRoute:@[ @"city" ] withSignal:[RACSignal return:routable]];
            });

            it(@"should receive the routable", ^{
                let url = [NSURL URLWithString:@"https://city"];
                let componentsAndRoutable = [[routes handleComponents:url.aut_routingComponents context:nil URL:url] asynchronousFirstOrDefault:nil success:&success error:&error];
                expect(componentsAndRoutable).to.haveCountOf(2);
                expect(componentsAndRoutable.first).to.beIdenticalTo(routable);
                expect(componentsAndRoutable.last).to.haveCountOf(0);
                expect(success).to.beTruthy();
                expect(error).to.beNil();
            });
        });

        context(@"with remaining components", ^{
            beforeEach(^{
                [routes addRoute:@[ @"city" ] withSignal:[RACSignal return:routable]];
            });

            it(@"should send the remaining components", ^{
                let url = [NSURL URLWithString:@"https://city/road/number"];
                let componentsAndRoutable = [[routes handleComponents:url.aut_routingComponents context:nil URL:url] asynchronousFirstOrDefault:nil success:&success error:&error];
                expect(componentsAndRoutable).to.haveCountOf(2);
                expect(componentsAndRoutable.first).to.beIdenticalTo(routable);
                expect(componentsAndRoutable.last).to.equal(@[ @"road", @"number" ]);
                expect(success).to.beTruthy();
                expect(error).to.beNil();
            });
        });

        context(@"with a context class", ^{
            __block RACSubject<NSNumber *> *handledContext;

            beforeEach(^{
                handledContext = [RACReplaySubject subject];

                [routes addRoute:@[ @"road" ] withContextClass:NSNumber.class handler:^(NSDictionary *parameters, NSNumber *context, NSURL *url) {
                    [handledContext sendNext:context];
                    return [RACSignal empty];
                }];
            });

            it(@"should succeed when the context object's class matches", ^{
                let url = [NSURL URLWithString:@"https://road"];
                let context = @1;
                success = [[routes handleComponents:url.aut_routingComponents context:context URL:url] asynchronouslyWaitUntilCompleted:&error];
                expect(success).to.beTruthy();
                expect(error).to.beNil();

                let selectedContext = [handledContext asynchronousFirstOrDefault:nil success:&success error:&error];
                expect(selectedContext).to.equal(context);
                expect(success).to.beTruthy();
                expect(error).to.beNil();
            });

            it(@"should fail when the context object's class does not match", ^{
                let url = [NSURL URLWithString:@"https://road"];
                let context = @"1";
                success = [[routes handleComponents:url.aut_routingComponents context:context URL:url] asynchronouslyWaitUntilCompleted:&error];
                expect(success).to.beFalsy();
                expect(error).notTo.beNil();
                expect(error.domain).to.equal(AUTRoutingErrorDomain);
                expect(error.code).to.equal(AUTRoutingErrorCodeWrongContextObjectClass);

                [handledContext sendCompleted];
                let selectedContext = [handledContext asynchronousFirstOrDefault:nil success:&success error:&error];
                expect(selectedContext).to.beNil();
                expect(success).to.beTruthy();
            });
            
            it(@"should fail when the context object is nil", ^{
                let url = [NSURL URLWithString:@"https://road"];
                success = [[routes handleComponents:url.aut_routingComponents context:nil URL:url] asynchronouslyWaitUntilCompleted:&error];
                expect(success).to.beFalsy();
                expect(error).notTo.beNil();
                expect(error.domain).to.equal(AUTRoutingErrorDomain);
                expect(error.code).to.equal(AUTRoutingErrorCodeWrongContextObjectClass);
                
                [handledContext sendCompleted];
                let selectedContext = [handledContext asynchronousFirstOrDefault:nil success:&success error:&error];
                expect(selectedContext).to.beNil();
                expect(success).to.beTruthy();
            });
        });
    });
});

SpecEnd
