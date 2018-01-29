//
//  AppDelegate.swift
//  swift-protobuf-bench-app
//
//  Created by Daniel Alm on 28.01.18.
//  Copyright © 2018 Daniel Alm. All rights reserved.
//

import Cocoa
import SwiftProtobuf

func bench<T>(_ message: String, block: () -> T) -> T {
	let start = CACurrentMediaTime()
	defer { print("\(message): \(CACurrentMediaTime() - start) s") }
	return block()
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet weak var window: NSWindow!

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		let sampleData = try! Data(contentsOf: URL(fileURLWithPath: "sample_data2.pb"))
		
		let container = try! Container(serializedData: sampleData)
		bench("serialize without wrapper") { try! container.serializedData() }
		
		let wrappedData = bench("serialize with wrapper") { () -> Data in
			var wrapper = Wrapper1()
			wrapper.container = container
			return try! wrapper.serializedData()
		}
		
		bench("serialize with fast wrapper") {
			var fastWrapper = Wrapper1_Fast()
			fastWrapper.container = try! container.serializedData()
			try! fastWrapper.serializedData()
		}
		
		bench("deserialize wrapped") { try! Wrapper1(serializedData: wrappedData) }
		
		exit(0)
	}

	func applicationWillTerminate(_ aNotification: Notification) { }
}
