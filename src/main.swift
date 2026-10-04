import Cocoa
import WebKit

// 无边框窗口需要子类化才能成为 key window（接收键盘事件）
class PanelWindow: NSWindow {
    override var canBecomeKey: Bool { return true }
    override var canBecomeMain: Bool { return true }
}

class AppDelegate: NSObject, NSApplicationDelegate, WKScriptMessageHandler {
    var window: PanelWindow!
    var webView: WKWebView!
    var fullFrame: NSRect = .zero
    var isMini = false

    let fullSize = NSSize(width: 340, height: 560)
    let miniSize = NSSize(width: 210, height: 48)

    func applicationDidFinishLaunching(_ notification: Notification) {
        window = PanelWindow(
            contentRect: NSRect(x: 0, y: 0, width: fullSize.width, height: fullSize.height),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false)
        window.center()
        window.title = "番茄钟"
        window.hasShadow = true
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating            // 悬浮在其他窗口之上
        window.isMovableByWindowBackground = true
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]  // 所有桌面可见
        window.hidesOnDeactivate = false
        fullFrame = window.frame

        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        let ucc = config.userContentController
        ucc.add(self, name: "state")

        webView = WKWebView(frame: .zero, configuration: config)
        webView.setValue(false, forKey: "drawsBackground")   // 透明背景，圆角由 HTML 绘制
        window.contentView = webView

        if let htmlPath = Bundle.main.path(forResource: "index", ofType: "html") {
            let url = URL(fileURLWithPath: htmlPath)
            webView.loadFileURL(url, allowingReadAccessTo: Bundle.main.resourceURL!)
        }

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // ---- 接收页面消息 ----
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        // 窗口拖拽：JS 传来鼠标位移增量
        if let dict = message.body as? [String: Any], let type = dict["type"] as? String, type == "move" {
            let dx = dict["dx"] as? Double ?? 0
            let dy = dict["dy"] as? Double ?? 0
            DispatchQueue.main.async {
                var f = self.window.frame
                f.origin.x += CGFloat(dx)
                f.origin.y -= CGFloat(dy)   // 屏幕坐标系 Y 轴向上
                self.window.setFrame(f, display: true)
            }
            return
        }

        let body = message.body as? String ?? ""
        DispatchQueue.main.async {
            switch body {
            case "mini":
                self.setMini(true)
            case "full":
                self.setMini(false)
            case "done":
                // 计时结束：展开窗口、抢回焦点、响铃
                self.setMini(false)
                NSApp.activate(ignoringOtherApps: true)
                self.window.makeKeyAndOrderFront(nil)
                NSSound.beep()
            case "quit":
                NSApp.terminate(nil)
            default:
                break
            }
        }
    }

    // ---- 窗口大小切换 ----
    func setMini(_ mini: Bool) {
        guard mini != isMini else { return }
        isMini = mini

        var f: NSRect
        if mini {
            // 迷你条吸附到屏幕右上角
            fullFrame = window.frame
            let screen = window.screen ?? NSScreen.main!
            let visible = screen.visibleFrame
            f = NSRect(x: visible.maxX - miniSize.width - 12,
                       y: visible.maxY - miniSize.height - 12,
                       width: miniSize.width,
                       height: miniSize.height)
        } else {
            f = fullFrame
        }
        window.setFrame(f, display: true, animate: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)   // 不占 Dock 图标（如需 Dock 图标改为 .regular）
app.run()
