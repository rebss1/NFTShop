//
//  UIView+parentViewController.swift
//  Tracker
//
//  Created by Илья Лощилов on 07.07.2024.
//

import Foundation
import UIKit

extension UIView {
    
    var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
}