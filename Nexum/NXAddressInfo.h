//
//  NXAddressInfo.h
//  Nexum
//
//  Created by Varun Santhanam on 3/25/18.
//

@import Foundation;

/**
 NXAddressInfo is a singleton class that lets you get IP address infomation about current connection(s)
 */
@interface NXAddressInfo : NSObject

/**
 @name Shared Instance

/**
 Get the shared address info object

 @return The shared instance
 */
+ (nullable instancetype)sharedAddressInfo;

/**
 @name Get Address Info
 */

/**
 IPv4 WLAN Address
 */
@property (NS_NONATOMIC_IOSONLY, readonly, nullable) NSString *WLANIPv4Address;

@end
