//
//  RowView.swift
//  XLDSomeTweaksPlugin
//
//  Created by user on 2025/11/04.
//

import Ikemen

class ModernMusicBrainzReleaseQueryRowView: NSStackView {
    let releaseTitleLabel = NSTextField(labelWithString: "") ※ {
        $0.lineBreakMode = .byTruncatingMiddle
        $0.setContentCompressionResistancePriority(.init(250), for: .horizontal)
    }
    let releaseIDLabel = NSTextField(labelWithString: "") ※ {
        $0.textColor = .secondaryLabelColor
        $0.lineBreakMode = .byTruncatingTail
        $0.setContentCompressionResistancePriority(.init(249), for: .horizontal)
    }
    let mediaLabel = NSTextField(wrappingLabelWithString: "")
    let artistLabel = NSTextField(labelWithString: "")
    let metaLabel = NSTextField(wrappingLabelWithString: "")
    let disabledLabel = NSTextField(wrappingLabelWithString: "1つのリリースに同じ Disc ID が複数関連付けられている場合、XLDでは最初の一つしか選択できません。MusicBrainz Picard などで後からメタデータを修正してください。")
    
    init() {
        super.init(frame: .zero)
        
        let stackView = NSStackView(views: [
            NSStackView(views: [
                releaseTitleLabel,
                releaseIDLabel,
            ]) ※ {
                $0.alignment = .lastBaseline
            },
            mediaLabel,
            artistLabel,
            metaLabel,
            disabledLabel,
        ]) ※ {
            $0.orientation = .vertical
            $0.spacing = 0
            $0.alignment = .leading
        }
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(4)
            make.top.bottom.equalToSuperview().inset(8)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc dynamic var objectValue: ModernMusicBrainzReleaseQueryViewController.DiscModel? {
        didSet {
            if let objectValue {
                let release = objectValue.release
                let media = objectValue.media
                
                var title = release.title
                if !release.disambiguation.isEmpty {
                    title += " (" + release.disambiguation + ")"
                }
                releaseTitleLabel.stringValue = title
                releaseIDLabel.stringValue = release.id

                var mediaTitle = "\(media.format), Disc \(media.position) / \(release.media.count)"
                if !media.title.isEmpty {
                    mediaTitle += " - " + media.title
                }
                mediaLabel.stringValue = mediaTitle
                
                var artistCredit = "􀉬 "
                for credit in release.artistCredit {
                    artistCredit += credit.name + credit.joinphrase
                }
                artistLabel.stringValue = artistCredit

                var releaseMeta = "􀉉 \(release.date)"
                for label in release.labelInfo {
                    if let cn = label.catalogNumber {
                        releaseMeta += ", \(cn)"
                    }
                }
                metaLabel.stringValue = releaseMeta
                
                disabledLabel.isHidden = !objectValue.disabled
            }
        }
    }
}
