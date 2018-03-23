#  Designing For Reachability

## Who, What, and When?

Reachability allows your app to observe changes ina device's network connection status and handle them appropriately. This is the best way to handle a broken inernet connection proactively in apps that rely on an internet connection to work correctly, rather than having the user attempt a connection which might fail. Depending on the reason for the failure, that connection could add a few seconds of loading to your app. Using reachability allows you to abstract the process of connection state management away from the part of your code base that is making and handling network requests. Nexum uses a single class, an `NXNetwork`, which is used to monitor the reachability of a given host. Each `NXNetwork` can be used for monitor the reachability of a single host only, and can inform your app of changes to the device's ability to reach that host in a number of ways: delegation, a block, and a notification. NXNetwork objects are long-lasting -- you must maintain a reference to the object in memory if you want it to continue observing reachability changes.

To design around rechability, you've got to make some decisions early on.

### What are you monitoring?
If your app requires a general connection to the internet, you might just want to listen to all reachability changes. Reachability can change frequently as your user roams from WLAN to WWAN connections, and you're gonna want to be able to handle those changes appropriately incase the user loses connection alltogether. You might also want to adjust your apps behavior when its on a WWAN connection (those connections are often slower and users are pickier about their data use.)

If your app relies a lot on a specific host, say `https://api.myapp.com`, you'll probably want to monitor your ability to reach this host as well. You can do this in addition to general internet monitoring (if you don't have an internet connection, you won't have this host either).

### Listening vs. Querying
You may also not need to listen to changes on every host. `NXNetwork` objects have a `listening` state which, when enabled, will cause blocks to be executed, delegates to be informed, and notifications to be sent upon reachability changes. However, even  `NXNetwork` objects that are not actively `listening` to their reachability status are still up-to-date. You can query their `reachabilityStatus` at any time and expect and accurate response

### Informing Your Objects
Depending on the complexity of your reachability needs and the design of your app. you may want to use one or more `NXNetwork` objects to monitor reachability. Each `NXNetwork` object can inform your app via the  `NXNetworkDelegate` protocol, an assignable block, or a notification. You'll need to decide which object(s) are responsbile for handleing these respones. You could have your objects communicate with `NXNetwork` directly, or you could write a wrapper class that handles all the changes internally and informs the rest of your app as necessry. The latter approach is recommended if you plan on using more than one `NXNetwork` object, as you'll find that some responses will be fired twice and may need to be collapsed. `NXNetwork` objects don't talk to each other, and you'll want to write functionality to do that if you're simultaneously monitoring two hosts.

## Using The Shared Network

For the most basic implementation, Nexum is built to get you up and running right away. All you've got to do subscribe to the `NXNetworkReachabilityStatusChanged` to handle general changes to the internet connection, and instantiate the shared instance and tell it to start listening by calling:

```
[[NXNetwork sharedNetwork] startListening];
```

Then, you can write methods that are called when the notification is sent, and query the current device reachabiltiy status by checking the status of `[NXNetwork sharedNetwork].reachabilityStatus` and behaving accordingly. This is the simplest way to get your app to react to internet connection changes. See the [Example - Basic Reachability guide](https://vsanthanam.github.io/Nexum/Documentation/example---basic-reachability.html) for more information.

The shared instance monitors internet reachability, but cannot be used to monitor the reachability of a specific host. If you need more granular control, you might want to create and manage your own `NXNetwork` objects instead.

##  Delegation

Depending on how your app is structured and which object owns your instance of `NXNetwork`, you might want to handle changes to reachability using `NXNetworkDelegate`

This might be ideal if:

1. You want your handling of reachability changes to change a lot during runtime. For example, you could re-assign an `NXNetwork`'s `.delegate` property to whatever view controller is currently visible.
2. Only one delegate object is handling reachability changes at any given time for a given `NXNetwork` object at any given time. (I.e., one `NXNetwork` isn't being used to inform multiple objects. Rather the delegate object handles that)
3. You have multiple `NXNetwork` objects which might have similar handling. (i.e. you're checking reachaiblity for multiple hosts concurrently)

> NOTE: Using delegation with the shared instance is not recommended

In this example, a single NXNetwork object is controlled by the AppDelegate, and every view controller that becomes visible become's its delegate.

*AppDelegate.h*
```

@import UIKit;
@import Nexum;

@interface AppDelegate : NSObject<UIApplicationDelegate>

@property (nonatomic, strong, nullable) NXNetwork *network;

@end

```
*AppDelegate.m*

```

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)dictionary {

    self.network = [NXNetwork network]; // Creates a general reachability to monitor changes in internet connection
    [self.network startListening]; // Start listening for changes in reachability

    return YES;

}

@end

```

Then, in every view controller, you might do the following:

```
#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()<NXNetworkDelegate>

@end

@implementation ViewControlller

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    // Assign network's delegate to this vc
    AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
    ad.network.delegate = self;

}

- (void)viewDidDisappear:(BOOL)animated {

    [super viewDidDisappear:animated];

    // Remove this vc as the network's delegate
    AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
    ad.network.delegate = nil;

}

#pragma mark - NXNetworkDelegate

- (void)network:(NXNetwork *)network reachabilityStatusChanged:(NXNetworkReachabilityStatus)reachabilityStatus {

    // handle changes in reachability. If necessary, you could compare the value in 'network' for pointer equivelency with your app delegate's own network object, incase you've got other nxnetwork objects who have also been assigned this view controller as their delegate.

}

@end
```

Alternatively, delegation might make sense if you've got multiple `NXNetwork` objects that all require similar but slightly different handling. You could assign all your `NXNetwork` object to use the same delegate, and have the delegate method evaluate the identity off the `NXNetwork` object befor deciding how to proceed.

## Block

If reachability is supposed to be a small, self-contained part of your app's experience, using a block can help contain your implementation into just a single class and a few lines of code.

This might be ideal if:

1. Reachability is part of only a single class or view controller and isn't a permeating feature of your app (say, to monitor a single `WKWebView` or something)
2. Reachability monitoring is temporary, and not something you expect to happen during the entire life-cycle of your app. Most of your app doesn't need reachability monitoring.
3. In addition to long-standing reachability monitoring, you need to temporarily monitor an additional host and you want this implementation to be distinct and separate from your other, global reachability system.
4. Each instance of `NXNetwork` has its own, totally unique behavior upon reachability change and you don't want to deal with delegation or notifications, whigh might require you to verify **which** network made the change.

> NOTE: Using change blocks with the shared instance is not recommended

Using a change block is pretty simple -- just remember to assign the block to the network object before you start listening for reachability changes, like so:

```

@import Nexum;

#import ViewController.h

@interface ViewController ()

@property (nonatomic, strong) NXNetwork *network;

@end

@implementation ViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    
    self.network = [NXNetwork network];
    self.network.reachabilityStatusChangedHandler = ^(NXNetwork *network, NXNetworkReachabilityStatus reachabilityStatus) {
    
        // do something with updated reachability status
    
    }
    
    [self.network startListening];

}

@end

```

## Notifications

Notifications are the most flexible way to handle reachability changes, and work as a great complement to delegation and blocks if needed. While blocks are only executed if they are assigned, and delegates are only informed if they exist, an `NXNetwork` object **always** sends a notification when its reachability status changes.

This might be ideal if:

1. You want multiple ways to monitor reachability changes and want to categorize different behavior (i.e. you could update parts of your app in the delegate but do UI updates via notifications)
2. You want to inform dozens of objects which might come and go from memory, and you don't want to wrap your reachability implemention in its own class or classes.

This approach is just as straight forward as it sounds. Any `NXNetwork` object will fire a notification when its reachability status changes, including the general purpose shared instance. To see which `NXNetwork` instance sent the notification, check the notification's `.object` property:

```
- (void)handleChange:(NSNotification *)notif {

    NXNetwork *network = (NXNetwork *)notif.object;
    
    // handle network.reachabilityStatus here

}

```


