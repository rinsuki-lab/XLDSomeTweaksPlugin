//
//  Tweaks.swift
//  XLDSomeTweaksPlugin
//
//  Created by user on 2025/11/04.
//


import Ikemen
import SnapKit

extension XLDCDDBUtilProtocol {
    var tracks: [XLDTrackProtocol] {
        guard let trackArrIvar = class_getInstanceVariable(type(of: self), "trackArr") else {
            fatalError()
        }
        let trackArrOffset = ivar_getOffset(trackArrIvar)
        guard String(cString: ivar_getTypeEncoding(trackArrIvar)!) == "@\"NSArray\"" else {
            fatalError()
        }
        let nsArrayPtrPtr = Unmanaged.passUnretained(self).toOpaque() + trackArrOffset
        let nsArrayPtr = nsArrayPtrPtr.bindMemory(to: UnsafeMutableRawPointer.self, capacity: 1)[0]
        return Unmanaged<NSArray>.fromOpaque(nsArrayPtr).takeUnretainedValue() as! [XLDTrackProtocol]
    }
    
    var discidString: String {
        guard let discidIvar = class_getInstanceVariable(type(of: self), "discid") else {
            fatalError()
        }
        let discidOffset = ivar_getOffset(discidIvar)
        guard String(cString: ivar_getTypeEncoding(discidIvar)!) == "[100c]" else {
            fatalError()
        }
        return String(cString: (Unmanaged.passUnretained(self).toOpaque() + discidOffset).bindMemory(to: CChar.self, capacity: 100))
    }
    
    var tocString: String {
        guard let tocIvar = class_getInstanceVariable(type(of: self), "toc") else {
            fatalError()
        }
        let tocOffset = ivar_getOffset(tocIvar)
        guard String(cString: ivar_getTypeEncoding(tocIvar)!) == "[1024c]" else {
            fatalError()
        }
        return String(cString: (Unmanaged.passUnretained(self).toOpaque() + tocOffset).bindMemory(to: CChar.self, capacity: 1024))
    }
}

extension NSObject {
    @MainActor @objc func _someTweaks_cddbGetTracks(autoStart: Bool, isManualQuery: Bool) -> Void {
        guard Plugin.defaults.bool(forKey: DefaultsKey.useModernMusicBrainzReleaseQuery) else {
            return _someTweaks_cddbGetTracks(autoStart: autoStart, isManualQuery: isManualQuery)
        }
        guard let discView = perform(#selector(XLDController.discView)).takeUnretainedValue() as? NSObject else {
            NSLog("failed to get discView")
            return _someTweaks_cddbGetTracks(autoStart: autoStart, isManualQuery: isManualQuery)
        }
        guard let cueParser = discView.perform(#selector(XLDDiscView.cueParser)).takeUnretainedValue() as? XLDCueParserProtocol else {
            NSLog("failed to get cueParser")
            return _someTweaks_cddbGetTracks(autoStart: autoStart, isManualQuery: isManualQuery)
        }
        guard let window = discView.perform(#selector(XLDDiscView.window)).takeUnretainedValue() as? NSWindow else {
            NSLog("failed to get discView window")
            return _someTweaks_cddbGetTracks(autoStart: autoStart, isManualQuery: isManualQuery)
        }
        
        guard let cddbUtilClass = NSClassFromString("XLDCDDBUtil") as? XLDCDDBUtilProtocol.Type else {
            return _someTweaks_cddbGetTracks(autoStart: autoStart, isManualQuery: isManualQuery)
        }
        guard let util = cddbUtilClass.init(delegate: self) else {
            fatalError()
        }
        util.setTracks(
            cueParser.trackList(),
            totalFrame: .init(cueParser.totalFrames())
        )

        print("try to open sheet")
        let tracks = util.tracks
        print(tracks)
        let discID = util.discidString
        let vc = ModernMusicBrainzReleaseQueryViewController(cddbUtil: util)
        let sheetWindow = NSWindow(contentViewController: vc)
        window.beginSheet(sheetWindow) { response in
            guard response == .OK else {
                return
            }
            guard let current = vc.arrayController.selectedObjects.first as? ModernMusicBrainzReleaseQueryViewController.DiscModel else {
                return
            }
            util.readCDDB(withInfo: [
                "MusicBrainz",
                nil,
                current.release.id,
            ])
            discView.perform(#selector(XLDDiscView.reloadData))
            print(current)
        }
        print("done?")
    }
}

class Tweaks_ModernMusicBrainzReleaseQuery {
    @MainActor static let menuItem = NSMenuItem(title: "SomeTweaksPluginのMusicBrainz照会ダイアログを使う", action: nil, keyEquivalent: "") ※ {
        $0.subtitle = "ロード中の表示が追加され、MusicBrainzでのカタログNoやディスク名などが表示されるようになりますが、MusicBrainz以外のソース (CDDBなど) が利用できなくなります。"
        $0.bind(.value, to: Plugin.defaults, withKeyPath: DefaultsKey.useModernMusicBrainzReleaseQuery)
    }
    
    static func swizzle() {
        let classXLDController = NSClassFromString("XLDController")!
        method_exchangeImplementations(
            class_getInstanceMethod(classXLDController, #selector(XLDController.cddbGetTracks(withAutoStart:isManualQuery:)))!,
            class_getInstanceMethod(classXLDController, #selector(NSObject._someTweaks_cddbGetTracks(autoStart:isManualQuery:)))!
        )
        let cddbUtil = NSClassFromString("XLDCDDBUtil")
        class_addProtocol(cddbUtil, XLDCDDBUtilProtocol.self)
        let cueParser = NSClassFromString("XLDCueParser")
        class_addProtocol(cueParser, XLDCueParserProtocol.self)
        let track = NSClassFromString("XLDTrack")
        class_addProtocol(track, XLDTrackProtocol.self)
    }
}
