//
//  PhotoController.swift
//  SwipeAndMatchTinderApp
//
//  Created by user on 30.09.2021.
//

import UIKit


class PhotoController: UIViewController {
        
    let imageView = UIImageView(image: UIImage(named: "jane1"))
    
    // MARK: - Initialiser
    init(imageUrl: String) {
        if let url = URL(string: imageUrl) {
            imageView.sd_setImage(with: url, completed: nil)
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        imageView.fillSuperview()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }
}
