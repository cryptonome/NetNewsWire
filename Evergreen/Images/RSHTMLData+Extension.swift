//
//  RSHTMLData+Extension.swift
//  Evergreen
//
//  Created by Brent Simmons on 11/26/17.
//  Copyright © 2017 Ranchero Software. All rights reserved.
//

import Foundation
import RSParser

extension RSHTMLMetadata {

	func largestOpenGraphImageURL() -> String? {

		guard let openGraphImages = openGraphProperties?.images, !openGraphImages.isEmpty else {
			return nil
		}

		var bestImage: RSHTMLOpenGraphImage? = nil

		for image in openGraphImages {
			if bestImage == nil {
				bestImage = image
				continue
			}
			if image.height > bestImage!.height && image.width > bestImage!.width {
				bestImage = image
			}
		}

		guard let url = bestImage?.secureURL ?? bestImage?.url else {
			return nil
		}

		// Bad ones we should ignore.
		let badURLs = Set(["https://s0.wp.com/i/blank.jpg"])
		guard !badURLs.contains(url) else {
			return nil
		}

		return url
	}

	func bestWebsiteIconURL() -> String? {

		// TODO: metadata icons — sometimes they’re large enough to use here.

		if let openGraphImageURL = largestOpenGraphImageURL() {
			return openGraphImageURL
		}

		return twitterProperties.imageURL
	}

	func bestFeaturedImageURL() -> String? {

		if let openGraphImageURL = largestOpenGraphImageURL() {
			return openGraphImageURL
		}

		return twitterProperties.imageURL
	}
}