//
//  View.swift
//  XLDSomeTweaksPlugin
//
//  Created by user on 2025/11/04.
//

import Ikemen

class ModernMusicBrainzReleaseQueryView: NSView {
    let tableView = NSTableView(frame: .zero) ※ {
        $0.headerView = nil
        $0.rowHeight = 1024
        $0.usesAutomaticRowHeights = true
        $0.addTableColumn(.init())
        $0.columnAutoresizingStyle = .firstColumnOnlyAutoresizingStyle
        $0.style = .fullWidth
        $0.gridStyleMask = [.solidHorizontalGridLineMask]
    }
    lazy var scrollView = NSScrollView(frame: .zero) ※ {
        $0.documentView = tableView
        $0.borderType = .bezelBorder
        $0.hasVerticalScroller = true
        $0.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(320)
            make.height.greaterThanOrEqualTo(240)
        }
    }
    
    let reloadButton = NSButton(title: "再読み込み", target: nil, action: nil) ※ {
        $0.keyEquivalent = "r"
        $0.keyEquivalentModifierMask = .command
    }
    
    let cancelButton = NSButton(title: "キャンセル", target: nil, action: nil) ※ {
        $0.keyEquivalent = "\u{1B}"
    }
    
    let okButton = NSButton(title: "OK", target: nil, action: nil) ※ {
        $0.keyEquivalent = "\r"
    }
    
    let linkToAnotherReleaseButton = NSButton(title: "Disc ID を他のリリースに関連付ける…", target: nil, action: nil)
    let findByISRCButton = NSButton(title: "ISRCからリリースを探す…", target: nil, action: nil)
    let titleLabel = NSTextField(labelWithString: "") ※ {
        $0.setContentHuggingPriority(.init(1), for: .horizontal)
    }
    
    let loadingIndicator = NSProgressIndicator() ※ {
        $0.controlSize = .large
        $0.style = .spinning
        $0.isDisplayedWhenStopped = false
    }
    
    init() {
        super.init(frame: .zero)

        let contentView = NSStackView(views: [
            NSStackView(views: [
                titleLabel,
                reloadButton,
            ]) ※ {
                $0.alignment = .lastBaseline
            },
            scrollView,
            NSStackView(views: [
                linkToAnotherReleaseButton,
                findByISRCButton,
                SpacerView(orientation: .horizontal),
                cancelButton,
                okButton,
            ]) ※ {
                $0.setHuggingPriority(.required, for: .horizontal)
                $0.setContentHuggingPriority(.required, for: .horizontal)
            },
        ])
        cancelButton.snp.makeConstraints { $0.width.equalTo(okButton) }
        okButton.snp.makeConstraints { $0.width.equalTo(reloadButton) }
        contentView.spacing = 16
        contentView.orientation = .vertical
        contentView.alignment = .trailing
        
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalTo(scrollView)
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
