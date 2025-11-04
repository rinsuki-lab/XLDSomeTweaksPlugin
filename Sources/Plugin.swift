//
//  Plugin.swift
//  XLDSomeTweaksPlugin
//
//  Created by user on 2025/11/04.
//

@objc(XLDSomeTweaksPlugin)
@MainActor
class Plugin: NSObject {
    static let supportedVersion = "157.2"
    static var isHooked = false
    
    override class func conforms(to `protocol`: Protocol) -> Bool {
        if !isHooked {
            isHooked = true
            self.pluginInitialize()
        }
        return super.conforms(to: `protocol`)
    }
    
    static let defaults = UserDefaults(suiteName: "net.rinsuki.plugins.XLDSomeTweaksPlugin")!
    static let pluginMenu = NSMenu(title: "XLDSomeTweaksPlugin")
    static let pluginTweaksMenu = NSMenu(title: "Tweaks")
    
    private class func pluginInitialize() {
        let xldVersion = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
        if xldVersion != supportedVersion {
            let alert = NSAlert()
            alert.alertStyle = .warning
            alert.messageText = String(
                localized: "INCOMPATIBLE_XLD_VERSION_TITLE",
                defaultValue: "非対応バージョン"
            )
            alert.informativeText = String(
                localized: "INCOMPATIBLE_XLD_VERSION_MESSAGE",
                defaultValue: "XLDSomeTweaksPlugin はこのバージョンの XLD に対応していません。\n\n現在のバージョン: \(xldVersion ?? "Unknown")\n対応バージョン: \(supportedVersion)"
            )
            alert.addButton(withTitle: String(
                localized: "INCOMPATIBLE_XLD_VERSION_BUTTON_SKIP",
                defaultValue: "プラグインなしで XLD を起動する"
            ))
            alert.addButton(withTitle: String(
                localized: "INCOMPATIBLE_XLD_VERSION_BUTTON_ANYWAY",
                defaultValue: "とにかくプラグインを読み込む"
            ))
            let result = alert.runModal()
            if result == .alertFirstButtonReturn {
                return
            }
        }
        print("initializing plugin...")
        
        defaults.register(defaults: [
            DefaultsKey.disableLoadISRCFromMusicBrainz: true,
            DefaultsKey.useModernMusicBrainzReleaseQuery: true,
        ])
        
        Tweaks_DisableLoadISRCFromMusicBrainz.swizzle()
        Tweaks_ModernMusicBrainzReleaseQuery.swizzle()
        
        let menu = NSMenuItem(title: "XLDSomeTweaksPlugin", action: nil, keyEquivalent: "")
        menu.submenu = pluginMenu
        DispatchQueue.main.async {
            NSApplication.shared.mainMenu!.addItem(menu)
        }
        
        pluginMenu.addItem(withTitle: "Tweaks", action: nil, keyEquivalent: "").submenu = pluginTweaksMenu
        
        pluginTweaksMenu.addItem(Tweaks_DisableLoadISRCFromMusicBrainz.menuItem)
        pluginTweaksMenu.addItem(Tweaks_ModernMusicBrainzReleaseQuery.menuItem)
    }
}
