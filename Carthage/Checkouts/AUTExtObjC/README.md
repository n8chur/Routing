# Featuring:

## `let` and `var`

Pretend that you're writing Swift (when you're really writing Objective-C):

```objc
let value = @"A constant string, with an inferred type of NSString *";
```

```objc
var value = @"A string that can be reassigned, with an inferred type of NSString *";

value = @"A new value";
```

## `AUTAssertNotNil`

Makes repeated `NSParameterAssert(argument != nil);` boilerplate that much easier :sparkles:.

```objc
AUTAssertNotNil(something, somethingElse, anotherThing);
```

## `AUTNotNil`

Like Swift's `!`, but in Objective-C:

```objc
- (void)doSomethingWith:(nonnull id)argument;

@property (nullable) id property;

// ...

[self doSomethingWith:AUTNotNil(self.property)];
```

## `AUTFallback`

Like Swift's `??`, but in Objective-C:

```objc
- (void)doSomethingWith:(nonnull id)argument;

@property (nullable) id property;

// ...

[self doSomethingWith:AUTFallback(self.property, @"fallback")];
```

## `AUTStrongifyOr`

Same as `@strongify(...)`, but with an escape hatch if strongification fails.

```objc
@strongifyOr(self) return [RACSignal empty];
```

## `AUT_UNAVAILABLE_DESIGNATED_INITIALIZER`

Reduces boilerplate when opting out of designated initializers.

### `Header.h`
```objc
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
```

### `Implementation.m`
```objc
- (instancetype)initWithCoder:(NSCoder *)aDecoder AUT_UNAVAILABLE_DESIGNATED_INITIALIZER;
```

## `AUTLocalizationNotNeeded()`

Tells the clang analyzer that a string does not need localization if the
CLANG_ANALYZER_LOCALIZABILITY_NONLOCALIZED build setting is on.

```objc
label.text = AUTLocalizationNotNeeded(@"Secret Developer Menu");
```
