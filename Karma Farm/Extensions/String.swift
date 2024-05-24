//
//  String.swift
//  Karma Farm
//
//  Created by Tobias Fu on 1/27/24.
//

import UIKit

extension String {
   func sizeUsingFont(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
}
