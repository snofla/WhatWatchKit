# WhatWatchKit

![Build](https://github.com/snofla/WhatWatchKit/actions/workflows/swift.yml/badge.svg)
![SPM](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)


A research project to detect and identify watches using CoreML. It uses two models that I trained over a couple of weeks: 

* `WhetherWatchModel`: an object detection neural network trained on open source data;
* `WhatWatchModel`: a classifier neural network trained on own data;

The why: I don't know. Working with and training neural networks requires very domain-specific knowledge, and since I know a bit about watches, and after having visited the [WWDC24](https://www.instagram.com/p/C8Axv5Us3Mr/), the puzzle pieces fell in the right place.

Useful? Maybe. Entertaining? Sure is. I mean like: 

```bash
xcrun coremlcompiler compile ../WhetherWatch.mlmodel Resources/
xcrun coremlcompiler generate --language Swift ../WhetherWatch.mlmodel Models/
```

For specifics see the section below.

## Requirements

iOS 17 / macOS 14. With Xcode 15.2 the tests do not run on the simulator. They work fine running under macOS.


## Installation

Add the following dependency to your **Package.swift** file:

```swift
.package(url: "https://github.com/snofla/WhatWatchKit.git", from: "1.0.0")
```


## Usage

The package has two namespaces `Whether` and `What`. 

### `Whether` namespace

The `Whether` namespace has functions to detect whether an image has a watch in it, and returns the bounding rectangles of each detected watch.

*Example 1* **`Whether.anyMatches(in:) async throws -> Watches`**

```swift
// Function definition: public static func anyWatches(in image: CGImage) async throws -> Watches

// [...]
let path: URL = "... some path to an image"
let image = if let image = CIImage(contentsOf: path) {
  image
} else {
  throw // some error
}

// Detect watches in image
let result = try await Whether.anyWatches(in: image)
guard result.count > 0 else {
  throw // some error
}

```

Additionally `Whether` has a function to extract a watch's image from the original image. The result can then be submitted to the functions in the `What` namespace.

*Example 2* **`Whether.extractWatch(at:from:) async throws -> CGImage?`**

```swift
// Function definition: public static func extractWatch(at index: Int, from watches: Watches) async throws -> CGImage?

// Detect watches in image
let result = try await Whether.anyWatches(in: image)
guard result.count > 0 else {
  throw // some error
}

for try await watchImage in result {
  // Do something with the returned image
}

```



### `What` namespace

The `What` namespace has functions that return the type of a watch in an image. Like in the `Whether` namespace the functions have overloads that accept either a URL to an image or the image itself. 

The functions return an array of `Category` structs, and is sorted by the confidence of the estimation of the watch's category.

Example 1 **`What.anyWatches(in:) async throws -> Watches`**

```swift
// Function definition: public static func anyWatches(in cImage: CIImage) async throws -> Watches

let image = CIImage(contentsOf: URL(string: "...")!)!
let result = try await Whether.anyWatches(in: image)
if !result.isEmpty {
  
}

let categories = try await What.categoryOfWatch(in: watchImage)
print("The watch is classified as "\(categories.first?.label)")
```



## Models

### WhetherWatchModel

This object detection model is trained on [Open Source](https://creativecommons.org/licenses/by/4.0/) data provided here: [Watches detection Computer Vision Project](https://universe.roboflow.com/nadezhda-jddr9/watches-detection). It seems to be fairly accurate. 
This is what CreateML shows:

<img src="./Documentation/Whether-Training.png" alt="Whether-Training" width="50%" />

Here's the neural network detecting and locating a couple of my watches correctly: 

<img src="./Documentation/Citizens.png" alt="Citizens" width="50%" />

### WhatWatchModel

The image classification neural network is trained on my own data. The accuracy ranges from 60% to 100%, which is expected given that categorizing watches involves some subjectivity: 

| Training                                                     | Validation                                                   |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| <img src="./Documentation/Classifier-Full-Training.png" alt="Classifier-Full-Training" width="80%" /> | <img src="./Documentation/Classifier-Training-Validation.png" alt="Classifier-Training-Validation" width="80%" /> |



CreateML shows:

<img src="./Documentation/Classifier-Training.png" alt="Classifier-Training" width="50%;" />

## License

```text
Copyright (c) 2024 A. H. F. HOOGERVORST

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to
deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
IN THE SOFTWARE.

```

