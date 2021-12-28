//
//  UserDetailsControllerViewController.swift
//  SwipeAndMatchTinderApp
//
//  Created by user on 10.09.2021.
//

import UIKit
import SwiftUI

class UserDetailsController: UIViewController {
    
    // MARK: - Properties
    var cardViewModel: CardViewModel! {
        didSet {
            infoLabel.attributedText = cardViewModel.attributedText
            swipingImageController.cardViewModel = cardViewModel
        }
    }
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = self
        return scrollView
    }()
    
    let swipingImageController = SwipingPhotosViewController()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    let dismissButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "dismiss_down_arrow").withRenderingMode(.alwaysOriginal),
                        for: .normal)
        button.addTarget(self, action: #selector(handleDismiss),
                         for: .touchUpInside)
        button.layer.zPosition = 1
        return button
    }()
    
    lazy var dislikeButton = self.createButton(
        image: UIImage(named: "dismiss_circle")!,
        selector: #selector(handleDislike))
    
    lazy var superLikeButton = self.createButton(
        image: UIImage(named: "super_like_circle")!,
        selector: #selector(handleDislike))
    
    lazy var likeButton = self.createButton(
        image: UIImage(named: "like_circle")!,
        selector: #selector(handleDislike))
    
    @objc fileprivate func handleDislike() {
        
    }
    
    fileprivate let extraSwipingHeight: CGFloat = 80
    
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupVisualBlurEffectView()
        setupBottomControls()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let swipingView = swipingImageController.view!
        
        scrollView.addSubview(swipingView)
        swipingView.frame = CGRect(x: 0, y: 0,
                                   width: view.frame.width,
                                   height: view.frame.width + extraSwipingHeight)
    }

    // MARK: - Methods
    
    fileprivate func setupLayout() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.fillSuperview()
        
        let swipingView = swipingImageController.view!
        scrollView.addSubview(swipingView)
        
        scrollView.addSubview(infoLabel)
        infoLabel.anchor(top: swipingView.bottomAnchor,
                         leading: scrollView.leadingAnchor,
                         bottom: nil,
                         trailing: scrollView.trailingAnchor,
                         padding: .init(top: 16, left: 16,
                                        bottom: 0, right: 16))
        
        scrollView.addSubview(dismissButton)
        dismissButton.anchor(top: swipingView.bottomAnchor,
                             leading: nil,
                             bottom: nil,
                             trailing: view.trailingAnchor,
                             padding: .init(top: -25,
                                            left: 0,
                                            bottom: 0,
                                            right: 24),
                             size: .init(width: 50, height: 50))
    }
    
    @objc fileprivate func handleDismiss() {
        self.dismiss(animated: true)
    }
    
    fileprivate func setupVisualBlurEffectView() {
        let blurEffect = UIBlurEffect(style: .regular)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        
        view.addSubview(visualEffectView)
        visualEffectView.anchor(top: view.topAnchor,
                                leading: view.leadingAnchor,
                                bottom: view.safeAreaLayoutGuide.topAnchor,
                                trailing: view.trailingAnchor)
        
    }
    
    fileprivate func setupBottomControls() {
        let stackView = UIStackView(arrangedSubviews: [dislikeButton,
                                                       superLikeButton,
                                                       likeButton])
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        stackView.anchor(top: nil, leading: nil,
                         bottom: view.safeAreaLayoutGuide.bottomAnchor,
                         trailing: nil,
                         padding: .init(top: 0, left: 0, bottom: 0, right: 0),
                         size: CGSize(width: 300, height: 80))
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            .isActive = true
    }
    
    fileprivate func createButton(image: UIImage, selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal),
                        for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }

}


// MARK: - extension UIScrollViewDelegate
extension UserDetailsController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let changeY = -scrollView.contentOffset.y
        var width = view.frame.width + changeY * 2
        width = max(view.frame.width, width)
        
        let swipingView = swipingImageController.view!
        
        swipingView.frame = CGRect(x: min(0, -changeY),
                                 y: min(0, -changeY),
                                 width: width,
                                 height: width + extraSwipingHeight)
        
    }
}


