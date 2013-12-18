# DAAppsViewController

`DAAppsViewController` is a simple way of displaying apps from the App Store in an aesthetically similar manner. The user is able to view each app's App Store page by launching an instance of `SKStoreProductViewController`. Particularly useful for showing an app developer's other apps.

![Screenshot](https://github.com/danielamitay/DAAppsViewController/raw/master/screenshot.png)

## Installation

- Copy over the `DAAppsViewController` folder to your project folder.
- Add the **StoreKit** framework to your project.
- `#import "DAAppsViewController.h"`

## Usage

Example project included (DAAppsViewControllerExample)

### Displaying apps by a specific developer (useful for "Our other apps")

```objective-c
DAAppsViewController *appsViewController = [[DAAppsViewController alloc] init];
[appsViewController loadAppsWithArtistId:356087517 completionBlock:nil];
[self.navigationController pushViewController:appsViewController animated:YES];
```

### Displaying a predetermined set of apps

By **appId**:
```objective-c
NSArray *appsArray = @[@575647534,@498151501,@482453112,@582790430,@543421080];
DAAppsViewController *appsViewController = [[DAAppsViewController alloc] init];
appsViewController.pageTitle = @"Apps by XXX"; // Optional
[appsViewController loadAppsWithAppIds:appsArray completionBlock:nil];
[self.navigationController pushViewController:appsViewController animated:YES];
```

By **bundleId**:
```objective-c
NSArray *bundlesArray = @[@"com.flexibits.fantastical.iphone",@"com.samvermette.Transit",@"com.tripsyapp.tripsy",@"com.seatgeek.SeatGeek",@"com.bumptechnologies.flock.Release"];
DAAppsViewController *appsViewController = [[DAAppsViewController alloc] init];
[appsViewController loadAppsWithBundleIds:bundlesArray completionBlock:nil];
[self.navigationController pushViewController:appsViewController animated:YES];
```

### Displaying apps for a specific App Store search term

```objective-c
DAAppsViewController *appsViewController = [[DAAppsViewController alloc] init];
[appsViewController loadAppsWithSearchTerm:@"Radio" completionBlock:nil];
[self.navigationController pushViewController:appsViewController animated:YES];
```

## Notes

### Compatibility

iOS5.0+

### Automatic Reference Counting (ARC) support

`DAAppsViewController` was made with ARC enabled by default.

## Contact

- [@danielamitay](http://twitter.com/danielamitay)
- hello@danielamitay.com
- http://www.danielamitay.com

If you use/enjoy `DAAppsViewController`, let me know!

## License

### MIT License

Copyright (c) 2013 Daniel Amitay (http://www.danielamitay.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
