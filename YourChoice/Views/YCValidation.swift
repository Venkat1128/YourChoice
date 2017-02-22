//
//  YCValidation.swift
//  YourChoice
//
//  Created by Venkat Kurapati on 13/02/2017.
//  Copyright © 2017 Kurapati. All rights reserved.
//

import UIKit
@IBDesignable
class YCValidation: UIView {

    let nibName = "YCValidation"
    var view: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBInspectable var title: String?
    @IBInspectable var placeholder: String?
    
    var enabled: Bool {
        get {
            return inputTextField.isEnabled
        }
        set(enabled) {
            inputTextField.isEnabled = enabled
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        
        // 3. Setup view from .xib file
        setup()
    }
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        // 3. Setup view from .xib file
        setup()
    }
    
    override func layoutSubviews() {
        titleLabel.text = title
        inputTextField.placeholder = placeholder
        inputTextField.autocorrectionType = .no
        errorLabel.isHidden = true
        inputTextField.layer.borderWidth = 1.0
        inputTextField.layer.cornerRadius  = 12.0
        inputTextField.layer.borderColor = UIColor.black.cgColor
    }
    
    func setup() {
        view = loadViewFromNib()
        // Use bounds not frame or it'll be offset
        view.frame = bounds
        // Make the view stretch with containing view
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    func initInputTextField(_ keyboardType: UIKeyboardType, returnKeyType: UIReturnKeyType, spellCheckingType: UITextSpellCheckingType, delegate: UITextFieldDelegate, secureTextEntry: Bool) {
        inputTextField.keyboardType = keyboardType
        inputTextField.returnKeyType = returnKeyType
        inputTextField.spellCheckingType = spellCheckingType
        inputTextField.delegate = delegate
        inputTextField.isSecureTextEntry = secureTextEntry
    }
}
