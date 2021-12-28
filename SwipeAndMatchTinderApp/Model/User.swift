//
//  User.swift
//  SwipeAndMatchTinderApp
//
//  Created by user on 25.08.2021.
//

import UIKit


struct User: ProducesCardViewModel {
    
    // MARK: - Properties
    var userName: String?
    var age: Int?
    var profession: String?
    var imageUrl1: String?
    var imageUrl2: String?
    var imageUrl3: String?
    var uid: String?
    
    var minSeekingAge: Int?
    var maxSeekingAge: Int?
    
    // MARK: - Initialiser
    init(dictionary: [String: Any]) {
        self.userName = dictionary["fullName"] as? String ?? ""
        self.age = dictionary["age"] as? Int
        self.profession = dictionary["profession"] as? String
        self.imageUrl1 = dictionary["imageUrl1"] as? String
        self.imageUrl2 = dictionary["imageUrl2"] as? String
        self.imageUrl3 = dictionary["imageUrl3"] as? String
        self.uid = dictionary["uid"] as? String ?? ""
        self.minSeekingAge = dictionary["minSeekingAge"] as? Int
        self.maxSeekingAge = dictionary["maxSeekingAge"] as? Int
    }
    
    // MARK: - Methods
    func toCardViewModel() -> CardViewModel {
        
        let ageString = age != nil ? "\(age!)" : "N\\A"
        let attributedText = NSMutableAttributedString(string: userName ?? "", attributes: [.font: UIFont.systemFont(ofSize: 32, weight: .heavy)])
        attributedText.append(NSAttributedString(string: "  \(ageString)" ,
                                                 attributes: [.font: UIFont.systemFont(ofSize: 24, weight: .regular)]))
        
        let professionString = profession != nil ? "\(profession!)" : "Not available"
        attributedText.append(NSAttributedString(string: "\n\(professionString)", attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .regular)]))
        
        var imagesUrl = [String]()
        
        if let imageOneUrl = imageUrl1 { imagesUrl.append(imageOneUrl) }
        if let imageTwoUrl = imageUrl2 { imagesUrl.append(imageTwoUrl) }
        if let imageThreeUrl = imageUrl3 { imagesUrl.append(imageThreeUrl) }
        
        return CardViewModel(uid: self.uid ?? "", imageNames: imagesUrl,
                             attributedText: attributedText,
                             textAlignment: .left)
    }
}
