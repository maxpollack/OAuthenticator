// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "OAuthenticator",
	platforms: [
		.macOS(.v10_15),
		.macCatalyst(.v13),
		.iOS(.v13),
		.tvOS(.v13),
		.watchOS(.v7),
		.visionOS(.v1),
	],
	products: [
		.library(name: "OAuthenticator", targets: ["OAuthenticator"]),
		.library(name: "OAuthenticatorUI", targets: ["OAuthenticatorUI"]),
	],
	dependencies: [
	],
	targets: [
		.target(
			name: "OAuthenticator",
			dependencies: [],
			resources: [.process("PrivacyInfo.xcprivacy")]
		),
		.target(name: "OAuthenticatorUI", dependencies: ["OAuthenticator"]),
		.testTarget(name: "OAuthenticatorTests", dependencies: ["OAuthenticator"]),
	]
)
