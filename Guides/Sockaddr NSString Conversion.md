#  Converting Between NSString and sockaddr

## Create sockaddr from NSString (IPv4)
```
// NSString containing IPv4 Address
NSString *stringaddr = @"192.168.0.1";

// Convert
struct sockaddr *address = nx_sockaddr_from_ipv4_nsstring(stringaddr);
```

## Create sockaddr from NSString (IPv4)
```
// NSString containing IPv6 Address
NSString *stringaddr = @"2001:db8:8714:3a90::12";

// Convert
struct sockaddr *address = nx_sockaddr_from_ipv6_nsstring(stringaddr);
```

## Get NSString from sockaddr (IPv4 or IPv6)
```
// sockaddr(s) containing an IPv4 and an IPv6 adddress, respectively
struct sockaddr *ipv4 = nx_sockaddr_from_ipv4_nsstring(@"192.168.0.1");
struct sockaddr *ipb6 = nx_sockaddr_from_ipv6_nsstring(@"2001:db8:8714:3a90::12");

// Convert
NSString *ipv4string = nx_nsstring_from_sockaddr(ipv4);
NSString *ipv6string = nx_nsstring_from_sockaddr(ipv6);
```

