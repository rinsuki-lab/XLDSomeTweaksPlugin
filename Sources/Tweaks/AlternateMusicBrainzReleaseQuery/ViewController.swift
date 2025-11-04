//
//  ViewController.swift
//  XLDSomeTweaksPlugin
//
//  Created by user on 2025/11/04.
//

import Ikemen
import Combine

@objc class IsNotEmptyTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSNumber.self
    }

    override class func allowsReverseTransformation() -> Bool {
        return false
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let array = value as? NSArray else { return false }
        return array.count > 0
    }
}

class ModernMusicBrainzReleaseQueryViewController: NSViewController {
    let cddbUtil: XLDCDDBUtilProtocol
    private lazy var contentView = ModernMusicBrainzReleaseQueryView()
    var discs: [(MusicBrainzRelease, MusicBrainzMedia, MusicBrainzDisc)] = []
    var arrayController = NSArrayController() ※ {
        $0.avoidsEmptySelection = false
    }
    var cancellables = Set<AnyCancellable>()
    
    class DiscModel: NSObject {
        let release: MusicBrainzRelease
        let media: MusicBrainzMedia
        let disc: MusicBrainzDisc
        let disabled: Bool
        
        init(release: MusicBrainzRelease, media: MusicBrainzMedia, disc: MusicBrainzDisc, disabled: Bool) {
            self.release = release
            self.media = media
            self.disc = disc
            self.disabled = disabled
            super.init()
        }
    }

    init(cddbUtil: XLDCDDBUtilProtocol) {
        self.cddbUtil = cddbUtil
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = contentView
        contentView.titleLabel.stringValue = "Disc ID \(cddbUtil.discidString) の検索結果:"
        
        contentView.cancelButton.target = self
        contentView.cancelButton.action = #selector(close)

        contentView.okButton.target = self
        contentView.okButton.action = #selector(ok)
        
        contentView.linkToAnotherReleaseButton.target = self
        contentView.linkToAnotherReleaseButton.action = #selector(openLinkPage)
        
        contentView.findByISRCButton.target = self
        contentView.findByISRCButton.action = #selector(openFindByISRCPage)
        
        contentView.reloadButton.target = self
        contentView.reloadButton.action = #selector(reload)

        contentView.tableView.bind(.content, to: arrayController, withKeyPath: "arrangedObjects")
        contentView.tableView.bind(.selectionIndexes, to: arrayController, withKeyPath: "selectionIndexes")
        contentView.okButton.bind(.enabled, to: arrayController, withKeyPath: "selectedObjects.@count")
        contentView.tableView.delegate = self
        contentView.tableView.doubleAction = #selector(ok)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        reload()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        reloadTask?.cancel()
    }
    
    @objc func openLinkPage() {
        let url = URL(string: "https://musicbrainz.org/cdtoc/attach?toc=\(cddbUtil.tocString)")!
        NSWorkspace.shared.open(url)
    }
    
    @objc func openFindByISRCPage() {
        var url = "https://files.rinsuki.net/2025/find_mbs_by_isrc.html?t=s"
        for track in cddbUtil.tracks {
            url += ",\(track.metadata()["ISRC"] ?? "NO_ISRC"):\(track.frames())"
        }
        NSWorkspace.shared.open(URL(string: url)!)
    }
    
    var reloadTask: Task<Void, Never>?
    @objc func reload() {
        let discID = cddbUtil.discidString
        let req = URLRequest(url: URL(string: "https://musicbrainz.org/ws/2/discid/\(discID)?fmt=json&inc=labels+artist-credits")!)
        reloadTask?.cancel()
        arrayController.content = []
        reloadTask = Task {
            defer {
                DispatchQueue.main.async {
                    self.contentView.loadingIndicator.stopAnimation(self)
                }
            }
            do {
                await MainActor.run {
                    contentView.loadingIndicator.startAnimation(self)
                }
                let (data, res) = await try URLSession.shared.data(for: req)
                let decoded = try JSONDecoder().decode(MusicBrainzDiscIDLookupResponse.self, from: data)
                var discs: [DiscModel] = []
                for release in decoded.releases {
                    var disabled = false
                    for media in release.media {
                        for disc in media.discs {
                            if disc.id == discID {
                                discs.append(.init(release: release, media: media, disc: disc, disabled: disabled))
                                disabled = true
                            }
                        }
                    }
                }
                await MainActor.run {
                    self.arrayController.content = discs
                    self.view.window?.makeFirstResponder(self.contentView.tableView)
                }
            } catch {
                guard !Task.isCancelled else {
                    return
                }
                await MainActor.run {
                    if let window = view.window {
                        let alert = NSAlert()
                        alert.alertStyle = .warning
                        alert.messageText = "MusicBrainzへの照会に失敗しました"
                        alert.informativeText = error.localizedDescription + "\n\n\(error)"
                        alert.beginSheetModal(for: window)
                    }
                }
            }
        }
    }
    
    @objc func close() {
        if let window = view.window {
            window.sheetParent?.endSheet(window, returnCode: .cancel)
        }
    }
    
    @objc func ok() {
        if let window = view.window {
            window.sheetParent?.endSheet(window, returnCode: .OK)
        }
    }
}

extension ModernMusicBrainzReleaseQueryViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let rowView = ModernMusicBrainzReleaseQueryRowView()
        return rowView
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        guard let discs = arrayController.content as? [DiscModel] else {
            return false
        }
        return !discs[row].disabled
    }
}
