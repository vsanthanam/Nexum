//
//  NXNetwork.h
//  Nexum
//
//  Created by Varun Santhanam on 3/20/18.
//

@import Foundation;
@import SystemConfiguration;
@import Darwin.POSIX.netinet;

/**
 Notification sent when an NXNetwork's reachability status changes
 */
extern NSString * const _Nonnull NXNetworkReachabilityStatusChanged;

/**
 An enumeration describing the various reachability statuses (statii?)

 - NXNetworkReachabilityStatusNotReachable: The network object is not reachable
 - NXNetworkReachabilityStatusReachableOverWiFi: The network object is reachable over WiFi
 - NXNetworkReachabilityStatusReachableOverWWAN: The network object is reachable over WWAN
 */
typedef NS_ENUM(NSInteger, NXNetworkReachabilityStatus) {
    
    /**
     The network object is not reachable
     */
    NXNetworkReachabilityStatusNotReachable = 0,
    
    /**
     The network object is reachable over WiFi
     */
    NXNetworkReachabilityStatusReachableOverWiFi = 1,
    
    /**
     The network object is reachable over WWAN
     */
    NXNetworkReachabilityStatusReachableOverWWAN = 2
    
};

@class NXNetwork;

/**
 The methods of NXNetworkNavigationDelegate protocol help you observe and handle changes to a NXNetwork object's reachability.
 */
@protocol NXNetworkDelegate <NSObject>

/**
 Sent to the delegate when the network object's reachability status changes

 @param network The network object who's reachability has changed
 @param reachabilityStatus The new reachabiltiy status
 */
- (void)network:(nonnull NXNetwork *)network reachabilityStatusChanged:(NXNetworkReachabilityStatus)reachabilityStatus;

@optional

@end

/**
 A block used to handle changes in a network object's reachabiltiy status

 @param network The network object who's reachabiltiy status has changed
 @param reachabilityStatus The new reachability status
 */
typedef void (^NXNetworkReachabilityStatusChangedHandler)(NXNetwork * _Nonnull network, NXNetworkReachabilityStatus reachabilityStatus);

/**
 NXNetwork is a long-use object used to listen to and handle changes in a device's network reachability. You should create an instance of a NXNetwork object and retain a strong reference to it in memory, and react to changes using by observing the `NXNetworkReachabilityStatusChanged` notification, a block you can assign to nexum instance's `reachabilityStatusChangedHandler` property, or an object that conforms to `NXNetworkDelegate` protocol.
 */
@interface NXNetwork : NSObject

/**
 The delegate object to be informed of changes to the network object's reachability status
 */
@property (weak, nullable) id<NXNetworkDelegate> delegate;

/**
 The block to be executed when the network object's reachability status changes
 */
@property (NS_NONATOMIC_IOSONLY, copy, nullable) NXNetworkReachabilityStatusChangedHandler reachabilityStatusChangedHandler;
@property (NS_NONATOMIC_IOSONLY, readonly, getter=isListening) BOOL listening;
@property (NS_NONATOMIC_IOSONLY, readonly) NXNetworkReachabilityStatus reachabilityStatus;

+ (nullable instancetype)sharedNetwork;

+ (nullable instancetype)network;

- (nullable instancetype)initWithHostName:(nonnull NSString *)hostName NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithHostAddress:(nonnull const struct sockaddr *)hostAddress NS_DESIGNATED_INITIALIZER;

- (BOOL)startListening;
- (BOOL)stopListening;

@end
