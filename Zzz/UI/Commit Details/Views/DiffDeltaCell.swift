//
//  DiffDeltaCell.swift
//  Zzz
//
//  Created by Roman Laitarenko on 8/22/16.
//  Copyright © 2016 Roman Laitarenko. All rights reserved.
//

import Foundation

class DiffDeltaCell: NSTableCellView {
    
    @IBOutlet var pathLabel: NSTextField!
    @IBOutlet var statusLabel: NSTextField!
    
    func fill(with model: GCDiffDelta) {
        
        pathLabel.stringValue = model.canonicalPath
        statusLabel.stringValue = model.changeDescription
    }
}

// MARK: GCDiffDelta description
private extension GCDiffDelta {
    
    dynamic var changeDescription: String {
        switch change {
        case .unmodified:
            return "Unmodified"
        case .ignored:
            return "Ignored"
        case .untracked:
            return "Untracked"
        case .unreadable:
            return "Unreadable"
        case .added:
            return "Added"
        case .deleted:
            return "Deleted"
        case .modified:
            return "Modified"
        case .renamed:
            return "Renamed"
        case .copied:
            return "Copied"
        case .typeChanged:
            return "TypeChanged"
        case .conflicted:
            return "Conflicted"
        }
    }
}
