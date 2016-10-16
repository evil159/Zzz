//
//  ColoredView.swift
//  Zzz
//
//  Created by Roman Laitarenko on 9/5/16.
//  Copyright © 2016 Roman Laitarenko. All rights reserved.
//

import Foundation

class ColoredView: NSView {
    
    var backgroundColor: NSColor? {
        didSet {
            self.needsDisplay = true
        }
    }
    
    override var wantsUpdateLayer: Bool {
        return true
    }
    
    override func updateLayer() {
        layer?.backgroundColor = backgroundColor?.cgColor
    }
}
