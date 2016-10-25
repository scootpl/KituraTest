import PackageDescription

let package = Package(
    name: "KituraTest",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 0),
	.Package(url: "https://github.com/IBM-Swift/HeliumLogger.git", majorVersion: 1, minor: 0),
	.Package(url: "https://github.com/IBM-Swift/Kassandra.git", majorVersion: 0, minor: 2),
	.Package(url: "https://github.com/apple/swift-protobuf.git", Version(0,9,24))
    ]
)
