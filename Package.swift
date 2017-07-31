// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "SwiftTcl",
	dependencies: [
		.Package(url: "https://github.com/snoe925/swift-tcl8.6.git", majorVersion: 14)
	]
)

let libSwiftTcl = Product(name: "SwiftTcl", type: .Library(.Dynamic), modules: "SwiftTcl")
products.append(libSwiftTcl)
