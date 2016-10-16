//
//  CommitCell.swift
//  Zzz
//
//  Created by Roman Laitarenko on 8/21/16.
//  Copyright © 2016 Roman Laitarenko. All rights reserved.
//

import Foundation

class CommitCell: NSTableCellView {
    
    @IBOutlet var authorLabel: NSTextField!
    @IBOutlet var messageLabel: NSTextField!
    @IBOutlet var dateLabel: NSTextField!
    
    override var backgroundStyle: NSBackgroundStyle {
        didSet {
            invalidateView()
        }
    }
    
    func fillWithCommit(commit: GCHistoryCommit?) {
        
        let placeholder = "No data"
        
        authorLabel.stringValue = commit?.authorName ?? placeholder
        messageLabel.stringValue = commit?.summary ?? placeholder
        dateLabel.objectValue = commit?.date ?? placeholder
    }
    
    private func invalidateView() {
        
        let textColor = backgroundStyle == .Light ? NSColor.labelColor() : NSColor.highlightColor()

        authorLabel.textColor = textColor
        messageLabel.textColor = textColor
        dateLabel.textColor = textColor
    }
}