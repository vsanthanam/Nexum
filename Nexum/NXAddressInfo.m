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
 
    NSString *address;
    
    struct ifaddrs *interfaces;
    struct ifaddrs *temp;
    
    int Status = 0;
    
    Status = getifaddrs(&interfaces);
    
    if (Status == 0) {
        
        temp = interfaces;
        
        while (temp != NULL) {
            
            if (temp->ifa_addr->sa_family == AF_INET) {
                
                if ([[NSString stringWithUTF8String:temp->ifa_name] isEqualToString:@"en0"]) {
                    
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp->ifa_addr)->sin_addr)];
                    
                }
            }
            
            temp = temp->ifa_next;
            
        }
        
    }
    
    freeifaddrs(interfaces);
    
    if (address == nil || address.length <= 0) {
        
        return nil;
        
    }
    
    return address;
    
}

//NSString * address_for_interface(NSString * interface) {
//    
//    struct ifaddrs *ifa, *ifa_tmp;
//    char addr[50];
//    
//    if (getifaddrs(&ifa) == -1) {
//        
//        perror("getifaddrs failed");
//        
//    }
//    
//    ifa_tmp = ifa;
//    while (ifa_tmp) {
//        
//        if ((ifa_tmp->ifa_addr) && ((ifa_tmp->ifa_addr->sa_family == AF_INET) ||
//                                    (ifa_tmp->ifa_addr->sa_family == AF_INET6))) {
//            if (ifa_tmp->ifa_addr->sa_family == AF_INET) {
//                
//                struct sockaddr_in *in = (struct sockaddr_in*) ifa_tmp->ifa_addr;
//                inet_ntop(AF_INET, &in->sin_addr, addr, sizeof(addr));
//                
//            } else {
//                
//                struct sockaddr_in6 *in6 = (struct sockaddr_in6*) ifa_tmp->ifa_addr;
//                inet_ntop(AF_INET6, &in6->sin6_addr, addr, sizeof(addr));
//            }
//            printf("name = %s\n", ifa_tmp->ifa_name);
//            printf("addr = %s\n", addr);
//        }
//        ifa_tmp = ifa_tmp->ifa_next;
//    }
//    
//    return @"";
//    
//}
//
//- (void)test {
//    
//}

@end
