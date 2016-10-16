//
//  DiffHeaderView.swift
//  Zzz
//
//  Created by Roman Laitarenko on 8/22/16.
//  Copyright © 2016 Roman Laitarenko. All rights reserved.
//

import Foundation

class DiffHeaderCell: NSTableCellView {
    
    @IBOutlet var hashLabel: NSTextField!
    @IBOutlet var parentHashLabel: NSTextField!
    @IBOutlet var dateLabel: NSTextField!
    @IBOutlet var authorLabel: NSTextField!
    @IBOutlet var avatarView: NSImageView!
    @IBOutlet var separatorView: ColoredView!
    
    var commit: GCHistoryCommit? {
        didSet {
            reloadData(commit)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initialize()
    }
    
    private func initialize() {
        separatorView.backgroundColor = NSColor.windowFrameColor()
    }
    
    private func reloadData(commit: GCHistoryCommit?) {
        
        let parent = commit?.parents.first as? GCHistoryCommit
        
        hashLabel.stringValue = commit?.SHA1 ?? ""
        parentHashLabel.stringValue = parent?.SHA1 ?? ""
        dateLabel.objectValue = commit?.date
        authorLabel.stringValue = commit?.author ?? ""
    }
}