//
//  NXNetwork.m
//  Nexum
//
//  Created by Varun Santhanam on 3/20/18.
//

@import CoreFoundation;
@import os.log;
@import Darwin.POSIX.arpa.inet;

#import "NXNetwork.h"

#define log_subsystem   "Nexum"
#define log_category    "NXNetwork"

NSString * const NXNetworkReachabilityStatusChanged = @"kNXNetworkReachabilityStatusChanged";

@implementation NXNetwork {
    
    SCNetworkReachabilityRef _reachability;
    
}

@synthesize delegate = _delegate;
@synthesize reachabilityStatusChangedHandler = _reachabilityStatusChangedHandler;

static os_log_t nx_network_log;

#pragma mark - Overridden Instance Methods

+ (void)initialize {
    
    nx_network_log = os_log_create(log_subsystem, log_category);
    
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

- (NSString *)description {
    
    SCNetworkReachabilityFlags flags;
    
    return [NSString stringWithFormat:@"<%@: %p (%@)>", NSStringFromClass([self class]), self, string_from_flags(SCNetworkReachabilityGetFlags(_reachability, &flags))];
    
}

- (void)dealloc {
    
    [self stopListening];
    
    if (_reachability) {
        
        CFRelease(_reachability);
        _reachability = nil;
        
    }
    
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

- (BOOL)isReachable {
    
    return (self.reachabilityStatus != NXNetworkReachabilityStatusNotReachable);
    
}

- (BOOL)isConnectionRequired {
    
    BOOL rv = NO;
    
    SCNetworkReachabilityFlags flags;
    
    if (SCNetworkReachabilityGetFlags(_reachability, &flags)) {
        
        rv = (flags & kSCNetworkReachabilityFlagsConnectionRequired);
        
    }
    
    return rv;
    
}

- (BOOL)isOnDemand {
 
    BOOL rv = NO;
    
    SCNetworkReachabilityFlags flags;
    
    if (SCNetworkReachabilityGetFlags(_reachability, &flags)) {
        
        rv = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) && (flags & (kSCNetworkReachabilityFlagsConnectionOnTraffic | kSCNetworkReachabilityFlagsConnectionOnDemand)));
        
    }
    
    return rv;
    
}

- (BOOL)isInterventionRequired {
    
    BOOL rv = NO;
    
    SCNetworkReachabilityFlags flags;
    
    if (SCNetworkReachabilityGetFlags(_reachability, &flags)) {
        
        rv = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) && (flags & kSCNetworkReachabilityFlagsInterventionRequired));
        
    }
    
    return rv;
    
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

- (instancetype)initWithLocalAddress:(const struct sockaddr *)localAddress remoteAddress:(const struct sockaddr *)remoteAddress {
    
    self = [super init];
    
    if (self) {
        
        self->_reachability = SCNetworkReachabilityCreateWithAddressPair(kCFAllocatorDefault, localAddress, remoteAddress);
        
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

- (void)stopListening {
    
    SCNetworkReachabilityUnscheduleFromRunLoop(_reachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    
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

static void callback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void * info) {

//#ifdef DEBUG
//    os_log_info(nx_network_log, "%@", string_from_flags(flags));
//#endif
    
    NXNetwork *network = (__bridge NXNetwork *)info;
    [network _reachabilityStatusChanged];
    
}

#pragma mark - Internal C Utils

static NXNetworkReachabilityStatus status_for_flags(SCNetworkReachabilityFlags flags) {
    
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

static NSString * string_from_flags(SCNetworkReachabilityFlags flags) {
    
    return [NSString stringWithFormat:@"Reachability Flag Status: %c%c %c%c%c%c%c%c%c",
            (flags & kSCNetworkReachabilityFlagsIsWWAN)               ? 'W' : '-',
            (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
            
            (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
            (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
            (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
            (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
            (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
            (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
            (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-'];
    
}

#pragma mark - Public C Utils

//const char * nx_string_from_sockaddr(const struct sockaddr *address) {
//
//    char *ipstring = NULL;
//
//    switch (address->sa_family) {
//
//        case AF_INET: {
//
//            NSLog(@"CASE INET");
//            struct sockaddr_in *addr = (struct sockaddr_in *)address;
//            ipstring = malloc(INET_ADDRSTRLEN);
//            inet_ntop(AF_INET, &(addr->sin_addr), ipstring, INET_ADDRSTRLEN);
//            break;
//
//
//        }
//
//        case AF_INET6: {
//
//            NSLog(@"CASE INET6");
//            struct sockaddr_in6 *addr = (struct sockaddr_in6 *)address;
//            ipstring = malloc(INET6_ADDRSTRLEN);
//            inet_ntop(AF_INET6, &(addr->sin6_addr), ipstring, INET6_ADDRSTRLEN);
//            break;
//
//        }
//
//        default:
//            NSLog(@"SOME OTHER CASE");
//            break;
//
//    }
//
//    return ipstring;
//
//}

NSString * nx_nsstring_from_sockaddr(const struct sockaddr *address) {
    
    if (address->sa_family == AF_INET) {
        
        char str[INET_ADDRSTRLEN];
        struct sockaddr_in *addr_in = (struct sockaddr_in *)address;
        inet_ntop(AF_INET, &(addr_in->sin_addr), str, INET_ADDRSTRLEN);
        
        return [NSString stringWithUTF8String:str];
        
    } else if (address->sa_family == AF_INET6) {
        
        char str[INET6_ADDRSTRLEN];
        struct sockaddr_in6 *addr_in = (struct sockaddr_in6 *)address;
        inet_ntop(AF_INET6, &(addr_in->sin6_addr), str, INET6_ADDRSTRLEN);
        
        return [NSString stringWithUTF8String:str];
        
    }
    
    return nil;
    
}

const struct sockaddr * nx_sockaddr_from_ipv4_nsstring(NSString *addressString) {
    
    struct sockaddr_in addr_in;
    inet_pton(AF_INET, [addressString UTF8String], &(addr_in.sin_addr));
    struct sockaddr *addr = (struct sockaddr *)&addr_in;
    addr->sa_family = AF_INET;
    
    return (const struct sockaddr *)addr;
    
}

const struct sockaddr * nx_sockaddr_from_ipv6_nsstring(NSString *addressString) {
    
    struct sockaddr_in6 addr_in;
    inet_pton(AF_INET6, [addressString UTF8String], &(addr_in.sin6_addr));
    struct sockaddr *addr = (struct sockaddr *)&addr_in;
    addr->sa_family = AF_INET6;
    
    return (const struct sockaddr *)addr;
}

@end
