// swift-tools-version:5.0

//  Created by Denys Telezhkin on 09/06/19.
//  Copyright © 2019 Denys Telezhkin. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import PackageDescription

let package = Package(
    name: "Ariadne",
    platforms: [
        .iOS(.v10),
        .tvOS(.v10),
        .macOS(.v10_12),
        .watchOS(.v3)
    ],
    products: [
        .library(name: "Ariadne", targets: ["Ariadne"])
    ],
    targets: [
         .target(name: "Ariadne"),
         .testTarget(name: "Tests", dependencies: ["Ariadne"])
    ],
    swiftLanguageVersions: [.v5, .v4_2]
)
