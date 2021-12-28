//
//  CustomTextField.swift
//  SwipeAndMatchTinderApp
//
//  Created by user on 29.08.2021.
//

import UIKit

final class CustomTextField: UITextField {
    
    // MARK: - Properties
    var padding: CGFloat
    var height: CGFloat
    
    // MARK: - Initializers
    init(padding: CGFloat, height: CGFloat = 50) {
        self.padding = padding
        self.height = height
        super.init(frame: .zero)
        backgroundColor = .white
        layer.cornerRadius = 25
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return .init(width: 0, height: height)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: padding, dy: 0)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: padding, dy: 0)
    }
}
