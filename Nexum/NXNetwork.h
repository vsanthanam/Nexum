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
 @name Access Shared Network
 */

/**
 The generic shared network object. You can use this singleton if you don't want to manage ownership of the network object directly, and you can interact with and observe changes to its reachabilty status via notifications, blocks, its delegate object.

 @return The shared network object
*/
+ (nullable instancetype)sharedNetwork;

/**
 @name Create A Network
 */

/**
 Create a generic network object, observing changes to internet reachability
 
 @return The network object
 */
+ (nullable instancetype)network;

/**
 Create network object that observes changes to the reachability of a single hostname and only that hostname
 
 @param hostName The host name
 @return The network object.
 */
- (nullable instancetype)initWithHostName:(nonnull NSString *)hostName NS_DESIGNATED_INITIALIZER;

/**
 Create network object that observes changes to the reachability of a single IP address and only that IP address
 
 @param hostAddress The IP address
 @return The network object
 */
- (nullable instancetype)initWithHostAddress:(nonnull const struct sockaddr *)hostAddress NS_DESIGNATED_INITIALIZER;

/**
 Create a network object that observes changes to the reachability of an IP Address pair

 @param localAddress The local IP address
 @param remoteAddress The remote IP address
 @return The network object
 */
- (nullable instancetype)initWithLocalAddress:(nonnull const struct sockaddr *)localAddress remoteAddress:(nonnull const struct sockaddr *)remoteAddress NS_DESIGNATED_INITIALIZER;

/**
 @name Responding To Reachability Changes
 */

/**
 The delegate object to be informed of changes to the network object's reachability status
 */
@property (weak, nullable) id<NXNetworkDelegate> delegate;

/**
 The block to be executed when the network object's reachability status changes
 */
@property (NS_NONATOMIC_IOSONLY, copy, nullable) NXNetworkReachabilityStatusChangedHandler reachabilityStatusChangedHandler;

/**
 The 'listening' status of the network object. If the network objet is listening for changes, notifications will be sent, blocks will be executed, and the delegate object will be informed when the network object's reachability status changes.
 */
@property (NS_NONATOMIC_IOSONLY, readonly, getter=isListening) BOOL listening;

/**
 Begin listening to changes in reachability
 
 @return YES if network object began listening, otherwise NO.
 */
- (BOOL)startListening;

/**
 Stop listening to changes in reachability
 
 @return YES if network object stopped listening, otherwose NO.
 */
- (BOOL)stopListening;

/**
 @name Reachability Status
 */

/**
 The current reachability status of the network object
 */
@property (NS_NONATOMIC_IOSONLY, readonly) NXNetworkReachabilityStatus reachabilityStatus;

@end
