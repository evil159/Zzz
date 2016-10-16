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

    func applicationDidFinishLaunching(aNotification: NSNotification) {

        NSApplication.sharedApplication().windows.first?.releasedWhenClosed = false
        NSApplication.sharedApplication().activateIgnoringOtherApps(true)
    }

    func applicationShouldHandleReopen(sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        
        if !flag {
            NSApplication.sharedApplication().windows.first?.makeKeyAndOrderFront(self)
        }
        
        return true
    }
}

