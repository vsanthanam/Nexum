//
//  NexumTests.m
//  NexumTests
//
//  Created by Varun Santhanam on 4/3/18.
//

@import XCTest;
@import Darwin.POSIX.arpa.inet;

#import "NXNetwork.h"

@interface NexumTests : XCTestCase

@end

@implementation NexumTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testConversionUtilsIPv4 {
    
    NSString *original = @"192.0.2.33";
    const struct sockaddr *addr = nx_sockaddr_from_ipv4_nsstring(original);
    NSString *converted = nx_nsstring_from_sockaddr(addr);
    
    XCTAssert([original isEqualToString:converted]);
    
}

- (void)testConversionUtilsIPv6 {
    
    NSString *original = @"2001:db8:8714:3a90::12";
    const struct sockaddr *addr = nx_sockaddr_from_ipv6_nsstring(original);
    NSString *converted = nx_nsstring_from_sockaddr(addr);
    
    XCTAssert([original isEqualToString:converted]);

}

@end
