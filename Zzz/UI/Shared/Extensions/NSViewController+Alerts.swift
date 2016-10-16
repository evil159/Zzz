//
//  GIViewController+Alerts.swift
//  Zzz
//
//  Created by Roman Laitarenko on 8/29/16.
//  Copyright © 2016 Roman Laitarenko. All rights reserved.
//

import Foundation

extension NSViewController {
    
    func presentAlert(withType type: GIAlertType, title: String, message: String?) {
        
        let alert = NSAlert()
        
        alert.setType(type)
        alert.messageText = title
        alert.addButtonWithTitle("OK")
        
        if let message = message {
            alert.informativeText = message
        }

        alert.beginSheetModalForWindow(view.window, withCompletionHandler: nil)
    }
}