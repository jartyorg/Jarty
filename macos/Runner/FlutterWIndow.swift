//
//  FlutterWindow.swift
//  Runner
//
//  Created by Kayshen 2023/3/12
//
import Foundation
import Cocoa
import FlutterMacOS

import clipboard_watcher
import hotkey_manager
import isar_flutter_libs
import screen_retriever
import tray_manager
import window_manager


class BaseFlutterWindow: NSObject {
    private let window: NSWindow
    let windowChannel: WindowChannel
    
    init(window: NSWindow, channel: WindowChannel) {
        self.window = window
        self.windowChannel = channel
        super.init()
    }
    
    func show() {
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func center() {
        window.center();
    }
    
    func hide() {
        window.orderOut(nil)
    }
    
    func setFrame(frame: NSRect) {
        window.setFrame(frame, display: false, animate: true)
    }
    
    func close() {
        window.close()
    }
    
}

class CustomWindow: NSWindow {
    override var canBecomeKey: Bool {
        return true
    }
    
    override func resignKey() {
        super.resignKey()
        self.close()
    }

}






class FlutterWindow: BaseFlutterWindow {
    let windowId: Int64
    
    let window: NSWindow
    
    weak var delegate: WindowManagerDelegate?
    
    init(id: Int64, arguments: String) {
        windowId = id
        window = CustomWindow(
            contentRect: NSRect(x: 0, y: 0, width: 633, height: 463),
            styleMask: [.borderless],
            backing: .buffered, defer: false)
        
        window.center()
        window.collectionBehavior=[.fullScreenAuxiliary,.canJoinAllSpaces]
        let project = FlutterDartProject()
        project.dartEntrypointArguments = ["floating_window", "\(windowId)", arguments]
        let flutterViewController = FlutterViewController(project: project)
        window.contentViewController = flutterViewController
        
        HotkeyManagerPlugin.register(with: flutterViewController.registrar(forPlugin: "HotkeyManagerPlugin"))
        IsarFlutterLibsPlugin.register(with: flutterViewController.registrar(forPlugin: "IsarFlutterLibsPlugin"))
        
        let plugin = flutterViewController.registrar(forPlugin: "FlutterFloatingWindowPlugin")
        FlutterFloatingWindowPlugin.registerInternal(with: plugin)
        
        let windowChannel = WindowChannel.register(with: plugin, windowId: id)
        // Give app a chance to register plugin.
        FlutterFloatingWindowPlugin.onWindowCreatedCallback?(flutterViewController)
        
        super.init(window: window, channel: windowChannel)
        
        window.delegate = self
        window.isReleasedWhenClosed = false
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
    }
    
    deinit {
        debugPrint("release window resource")
        window.delegate = nil
        if let flutterViewController = window.contentViewController as? FlutterViewController {
            flutterViewController.engine.shutDownEngine()
        }
        window.contentViewController = nil
        window.windowController = nil
    }
}

extension FlutterWindow: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        delegate?.onClose(windowId: windowId)
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        delegate?.onClose(windowId: windowId)
        return true
    }
}
