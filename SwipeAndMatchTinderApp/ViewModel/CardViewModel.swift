//
//  CardViewModel.swift
//  SwipeAndMatchTinderApp
//
//  Created by user on 26.08.2021.
//

import UIKit


protocol ProducesCardViewModel {
    func toCardViewModel() -> CardViewModel
}

class CardViewModel {

    // MARK: - Properties
    let uid: String
    let imageNames: [String]
    let attributedText: NSAttributedString
    let textAlignment: NSTextAlignment
    
    fileprivate var imageIndex = 0 {
        didSet {
            let imageUrl = imageNames[imageIndex]
//            let image = UIImage(named: imageName)
            imageIndexObserver?(imageIndex, imageUrl)
        }
    }
    
    var imageIndexObserver: ((Int, String?) -> ())?
    
    // MARK: - Initialiser
    init(uid: String, imageNames: [String], attributedText: NSAttributedString,
         textAlignment: NSTextAlignment) {
        self.imageNames = imageNames
        self.attributedText = attributedText
        self.textAlignment = textAlignment
        self.uid = uid
    }
    
    func advanceToNextPhoto() {
        imageIndex = min(imageIndex + 1, imageNames.count - 1)
    }
    
    func backToPreviosPhoto() {
        imageIndex = max(0, imageIndex - 1)
    }
    
}

