//
//  DividerView.swift
//  CheckMobiSDK
//
//  Copyright (c) 2019 checkmobi. All rights reserved.
//

import Foundation

class DividerView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.backgroundColor = UIColor(red:0.79, green:0.79, blue:0.79, alpha:1.0)
    }
    
    override func updateConstraints() {
        self.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                self.removeConstraint(constraint)
            }
        }
        
        let height = (1.0 / UIScreen.main.scale)
        addConstraint(NSLayoutConstraint(item: self,
                                         attribute: .height,
                                         relatedBy: .equal,
                                         toItem: nil,
                                         attribute: .height,
                                         multiplier: 1.0,
                                         constant: height))
        super.updateConstraints()
    }
}
