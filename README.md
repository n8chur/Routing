# Routing

Routing uses [ReactiveObjC](http://github.com/ReactiveCocoa/ReactiveObjC) to simplify deeplink handling on iOS. With Routing you can declaratively define relative routes in your view models.

## Usage

### Deeplinking

First we need to create routes that our root view model can handle. This is generally just the host in the case of a *root* view model.
```objective-c
static NSString * const AUTRouteURLScheme = @"app.example.com";

@implementation RootViewModel

- (instancetype)init {
    self = [super init];
    
    _routes = [[AUTRoutes alloc] init];

    @weakify(self);
    
    [_routes addRoute:@[ AUTRouteURLScheme ] withHandler:^ RACSignal<id<AUTRoutable>> * (NSDictionary *_1, NSURL *_2) {
        @strongify(self);
        if (self == nil) return [RACSignal empty];

        // presentChild's execution signal sends a ChildViewModel<AUTRoutable> *.
        // Since it also conforms to AUTRoutable it will have the opportunity 
        // to handle subsequent route paths.
        return [self.presentChild execute:nil];
    }];
    
    _router = [[AUTRouter alloc] initWithRootRoutes:_routes];
    
    /// presentChild is a RACCommand<id, ChildViewModel *> *
    _presentChild = [self createPresentChild];
    
    return self;
}

@end
```

Now we just need to hook up the URL handler in our app delegate:
```objective-c
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<NSString *, id> *)options {
    RootViewModel *rootViewModel = self.rootViewModel;
    if ([url.scheme isEqualToString:AUTRouteURLScheme] && rootViewModel != nil) {
        if (!url.aut_isRoutable) return NO;
        
        [rootViewModel.router.handleURL execute:RACTuplePack(url, nil)];
        return YES;
    }
    
    return NO;
}
```

Now if the application handles a URL where the host matches `AUTRouteURLScheme` ("app.example.com"), the root view model will present the `ChildViewModel`.

We can handle additional path components in `ChildViewModel`:
```objective-c

@interface ChildViewModel<AUTRoutable>
@end

@implementation ChildViewModel

- (instancetype)init {
    self = [super init];
    
    _routes = [[AUTRoutes alloc] init];

    @weakify(self);
    
    [_routes addRoute:@[ @"present_modal" ] withHandler:^ RACSignal<id<AUTRoutable>> * (NSDictionary *_1, NSURL *_2) {
        @strongify(self);
        if (self == nil) return [RACSignal empty];

        return [self.presentModal execute:nil];
    }];

    _presentModal = [self createPresentModal];

    return self;
}

@end
```

In the above example, when the application handles "https://app.example.com/present_modal" the `RootViewModel` will present a `ChildViewModel`, which will then present a `ModalViewModel`.

If we have a URL that requires us to parse an identifier out of a path component (E.g. "https://app.example.com/present_modal/<modal_id>/") we can do the following instead:
```objective-c
[_routes addRoute:@[ @"present_modal" ] withSingleTokenHandler:^ RACSignal<id<AUTRoutable>> * (NSString *modalID, NSURL *url)  {
    @strongify(self);
    if (self == nil) return [RACSignal empty];

    return [self.presentModal execute:modalID];
}];
```

### Push Notification / Application Shortcut Handling

Routing also works great for handling notifications and application shortcuts which need to route a user to a particular view in the application. 

[AUTRouter's handleURL command](AUTRouter/AUTRouter.h) is executed with a `RACTwoTuple<NSURL *, id> *` where the second value is a context object. We coould, for example, pass an object that has been deserialized from a notification payload (we suggest using [AUTUserNotifications](https://github.com/Automatic/AUTUserNotifications)) as a "context" object which will be available in any route handlers registered:
```objective-c
/// An example push notification object.
@interface Notification

- (instancetype)initWithPayload:(NSDictionary *)payload;

/// The URL for our AUTRouter to handle.
///
/// E.g.: exampleapp://app.example.com/notification_handler
@property (readonly, nonatomic) NSURL *URL;

/// The title of the view being linked to which comes from our 
/// notification payload.
@property (readonly, nonatomic) NSString *title;

@end

...

// In our push notification handling callback for our application:
Notification *notification = [[Notification alloc] initWithPayload:@{...}];
[self.router.handleURL execute:RACTuplePack(notification.URL, notification)];

...

// In our ChildViewModel for example:
[routes addRoute:@[ @"notification_handler" ] withContextClass:Notification.class handler:^ RACSignal<NotificationContentViewModel *> * (id _, Notification *notification, NSURL *url) {
    NotificationContentViewModel *viewModel = [[NotificationContentViewModel alloc] initWithNotification:notification];

    return [self.presentNotificationContent execute:viewModel];
}];

```

See the example project in [AUTPresentations](https://github.com/Automatic/AUTPresentations) for more exmaples of how you can use Routing in your application!

### Installing

Routing supports [Carthage](https://github.com/Carthage/Carthage).

To get the project running locally, run:
```bash
$ make bootstrap
```
And open the [project](AUTRouting.xcodeproj).

## Built With

* [ReactiveObjC](https://github.com/ReactiveCocoa/ReactiveObjC) - [Functional Reactive Programming](https://en.wikipedia.org/wiki/Functional_reactive_programming)

## Contributing

Fork the repository and and open a pull request to the master branch.

Please report any issues found on Github in the issues section.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/Automatic/Routing/tags).
