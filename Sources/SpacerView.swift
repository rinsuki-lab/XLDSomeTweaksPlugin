//
//  SpacerView.swift
//  XLDSomeTweaksPlugin
//
//  Created by user on 2025/11/04.
//


class SpacerView: NSView {
    init(orientation: NSLayoutConstraint.Orientation) {
        super.init(frame: .zero)
        setContentHuggingPriority(.init(1), for: orientation)
        setContentCompressionResistancePriority(.init(1), for: orientation)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
