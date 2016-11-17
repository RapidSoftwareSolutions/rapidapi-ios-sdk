<p align="center">
  <img src="https://storage.googleapis.com/rapid_connect_static/static/github-header.png" width=350 />
</p>

## Overview
RapidAPI is the world's first opensource API marketplace. It allows developers to discover and connect to the world's top APIs more easily and manage multiple API connections in one place.

## iOS SDK
* In case you're using [CocoaPods](https://cocoapods.org), add the following line to your `Podfile`:

  ```ruby
  pod "RapidAPISDK", "~> 0.1"
  ```
  
* Otherwise, you can add RapidAPISDK manually to your Xcode project.
  1. Go to the [releases tab](https://github.com/RapidSoftwareSolutions/rapidapi-ios-sdk/releases).
  2. Download the latest release zip.
  3. Unzip the file and drag the *RapidConnectSDK.framework* directory to the "Frameworks" folder in your project.  

## Initialization
Import RapidAPISDK by putting the following code in your header file

  ```objective-c
  #import <RapidConnectSDK/RapidConnectSDK.h>
  ```
    
Now initialize it using:
    
  ```objective-c
  RapidConnect *rapid = [[RapidConnect alloc] initWithProjectName:@"PROJECT_NAME" andToken:@"TOKEN"];
  ```
## Usage
To use any block in the marketplace, just copy it's code snippet and paste it in your code. For example, the following is the snippet for the **Delivery.sendSMS** block:

  ```objective-c
    [rapid callPackage:@"Delivery" block:@"sendSMS"
        withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                        @"Hello from RapidAPI!",@"message",
                        @"4158496404", @"number",
                        nil]
               success:^(NSDictionary *responseDict) {
               
               // response handling here ...
               NSLog(@"%@",responseDict);
               
    } failure:^(NSError *error) {
        // error handling here ...
        NSLog(@"%@",[error localizedDescription]);
  ```


**Notice** that the `error` event will also be called if you make an invalid block call (for example - the package you refer to does not exist).

## Using Files
Whenever a block in RapidAPI requires a file, you can either pass a URL to the file or a read stream.

#### URL
The following code will call the block MicrosoftComputerVision.analyzeImage with a URL of an image:

  ```objective-c    
    [rapid callPackage:@"MicrosoftComputerVision" block:@"analyzeImage"
        withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                        @"XXXXXXXXXXXXXXXXXXX",@"subscriptionKey",
                        @"http://example.com/file.jpg", @"image",
                        nil]
               success:^(NSDictionary *responseDict) {
        NSLog(@"%@",responseDict);
    } failure:^(NSError *error) {
        // error handling here ...
        NSLog(@"%@",[error localizedDescription]);
  ```

#### Post File
If the file is locally stored, you can read it using `NSFileManager` and pass the read stream to the block, like the following:

  ```objective-c 
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:@"path/to/the/file.jpg"];
    
    [rapid callPackage:@"MicrosoftComputerVision" block:@"analyzeImage"
        withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                        @"XXXXXXXXXXXXXXXXXXX",@"subscriptionKey",
                        data, @"image",
                        nil]
               success:^(NSDictionary *responseDict) {
        NSLog(@"%@",responseDict);
    } failure:^(NSError *error) {
        // error handling here ...
        NSLog(@"%@",[error localizedDescription]);
  ```
        
##Issues:

As this is a pre-release version of the SDK, you may expirience bugs. Please report them in the issues section to let us know. You may use the intercom chat on rapidapi.com for support at any time.

##License:

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
