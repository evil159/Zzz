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
        case .Unmodified:
            return "Unmodified"
        case .Ignored:
            return "Ignored"
        case .Untracked:
            return "Untracked"
        case .Unreadable:
            return "Unreadable"
        case .Added:
            return "Added"
        case .Deleted:
            return "Deleted"
        case .Modified:
            return "Modified"
        case .Renamed:
            return "Renamed"
        case .Copied:
            return "Copied"
        case .TypeChanged:
            return "TypeChanged"
        case .Conflicted:
            return "Conflicted"
        }
    }
}
