//
//  NXNetwork.m
//  Nexum
//
//  Created by Varun Santhanam on 3/20/18.
//

@import CoreFoundation;
@import os.log;

#import "NXNetwork.h"

NSString * const NXNetworkReachabilityStatusChanged = @"kNXNetworkReachabilityStatusChanged";

@implementation NXNetwork {
    
    SCNetworkReachabilityRef _reachability;
    
}

@synthesize delegate = _delegate;
@synthesize reachabilityStatusChangedHandler = _reachabilityStatusChangedHandler;

static os_log_t nx_network_log;

#pragma mark - Overridden Instance Methods

+ (void)initialize {
    
    nx_network_log = os_log_create("com.varunsanthanam.Nexum", "NXNetwork");
    
}

#pragma mark - Public Class Methods

+ (instancetype)sharedNetwork {
    
    static NXNetwork *sharedNetwork;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedNetwork = [[self alloc] init];
        
    });
    
    return sharedNetwork;
    
}

+ (instancetype)network {

    return [[self alloc] init];
    
}

#pragma mark - Overridden Instance Methods

- (instancetype)init {
    
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    self = [self initWithHostAddress:(const struct sockaddr *)&zeroAddress];
    
    return self;
    
}

- (void)dealloc {
    
    [self stopListening];
    
}

#pragma mark - Property Access Methods

- (NXNetworkReachabilityStatus)reachabilityStatus {
    
    NXNetworkReachabilityStatus rv = NXNetworkReachabilityStatusNotReachable;
    
    SCNetworkReachabilityFlags flags;
    
    if (SCNetworkReachabilityGetFlags(_reachability, &flags)) {
        
        rv = status_for_flags(flags);
        
    }
    
    return rv;
    
}

- (BOOL)isListening {
 
    return (BOOL)_reachability;
    
}

#pragma mark - Public Instance Methods

- (instancetype)initWithHostName:(NSString *)hostName {
    
    self = [super init];
    
    if (self) {
        
        self->_reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [hostName UTF8String]);
        
    }
    
    return self;
    
}


- (instancetype)initWithHostAddress:(const struct sockaddr *)hostAddress {
    
    self = [super init];
    
    if (self) {
        
        self->_reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, hostAddress);
        
    }
    
    return self;
    
}

- (BOOL)startListening {
    
    BOOL rv = NO;
    
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    
    if (SCNetworkReachabilitySetCallback(_reachability, callback, &context)) {
        
        if (SCNetworkReachabilityScheduleWithRunLoop(_reachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)) {
            
            rv = YES;
            
        }
        
    }
    
    return rv;
    
}

- (BOOL)stopListening {
    
    if (_reachability) {
        
        SCNetworkReachabilityUnscheduleFromRunLoop(_reachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        
        return YES;
        
    }
    
    return NO;
    
}

#pragma mark - Private Instance Methods

- (void)_reachabilityStatusChanged {
 
    [[NSNotificationCenter defaultCenter] postNotificationName:NXNetworkReachabilityStatusChanged object:self];
    
    if ([self.delegate respondsToSelector:@selector(network:reachabilityStatusChanged:)]) {
        
        [self.delegate network:self reachabilityStatusChanged:self.reachabilityStatus];
        
    }
    
    if (self.reachabilityStatusChangedHandler) {
        
        self.reachabilityStatusChangedHandler(self, self.reachabilityStatus);
        
    }
    
}

#pragma mark - C Functions

NXNetworkReachabilityStatus status_for_flags(SCNetworkReachabilityFlags flags) {
    
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
        
        return NXNetworkReachabilityStatusNotReachable;
        
    }
    
    NXNetworkReachabilityStatus rv = NXNetworkReachabilityStatusNotReachable;
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
        
        rv = NXNetworkReachabilityStatusReachableOverWiFi;
        
    }
    
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
        
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
            
            rv = NXNetworkReachabilityStatusReachableOverWiFi;
            
        }
        
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
        
        rv = NXNetworkReachabilityStatusReachableOverWWAN;
        
    }
    
    return rv;
    
}

void log_flags(SCNetworkReachabilityFlags flags, const char *comment) {
    
    NSString *string = [NSString stringWithFormat:@"Reachability Flag Status: %c%c %c%c%c%c%c%c%c %s\n",
                        (flags & kSCNetworkReachabilityFlagsIsWWAN)               ? 'W' : '-',
                        (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
                        
                        (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
                        (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
                        (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
                        (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
                        (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
                        (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
                        (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-',
                        comment];
    
    os_log_info(nx_network_log, "%@", string);
    
}

static void callback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void * info) {
 
    log_flags(flags, "Reachability Callback");
    NXNetwork *network = (__bridge NXNetwork *)info;
    [network _reachabilityStatusChanged];
    
}

@end