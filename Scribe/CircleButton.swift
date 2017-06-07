//
//  CircleButton.swift
//  Scribe
//
//  Created by Tran, Timothy on 6/7/17.
//  Copyright © 2017 Tran, Timothy. All rights reserved.
//

import UIKit
@IBDesignable
class CircleButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 30.0 {
        didSet{
            setupView()
        }
    }
    
    override func prepareForInterfaceBuilder() {
        setupView()
    }

    func setupView() {
        layer.cornerRadius = cornerRadius

    }


}
