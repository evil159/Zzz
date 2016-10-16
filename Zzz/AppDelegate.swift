//
//  AppDelegate.swift
//  Zzz
//
//  Created by Roman Laitarenko on 6/29/16.
//  Copyright © 2016 Roman Laitarenko. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        NSApplication.shared().windows.first?.isReleasedWhenClosed = false
        NSApplication.shared().activate(ignoringOtherApps: true)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        
        if !flag {
            NSApplication.shared().windows.first?.makeKeyAndOrderFront(self)
        }
        
        return true
    }
}

