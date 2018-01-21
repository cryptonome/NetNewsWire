//
//  InspectorWindowController.swift
//  Evergreen
//
//  Created by Brent Simmons on 1/20/18.
//  Copyright © 2018 Ranchero Software. All rights reserved.
//

import AppKit

protocol Inspector: class {

	var objects: [Any]? { get set }
	var isFallbackInspector: Bool { get } // Can handle nothing-to-inspect or unexpected type of objects.

	func canInspect(_ objects: [Any]) -> Bool

	func willEndInspectingObjects() // Called on the current inspector right before objects is about to change.
}

final class InspectorWindowController: NSWindowController {

	private var inspectors: [Inspector]!

	private var currentInspector: Inspector! {
		didSet {
			if let oldInspector = oldValue {
				oldInspector.willEndInspectingObjects()
			}
			currentInspector.objects = objects
			for inspector in inspectors {
				if inspector !== currentInspector {
					inspector.objects = nil
				}
			}
			show(currentInspector)
		}
	}

	var objects: [Any]? {
		didSet {
			currentInspector = inspector(for: objects)
		}
	}

	var isOpen: Bool {
		get {
			return isWindowLoaded && window!.isVisible
		}
	}

	override func windowDidLoad() {

		let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Inspector"), bundle: nil)
		let feedInspector = inspector("Feed", storyboard)
		let folderInspector = inspector("Folder", storyboard)
		let builtinSmartFeedInspector = inspector("BuiltinSmartFeed", storyboard)
		let nothingInspector = inspector("Nothing", storyboard)
		inspectors = [feedInspector, folderInspector, builtinSmartFeedInspector, nothingInspector]
	}

	func inspector(for objects: [Any]?) -> Inspector {

		var fallbackInspector: Inspector? = nil

		for inspector in inspectors {
			if inspector.isFallbackInspector {
				fallbackInspector = inspector
			}
			else if let objects = objects, inspector.canInspect(objects) {
				return inspector
			}
		}

		return fallbackInspector!
	}
}

private extension InspectorWindowController {

	func inspector(_ identifier: String, _ storyboard: NSStoryboard) -> Inspector {

		return storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: identifier)) as! Inspector
	}

	func show(_ inspector: Inspector) {

		// TODO
	}
}