//
//  FlutterFloatingWindowPlugin.swift
//  Runner
//
//  Created by Kayshen on 2023/3/12
//

import Cocoa
import FlutterMacOS

public class FlutterFloatingWindowPlugin: NSObject, FlutterPlugin {
    static func registerInternal(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_floating_window", binaryMessenger: registrar.messenger)
        let instance = FlutterFloatingWindowPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        registerInternal(with: registrar)
        guard let app = NSApplication.shared.delegate as? FlutterAppDelegate else {
            debugPrint("failed to find flutter main window, application delegate is not FlutterAppDelegate")
            return
        }

        guard let window = app.mainFlutterWindow else {
            debugPrint("failed to find flutter main window")
            return
        }
        let mainWindowChannel = WindowChannel.register(with: registrar, windowId: 0)
        FloatingWindowManager.shared.attachMainWindow(window: window, mainWindowChannel)
    }
    
    public typealias OnWindowCreatedCallback = (FlutterViewController) -> Void
    static var onWindowCreatedCallback: OnWindowCreatedCallback?
    
    public static func setOnWindowCreatedCallback(_ callback: @escaping OnWindowCreatedCallback) {
        onWindowCreatedCallback = callback
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "createWindow":
            let arguments = call.arguments as? String
            let windowId = FloatingWindowManager.shared.create(arguments: arguments ?? "")
            result(windowId)
        case "show":
            let windowId = call.arguments as! Int64
            FloatingWindowManager.shared.show(windowId: windowId)
            result(nil)
        case "hide":
            let windowId = call.arguments as! Int64
            FloatingWindowManager.shared.hide(windowId: windowId)
            result(nil)
        case "center":
            let windowId = call.arguments as! Int64
            FloatingWindowManager.shared.center(windowId: windowId)
            result(nil)
        case "close":
            let windowId = call.arguments as! Int64
            FloatingWindowManager.shared.close(windowId: windowId)
            result(nil)
        case "setFrame":
            let arguments = call.arguments as! [String: Any?]
            let windowId = arguments["windowId"] as! Int64
            let left = arguments["left"] as! Double
            let top = arguments["top"] as! Double
            let width = arguments["width"] as! Double
            let height = arguments["height"] as! Double
            let rect = NSRect(x: left, y: top, width: width, height: height)
            FloatingWindowManager.shared.setFrame(windowId: windowId, frame: rect)
            result(nil)
        case "getAllSubWindowIds":
            let subWindowIds = FloatingWindowManager.shared.getAllSubWindowIds()
            result(subWindowIds)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
