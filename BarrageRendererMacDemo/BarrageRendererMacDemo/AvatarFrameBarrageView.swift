//
//  AvatarFrameBarrageView.swift
//  BarrageRendererMacDemo
//
//  Created by Mrlu on 2020/11/13.
//  Copyright © 2020 mrlu. All rights reserved.
//

import AppKit

class AvatarFrameBarrageView: NSControl {
    private lazy var headImageView:NSImageView = {
        let image = NSImageView(frame: NSRect.zero)
        image.isEditable = false
        return image
    }()
    
    private lazy var midImageView:NSImageView = {
        let image = NSImageView(frame: NSRect.zero)
        image.isEditable = false
        image.imageScaling = .scaleAxesIndependently
        return image
    }()
    
    private lazy var tailImageView:NSImageView = {
        let image = NSImageView(frame: NSRect.zero)
        image.isEditable = false
        return image
    }()
    
    private lazy var textField:NSTextField = {
        let textField = NSTextField(frame: NSRect.zero)
        textField.isBordered = false
        textField.isSelectable = false
        textField.isEditable = false
        textField.backgroundColor = NSColor.clear
        return textField
    }()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        loadSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadSubviews() {
        addSubview(headImageView)
        addSubview(midImageView)
        addSubview(tailImageView)
        addSubview(textField)
    }
    
    override func layout() {
        super.layout()
        headImageView.frame = CGRect(origin: CGPoint.zero, size: headImageView.frame.size)
        tailImageView.frame = CGRect(origin: CGPoint(x: frame.width - tailImageView.frame.width, y: 0), size: tailImageView.frame.size)
        midImageView.frame = CGRect(origin: CGPoint(x: headImageView.frame.width, y: 0), size: CGSize(width: frame.width - headImageView.frame.width - tailImageView.frame.width, height: frame.size.height))
        let textSize = textField.sizeThatFits(NSSize(width: 1000, height: 40))
        textField.frame = CGRect(origin: CGPoint(x: midImageView.frame.minX, y: (frame.height - textSize.height)/2.0), size: CGSize(width: midImageView.frame.width, height: textSize.height))
    }
    
    override func sizeThatFits(_ size: NSSize) -> NSSize {
        let imageHeight = headImageView.bounds.height
        var maxWidth = CGFloat(0.0)
        var maxHeight = CGFloat(0.0)
        let textSize = textField.sizeThatFits(NSSize(width: 1000, height: 40))
        if textSize.width > maxWidth {
            maxWidth = textSize.width
        }
        if textSize.height > maxHeight {
            maxHeight = textSize.height
        }
        if imageHeight > maxHeight {
            maxHeight = imageHeight
        }
        maxWidth += headImageView.frame.width + tailImageView.frame.width
        return CGSize(width: maxWidth, height: maxHeight)
    }
    
    override func sizeToFit() {
        super.sizeToFit()
        let size = sizeThatFits(frame.size)
        self.frame = CGRect(origin: self.frame.origin, size: size)
    }
    
    override func configure(withParams params: [AnyHashable : Any]!) {
        super.configure(withParams: params)
        let themeid = (params["themeId"] as? NSNumber)?.intValue ?? 2
        
        if let title = params["title"] as? String {
            textField.stringValue = title
        }
        
        if let headSize = (params["hSize"] as? NSValue)?.sizeValue {
            headImageView.frame.size = headSize
            headImageView.image = NSImage(named: "rb_img_barrage_dressup_v\(themeid)_1")
        }
        
        if let headSize = (params["tSize"] as? NSValue)?.sizeValue {
            tailImageView.frame.size = headSize
            tailImageView.image = NSImage(named: "rb_img_barrage_dressup_v\(themeid)_3")
        }
        
        if let midSize = (params["mSize"] as? NSValue)?.sizeValue {
            let midImage = NSImage(named: "rb_img_barrage_dressup_v\(themeid)_2")
            midImage?.capInsets = NSEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
            midImage?.resizingMode = .stretch
            midImageView.image = midImage
        }
    }
    
}
