//
//  NXAddressInfo.m
//  Nexum
//
//  Created by Varun Santhanam on 3/25/18.
//

@import Darwin.POSIX.ifaddrs;
@import Darwin.POSIX.arpa.inet;

#import "NXAddressInfo.h"

@implementation NXAddressInfo

#pragma mark - Public Class Methods

+ (instancetype)sharedAddressInfo {
    
    static NXAddressInfo *sharedAddressInfo;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    
        sharedAddressInfo = [[self alloc] init];
        
    });
    
    return sharedAddressInfo;
    
}

#pragma mark - Property Access Methods

- (NSString *)WLANIPv4Address {
 
    return [self _IPv4AddressForInterface:@"en0"];
    
}

- (NSString *)WLANIPv6Address {
    
    return [self _IPv6AddressForInterface:@"en0"];
    
}

- (NSString *)WWANIPv4Address {
    
    return [self _IPv4AddressForInterface:@"pdp_ip0"];
    
}

- (NSString *)WWANIPv6Address {
    
    return [self _IPv4AddressForInterface:@"pdp_ip0"];
    
}

#pragma mark - Private Instance Methods

- (NSString *)_IPv4AddressForInterface:(NSString *)interface {
    
    NSString *address;
    
    struct ifaddrs *interfaces;
    struct ifaddrs *temp;
    
    int Status = 0;
    
    Status = getifaddrs(&interfaces);
    
    if (Status == 0) {
        
        temp = interfaces;
        
        while (temp != NULL) {
            
            if (temp->ifa_addr->sa_family == AF_INET) {
                
                if ([[NSString stringWithUTF8String:temp->ifa_name] isEqualToString:interface]) {
                    
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp->ifa_addr)->sin_addr)];
                    
                }
            }
            
            temp = temp->ifa_next;
            
        }
        
    }
    
    freeifaddrs(interfaces);
    
    if (address.length <= 0) {
        
        return nil;
        
    }
    
    return address;
    
}

- (NSString *)_IPv6AddressForInterface:(NSString *)interface {
    
    NSString *address;
    
    struct ifaddrs *interfaces;
    struct ifaddrs *temp;
    
    int status = 0;
    
    status = getifaddrs(&interfaces);
    
    if (status == 0) {
        
        temp = interfaces;
        
        while (temp != NULL) {
            
            if (temp->ifa_addr->sa_family == AF_INET6) {
                
                if ([[NSString stringWithUTF8String:temp->ifa_name] isEqualToString:interface]) {
                    
                    struct sockaddr_in6 *addr6 = (struct sockaddr_in6 *)temp->ifa_addr;
                    char buf[INET6_ADDRSTRLEN];
                    
                    if (inet_ntop(AF_INET6, (void *)&(addr6->sin6_addr), buf, sizeof(buf)) == NULL) {
                        
                        address = nil;
                        
                    } else {
                        
                        address = [NSString stringWithUTF8String:buf];
                        
                    }
                    
                }
                
            }
            
            temp = temp->ifa_next;
            
        }
        
    }
    
    freeifaddrs(interfaces);
    
    if (address.length <= 0) {
        
        return nil;
        
    }
    
    return address;
    
}

@end
