//
//  CardView.swift
//  SwipeAndMatchTinderApp
//
//  Created by user on 25.08.2021.
//

import UIKit
import SDWebImage


protocol CardViewDelegate {
    func didTapMoreInfo(cardViewModel: CardViewModel)
    func didRemoveCard(_ cardView: CardView)
}

class CardView: UIView {
    
    var delegate: CardViewDelegate?
    
    var nextCardView: CardView?
    
    var cardViewModel: CardViewModel! {
        didSet {
            let imageName = cardViewModel.imageNames.first ?? ""
            if let url = URL(string: imageName) {
                swipingPhotosController.cardViewModel = cardViewModel
            }
            informationLabel.attributedText = cardViewModel.attributedText
            informationLabel.textAlignment = cardViewModel.textAlignment
            
            cardViewModel.imageNames.forEach { _ in
                let barView = UIView()
                barView.backgroundColor = UIColor.init(white: 0, alpha: 0.1)
                barsStackView.addArrangedSubview(barView)
            }
            barsStackView.arrangedSubviews.first?.backgroundColor = .white
            
            setupImageIndexObserver()
        }
    }
    
//    fileprivate let imageView = UIImageView(image: #imageLiteral(resourceName: "lady5c"))
    
    fileprivate let swipingPhotosController = SwipingPhotosViewController(isCardMode: true)
    
    
    fileprivate let informationLabel = UILabel()
    fileprivate let threshold: CGFloat = 100
    fileprivate let gradientLayer = CAGradientLayer()
    fileprivate var barsStackView = UIStackView()
    fileprivate let moreInfoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(
                            named: "info_icon")?.withRenderingMode(.alwaysOriginal),
                        for: .normal)
        button.addTarget(self, action: #selector(handleMoreInfo),
                         for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initialiser
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        
        let pangesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(handlePan))
        addGestureRecognizer(pangesture)
        
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action:
                                        #selector(handleTapGesture(gesture:)))
        addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle methods
    override func layoutSubviews() {
        gradientLayer.frame = self.frame
    }
    
    // MARK: - Methods
    fileprivate func setupLayout() {
        layer.cornerRadius = 10
        clipsToBounds = true
        
        let swipingPhotosView = swipingPhotosController.view!
    
        addSubview(swipingPhotosView)
        swipingPhotosView.fillSuperview()
        
        setupGradientLayer()
//        setupBarStackView()
        
        addSubview(informationLabel)
        informationLabel.anchor(top: nil, leading: leadingAnchor,
                                bottom: bottomAnchor,
                                trailing: trailingAnchor,
                                padding: .init(top: 0, left: 16,
                                               bottom: 16, right: 16))
        informationLabel.textColor = .white
        informationLabel.numberOfLines = 0
        
        addSubview(moreInfoButton)
        moreInfoButton.anchor(top: nil,
                              leading: nil,
                              bottom: bottomAnchor,
                              trailing: trailingAnchor,
                              padding: .init(top: 0, left: 0,
                                             bottom: 16, right: 16),
                              size: .init(width: 44, height: 44))
        
    }
    
    fileprivate func setupBarStackView() {
        addSubview(barsStackView)
        barsStackView.anchor(top: topAnchor, leading: leadingAnchor,
                             bottom: nil, trailing: trailingAnchor,
                             padding: .init(top: 8, left: 8,
                                            bottom: 0, right: 8),
                             size: .init(width: 0, height: 4))
        barsStackView.spacing = 4
        barsStackView.distribution = .fillEqually
    }
    
    fileprivate func setupImageIndexObserver() {
        cardViewModel.imageIndexObserver = { [unowned self] (index, imageUrl) in
            guard let url = URL(string: imageUrl ?? "") else { return }

            
            self.barsStackView.arrangedSubviews.forEach { view in
                view.backgroundColor = UIColor.init(white: 0, alpha: 0.1)
            }
            self.barsStackView.arrangedSubviews[index].backgroundColor = .white
        }
    }
    
    // MARK: - Gesture methods
    @objc fileprivate func handleTapGesture(gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: nil)
        let shouldAdvance = tapLocation.x > self.frame.width / 2 ? true : false
        if shouldAdvance {
            cardViewModel.advanceToNextPhoto()
        } else {
            cardViewModel.backToPreviosPhoto()
        }
    }
    
    @objc fileprivate func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            superview?.subviews.forEach({ subview in
                subview.layer.removeAllAnimations()
            })
        case .changed:
            handleChanged(gesture)
        case .ended:
            handleEnded(gesture)
        default:
            ()
        }
    }
    
    fileprivate func handleEnded(_ gesture: UIPanGestureRecognizer) {
        let translationDirection: CGFloat = gesture.translation(in: nil).x > 0 ? 1 : -1
        let shouldDismissCard = abs(gesture.translation(in: nil).x) > threshold
        
        guard let homeController = self.delegate as? HomeController else { return }
        
        if shouldDismissCard {
            if translationDirection == 1 {
                homeController.handleLike()
            } else {
                homeController.handleDislike()
            }
        } else {
            UIView.animate(withDuration: 1, delay: 0,
                           usingSpringWithDamping: 0.6,
                           initialSpringVelocity: 0.1, options: .curveEaseOut) {
                self.transform = .identity
            }
        }
        
//        UIView.animate(withDuration: 1,
//                       delay: 0,
//                       usingSpringWithDamping: 0.6,
//                       initialSpringVelocity: 0.1,
//                       options: .curveEaseOut) {
//            if shouldDismissCard {
//                self.center = CGPoint(x: 151000 * translationDirection, y: 0)
//            } else {
//                self.transform = .identity
//            }
//        } completion: { _ in
//            self.transform = .identity
//            if shouldDismissCard {
//                self.removeFromSuperview()
//                self.delegate?.didRemoveCard(self)
//            }
//        }
    }
    
    fileprivate func handleChanged(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: nil)
        let degrees: CGFloat = translation.x / 20
        let angle = degrees * .pi / 180
        
        let rotationalTransformation = CGAffineTransform(rotationAngle: angle)
        self.transform = rotationalTransformation.translatedBy(x: translation.x, y: translation.y)
    }
    
    @objc fileprivate func handleMoreInfo() {
        self.delegate?.didTapMoreInfo(cardViewModel: self.cardViewModel)
    }
    
    // MARK: - Gradient
    fileprivate func setupGradientLayer() {
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.5, 1.1]
        layer.addSublayer(gradientLayer)
    }
    

    
}
