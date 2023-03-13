//
//  FloatingWindowManager.swift
//  Runner
//
//   Created by Kayshen 2023/3/12
//

import FlutterMacOS
import Foundation


class FloatingWindowManager {
    static let shared = FloatingWindowManager()
    
    private var id: Int64 = 0
    
    private var windows: [Int64: BaseFlutterWindow] = [:]
    
    func create(arguments: String) -> Int64 {
        id += 1
        let windowId = id
        
        let window = FlutterWindow(id: windowId, arguments: arguments)
        window.delegate = self
        window.windowChannel.methodHandler = self.handleMethodCall
        windows[windowId] = window
        return windowId
    }
    
    func attachMainWindow(window: NSWindow, _ channel: WindowChannel) {
        let mainWindow = BaseFlutterWindow(window: window, channel: channel)
        mainWindow.windowChannel.methodHandler = self.handleMethodCall
        windows[0] = mainWindow
    }
    
    private func handleMethodCall(fromWindowId: Int64, targetWindowId: Int64, method: String, arguments: Any?, result: @escaping FlutterResult) {
        guard let window = self.windows[targetWindowId] else {
            result(FlutterError(code: "-1", message: "failed to find target window. \(targetWindowId)", details: nil))
            return
        }
        window.windowChannel.invokeMethod(fromWindowId: fromWindowId, method: method, arguments: arguments, result: result)
    }
    
    func show(windowId: Int64) {
        guard let window = windows[windowId] else {
            debugPrint("window \(windowId) not exists.")
            return
        }
        window.show()
    }
    
    func hide(windowId: Int64) {
        guard let window = windows[windowId] else {
            debugPrint("window \(windowId) not exists.")
            return
        }
        window.hide()
    }
    
    
    func center(windowId: Int64) {
        guard let window = windows[windowId] else {
            debugPrint("window \(windowId) not exists.")
            return
        }
        window.center()
    }
    
    
    func close(windowId: Int64) {
        guard let window = windows[windowId] else {
            debugPrint("window \(windowId) not exists.")
            return
        }
        window.close()
    }
    
    func closeAll() {
        windows.forEach { _, value in
            value.close()
        }
    }
    
    func setFrame(windowId: Int64, frame: NSRect) {
        guard let window = windows[windowId] else {
            debugPrint("window \(windowId) not exists.")
            return
        }
        window.setFrame(frame: frame)
    }
  
    
    func getAllSubWindowIds() -> [Int64] {
        return windows.keys.filter { $0 != 0 }
    }
}

protocol WindowManagerDelegate: AnyObject {
    func onClose(windowId: Int64)
}

extension FloatingWindowManager: WindowManagerDelegate {
    func onClose(windowId: Int64) {
        windows.removeValue(forKey: windowId)
    }
}
