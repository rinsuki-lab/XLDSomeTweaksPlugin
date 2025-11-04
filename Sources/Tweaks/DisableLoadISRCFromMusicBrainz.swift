//
//  DisableLoadISRCFromMusicBrainz.swift
//  XLDSomeTweaksPlugin
//
//  Created by user on 2025/11/04.
//

import Ikemen

fileprivate extension NSURL {
    @MainActor @objc class func _someTweaks_disableLoadISRCFromMusicBrainz_urlWithString(_ string: NSString) -> NSURL {
        if Plugin.defaults.bool(forKey: DefaultsKey.disableLoadISRCFromMusicBrainz), string.contains("/ws/"), string.contains("+isrcs+") {
            return _someTweaks_disableLoadISRCFromMusicBrainz_urlWithString(string.replacingOccurrences(of: "+isrcs+", with: "+") as NSString)
        } else {
            return _someTweaks_disableLoadISRCFromMusicBrainz_urlWithString(string)
        }
    }
}

enum Tweaks_DisableLoadISRCFromMusicBrainz {
    @MainActor static let menuItem = NSMenuItem(title: "MusicBrainzからISRCを読み込まないようにする", action: nil, keyEquivalent: "") ※ {
        $0.subtitle = "MusicBrainzのRecordingに他のCDやデジタルリリースなどをソースとしたISRCが付いており、かつCDのサブコードにISRCの情報がない場合、XLDはデフォルトでMusicBrainzにあるISRC情報を付与しますが、後々MusicBrainzから取得したものか実際にCDから取得したものかの判別が付かなくなる問題があります。"
        $0.bind(.value, to: Plugin.defaults, withKeyPath: DefaultsKey.disableLoadISRCFromMusicBrainz)
    }
    
    static func swizzle() {
        method_exchangeImplementations(
            class_getClassMethod(NSURL.self, "URLWithString:")!,
            class_getClassMethod(NSURL.self, #selector(NSURL._someTweaks_disableLoadISRCFromMusicBrainz_urlWithString(_:)))!
        )
    }
}
