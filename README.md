# Nexum

![language](https://img.shields.io/badge/language-Objective--C-blue.svg)
![license](https://img.shields.io/github/license/vsanthanam/Nexum.svg)
![GitHub release](https://img.shields.io/github/release/vsanthanam/Nexum/all.svg)
[![documentation](https://code.vsanthanam.com/Nexum/Documentation/badge.svg)](https://code.vsanthanam.com/Nexum/Documentation/)

Updated Reachability for iOS Apps in Objective-C, based on Apple's [Reachability](https://developer.apple.com/library/content/samplecode/Reachability/Introduction/Intro.html), along with some other network utilities

## About

Apple appears to have stopped updating their Reachability code. It isn't marked up with nullability for use with Swift projects, it doesn't use ARC, and is generally inflexible. Nexum is a drop-in replacement for Apple's reachability that is still extremely similar and very simple, but designed for easy, drop-in use and more design flexibility. Not everyone wants to use NSNotification all the time :P

## Requirements

Nexum is compiled with the iOS 11.2 SDK, but support iOS 9.x+

## Set Up

Take a look at the [Project Setup guide](https://code.vsanthanam.com/Nexum/Documentation/project-setup.html) for detailed step by step instruction on setting up your project and building the documentation locally.

## Usage

Basic usage is pretty simple:
1. Create and retain a reference to an instance of an `NXNetwork` object, or use the shared instance for basic projects.
2. Observe changes in reachability using `NXNetworkDelegate`,  `NXNetworkReachabilityStatusChangedNotification`, or a block.

See the  [Designing for Reachability](https://code.vsanthanam.com/Nexum/Documentation/designing-for-reachability.html) for a detailed primer on potential different implentations, and see [Example - Basic Reachability](https://code.vsanthanam.com/Nexum/Documentation/example---basic-reachability.html) for a quick start.

## Docs

The full documentaion is available [here](https://code.vsanthanam.com/Nexum/Documentation/), hosted on GitHub Pages, but is also included as an xcode docset.

Documentation with made with [Jazzy](https://github.com/realm/jazzy) by [Realm](https://realm.io), using the [Jony Theme](https://github.com/HarshilShah/Jony) by [Harshil Shah](https://github.com/HarshilShah/)
