# FlickrSlideShowDemo
=====================

Slide show demo of Flickr Public feeds

[![Swift](https://img.shields.io/badge/Swift-4.2-orange.svg)](https://swift.org)
[![MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Features
-----------

* Slide show of [Flickr Public Feeds](https://api.flickr.com/services/feeds/photos_public.gne?tags=landscape,portrait&tagmode=any)
* Provide settings of slide show play time on MainViewController and SlideShowController
* Fetch new feeds when the first slide is displayed and restart the slide show with new feeds after the previous slide show.
* If slide show ends when network is lost, it will try to fetch new feeds when network is connected again, slide show will restart with new feeds.
* Single tap gesture show/hide toolbar, and Double tap gesture zoom in/out a photo.
* Parsing Atom Feed via [FeedKit](https://github.com/nmdias/FeedKit)
* MVVM with [RxSwift](https://github.com/ReactiveX/RxSwift)
* Using [SwiftLint](https://github.com/realm/SwiftLint) via CocoaPods


## Build
--------
1. Download codes and run pod install
```ruby
pod install
```
2. Open FlickrSlideShowDemo.xcworkspace in XCode 10.1 or above

## License
----------
FlickrSlideShowDemo is under MIT license. See the [LICENSE](LICENSE) for more info.
