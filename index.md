---
title: Get Started
homepage: true
description: simple, modern reachability for iOS apps in Objective-C
layout: page
navorder: 0
---
# Setup

Nexum is packaged as a **static framework**. Using the compiled static framework is the recommended setup option, but you can also use CocoaPods, or include the source code directly in your target.

## Static Framework

1. Download the latest stable release [from GitHub](https://github.com/vsanthanam/Nexum/releases). It contains a compiled static framework as well as a copy of the relevent documentation.
2. Add  `Nexum.framework`, and have your target link against the framework during the build process.
3. Reference the library by importing the clang module in relevent files with `@import Nexum;`.

## CocoaPods

<div class="alert alert-info" markdown="1">
 If you haven't already, download & install [Ruby](https://www.ruby-lang.org/en/) and [CocoaPods](https://cocoapods.org) on your machine.
</div>

* If you're project isn't already configured to use CocoaPods, create a podfile & project workpsace by running:

```
$ pod init
```

* Add `pod 'Nexum', '~> 1.0'` to your podfile for the appropriate targets.

* Install the depedency by running:

```
$ pod install
```

* Reference the library in the relevent files with `#import <Nexum/Nexum.h>`.

More information about the pod is available [here](https://cocoapods.org/pods/Nexum).

## Direct Source

1. Clone the repository:

```
$ git clone https://github.com/vsanthanam/Nexum.git
```

2. Add `NXNetwork.h`, `NXNetwork.m`, `NXAddressInfo.h`, and `NXAddressInfo.m` to your project.
3. Reference the library in the relevent files with `#import "VSAlertController.h"`. If you need the address conversion utilities, you'll also need to add `#import "NXAddressInfo.h"`

<div class="alert alert-warning" markdown="1">
**Warning:** Using the version of the code on the master branch isn't always production ready. Use one of the other two installation options for production ready releases.
</div>

Alternatively, you can build the `Framework` target for `Generic iOS Device` if you want to compile the static framework yourself. It's output can be found in `{Repo}/Release/Nexum.framework`.

# Documentation & Examples

/// write some ish here
