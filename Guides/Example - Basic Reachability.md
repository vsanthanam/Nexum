#  Basic Reachability

You can add reachability to your app with just a few lines of code. This implemementation provides you with minimal control, but will have you up in running in a matter of minutes.

## Observe Notification

First, add the following to your app delegate's  `-application:didFinishLaunchingWithOptions:` method

```

#import "AppDelegate.h"

@import Nexum;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Observe reachability change notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_handleReachabilityChange:)
                                                 name:NXNetworkReachabilityStatusChanged
                                               object:nil];
                                               
    // Listen for reachability changes
    [[NXNetwork sharedNetwork] startListening];

    return YES;

}

```

## Handle Notification

then, you an write a method to handle changes when the notification is fired, like so:

```
- (void)_handleReachabilityChange:(NSNotification *)notif {

    // Don't forget to update the UI on the main thread or you'll be a sad boi

    if ([NXNetwork sharedNetwork].reachabilityStatus == NXNetworkReachabilityStatusNotReachable) {

        NSLog(@"Device has no internet connection. Do Something");

    } else {
    
    
        NSLog(@"Device has an internet connection. Do Something");

    }
    
}
```
This is the easiest way to get Nexum up and running, but if you'd like more control over what reachability changes you are listening for and how they are handled, I recommend instantiating and managing your own instance of NXNetwork rather than using the singleton.

