//
//  SwipingPhotosViewController.swift
//  SwipeAndMatchTinderApp
//
//  Created by user on 29.09.2021.
//

import UIKit
import SwiftUI

class SwipingPhotosViewController: UIPageViewController {
    
    var cardViewModel: CardViewModel! {
        didSet {
            controllers = cardViewModel.imageNames.map({ (imageUrl) -> UIViewController in
                
                let photoController = PhotoController(imageUrl: imageUrl)
                return photoController
            })
            setViewControllers([controllers.first!], direction: .forward, animated: false)
            
            setupBarViews()
        }
    }
    
    var controllers = [UIViewController]()
    
    fileprivate let barsStackView = UIStackView(arrangedSubviews: [])
    
    var deselectedBarColor = UIColor(white: 0, alpha: 0.1)
    
    fileprivate let isCardMode: Bool
    
    // MARK: - Initialiser
    init(isCardMode: Bool = false) {
        self.isCardMode = isCardMode
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
        if isCardMode {
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        dataSource = self
        delegate = self
        
        if isCardMode {
            disableSwipingAbility()
        }
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:))))
        
    }
    
    fileprivate func disableSwipingAbility() {
        view.subviews.forEach { subview in
            if let subview = subview as? UIScrollView {
                subview.isScrollEnabled = false
            }
        }
    }
    
    @objc fileprivate func handleTap(gesture: UITapGestureRecognizer) {
        let currentController = viewControllers!.first!
        if let index = controllers.firstIndex(of: currentController) {
            
            if gesture.location(in: self.view).x > view.frame.width / 2 {
                let nextIndex = min(index + 1, controllers.count - 1)
                let nextController = controllers[nextIndex]
                setViewControllers([nextController], direction: .forward, animated: false)
                
                barsStackView.arrangedSubviews.forEach { $0.backgroundColor = deselectedBarColor }
                barsStackView.arrangedSubviews[nextIndex].backgroundColor = .white
            } else {
                let previousIndex = max(0, index - 1)
                let previousController = controllers[previousIndex]
                setViewControllers([previousController], direction: .forward, animated: false)
                
                barsStackView.arrangedSubviews.forEach { $0.backgroundColor = deselectedBarColor }
                barsStackView.arrangedSubviews[previousIndex].backgroundColor = .white
            }
            

        }
        
    }
    
    fileprivate func setupBarViews() {
        cardViewModel.imageNames.forEach { _ in
            let barView = UIView()
            barView.backgroundColor = deselectedBarColor
            barView.layer.cornerRadius = 2
            barsStackView.addArrangedSubview(barView)
        }
        
        barsStackView.arrangedSubviews.first?.backgroundColor = .white
        barsStackView.spacing = 8
        barsStackView.distribution = .fillEqually
        view.addSubview(barsStackView)
        
        let paddingTop = isCardMode ? CGFloat(10) : UIApplication.shared.statusBarFrame.height + 8
        
        barsStackView.anchor(top: view.topAnchor,
                             leading: view.leadingAnchor,
                             bottom: nil,
                             trailing: view.trailingAnchor,
                             padding: .init(top: paddingTop, left: 8,
                                            bottom: 0, right: 8),
                             size: .init(width: 0,
                                         height: 4))
        
    }

}

// MARK: - extension SwipingPhotosViewController: UIPageViewControllerDataSource

extension SwipingPhotosViewController: UIPageViewControllerDataSource,
                                        UIPageViewControllerDelegate {
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = controllers.firstIndex(where: { $0 == viewController } ) ?? 0
        if index == controllers.count - 1 { return nil }
        return controllers[index + 1]
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let index = controllers.firstIndex(where: { $0 == viewController } ) ?? 0
        if index == 0 { return nil }
        
        return controllers[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let currentPhotoController = viewControllers?.first
        if let index = controllers.firstIndex(where: { $0 == currentPhotoController }) {
            barsStackView.arrangedSubviews.forEach { $0.backgroundColor = deselectedBarColor }
            barsStackView.arrangedSubviews[index].backgroundColor = .white
        }
    }
    
    
}


