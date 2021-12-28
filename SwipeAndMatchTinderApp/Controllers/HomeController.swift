//
//  ViewController.swift
//  SwipeAndMatchTinderApp
//
//  Created by user on 25.08.2021.
//

import UIKit
import Firebase
import JGProgressHUD


class HomeController: UIViewController {
    
    let topStackView = TopNavigationStackView()
    let cardDeckView = UIView()
    let bottomsControl = HomeBottomControlsStackView()
    var cardViewModels = [CardViewModel]()
    var lastFetchedUser: User?
    var currentUser: User?
    let hud = JGProgressHUD(style: .dark)
    var topCardView: CardView?
    var swipes = [String: Int]()
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        topStackView.settingsButton.addTarget(self,
                                              action: #selector(handleSettings),
                                              for: .touchUpInside)
        bottomsControl.refreshButton.addTarget(self,
                                               action: #selector(handleRefresh),
                                               for: .touchUpInside)
        bottomsControl.likeButton.addTarget(self, action: #selector(handleLike),
                                            for: .touchUpInside)
        
        bottomsControl.dislikeButton.addTarget(self, action: #selector(handleDislike),
                                               for: .touchUpInside)
        fetchCurrentUser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser == nil {
            let registrationController = RegistrationViewController()
            registrationController.delegate = self
            let navController = UINavigationController(rootViewController: registrationController)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
        }
    }
    
    // MARK: - Methods
    fileprivate func setupLayout() {
        let overallStackView = UIStackView(arrangedSubviews:
                                            [topStackView,
                                             cardDeckView,
                                             bottomsControl])
        overallStackView.axis = .vertical
        
        view.addSubview(overallStackView)
        view.backgroundColor = .white
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                leading: view.leadingAnchor,
                                bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                trailing: view.trailingAnchor)
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: 0, left: 12,
                                               bottom: 0, right: 12)
        
        overallStackView.bringSubviewToFront(cardDeckView)
    }
    
    fileprivate func setupFirestoreUserCards() {
        cardViewModels.forEach { card in
            let cardView = CardView(frame: .zero)
            cardView.cardViewModel = card
            cardDeckView.addSubview(cardView)
            cardView.fillSuperview()
        }
    }
    
    @objc fileprivate func handleSettings() {
        let settingsController = SettingsController()
        settingsController.delegate = self
        let navigationController = UINavigationController(rootViewController:
                                                            settingsController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
        
    }
    
    @objc fileprivate func handleRefresh() {
        fetchUsersFromFirestore()
    }
    
    fileprivate func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid)
            .getDocument { snapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                guard let userDict = snapshot?.data() else { return }

                self.currentUser = User(dictionary: userDict)
                self.fetchSwipes()
        }
    }
    
    fileprivate func fetchSwipes() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("swipes").document(uid)
            .getDocument { snapshot, error in
                if let error = error {
                    print("error occurred:", error.localizedDescription)
                    return
                }
                
                guard let data = snapshot?.data() else { print("fuck"); return }
                self.swipes = (data as? [String: Int])!
                print(self.swipes)
                self.fetchUsersFromFirestore()
                
            }
    }
    
    fileprivate func fetchUsersFromFirestore() {
        let minAge = currentUser?.minSeekingAge ?? 18
        let maxAge = currentUser?.maxSeekingAge ?? 100
        
        hud.textLabel.text = "Fetching users"
        hud.show(in: view)
        
        let query = Firestore.firestore().collection("users")
            .whereField("age", isGreaterThanOrEqualTo: minAge)
            .whereField("age", isLessThanOrEqualTo: maxAge)
        topCardView = nil
        query.getDocuments { snapshot, error in
            self.hud.dismiss()
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            var previousCardView: CardView?
            
            snapshot?.documents.forEach({ documentSnapshot in
                
                let userDict = documentSnapshot.data()
                let user = User(dictionary: userDict)
                let isNotCurrentUser = user.uid != Auth.auth().currentUser?.uid
                let hasNotSwipedBefore = self.swipes[user.uid!] == nil
                
                if isNotCurrentUser && hasNotSwipedBefore {
                    let cardView = self.setupCardFromUser(user: user)
                    
                    previousCardView?.nextCardView = cardView
                    previousCardView = cardView
                    
                    if self.topCardView == nil {
                        self.topCardView = cardView
                    }
                }
            })
        }
    }
    
    fileprivate func saveSwipeToFirestore(_ didLike: Int) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let cardUid = topCardView?.cardViewModel.uid else { return }
        
        let documentData = [cardUid : didLike]
        
        Firestore.firestore().collection("swipes")
            .document(uid).getDocument { snapshot, error in
                if let error = error {
                    print("error occured:", error.localizedDescription)
                    return
                }
                
                if snapshot?.exists == true {
                    Firestore.firestore().collection("swipes").document(uid)
                        .updateData(documentData) { error in
                            if let error = error {
                                print("error occured:", error.localizedDescription)
                            }
                            self.checkIfMatchExists(cardUID: cardUid)
                        }
                } else {
                    Firestore.firestore().collection("swipes").document(uid)
                        .setData(documentData) { error in
                            if let error = error {
                                print("error occured:", error.localizedDescription)
                            }
                            self.checkIfMatchExists(cardUID: cardUid)
                        }
                }
                
            }
    }
    
    @objc func handleLike() {
        saveSwipeToFirestore(1)
        performSwipeAnimation(translation: 700, angle: 15)
    }
    
    @objc func handleDislike() {
        saveSwipeToFirestore(0)
        performSwipeAnimation(translation: -700, angle: -15)
    }
    
    fileprivate func checkIfMatchExists(cardUID: String) {
        print("fired")
        
        Firestore.firestore().collection("swipes").document(cardUID)
            .getDocument { snapshot, error in
                if let error = error {
                    print("error occured:", error.localizedDescription)
                    return
                }
                guard let data = snapshot?.data() else { return }
                guard let uid = Auth.auth().currentUser?.uid else { return }
                let hasMatches = data[uid] as? Int == 1
                
                if hasMatches {
                    print("has match")
                    let hud = JGProgressHUD(style: .dark)
                    hud.textLabel.text = "It's a match"
                    hud.show(in: self.view)
                    
                    hud.dismiss(afterDelay: 3)
                    
                }
            }
    }
    
    fileprivate func performSwipeAnimation(translation: CGFloat, angle: CGFloat) {
        let duration = 0.5
        
        let translationAnimation = CABasicAnimation(keyPath: "position.x")
        translationAnimation.toValue = translation
        translationAnimation.duration = duration
        translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        translationAnimation.fillMode = .forwards
        translationAnimation.isRemovedOnCompletion = false
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = angle * CGFloat.pi / 180
        rotationAnimation.duration = duration
        
        let cardView = topCardView
        topCardView = cardView?.nextCardView
        
        CATransaction.setCompletionBlock {
            cardView?.removeFromSuperview()
        }
        
        cardView?.layer.add(translationAnimation, forKey: "translation")
        cardView?.layer.add(rotationAnimation, forKey: "rotation")
        
        CATransaction.commit()
    }
    
    fileprivate func setupCardFromUser(user: User) -> CardView {
        let cardView = CardView(frame: .zero)
        cardView.delegate = self
        cardView.cardViewModel = user.toCardViewModel()
        cardDeckView.addSubview(cardView)
        cardDeckView.sendSubviewToBack(cardView)
        cardView.fillSuperview()
        return cardView
    }
    
}


// MARK: - SettingsControllerDelegate
extension HomeController: SettingsControllerDelegate {
    func didSaveSettings() {
        fetchCurrentUser()
    }
}

// MARK: - CardViewDelegate
extension HomeController: CardViewDelegate {
    
    func didTapMoreInfo(cardViewModel: CardViewModel) {
        let userDetailsController = UserDetailsController()
        userDetailsController.cardViewModel = cardViewModel
        userDetailsController.modalPresentationStyle = .fullScreen
        present(userDetailsController, animated: true)
    }
    
    func didRemoveCard(_ cardView: CardView) {
        self.topCardView?.removeFromSuperview()
        self.topCardView = self.topCardView?.nextCardView
    }
    
}

// MARK: - LoginControllerDelegate
extension HomeController: LoginControllerDelegate {
    func didFinishLoggingIn() {
        fetchCurrentUser()
    }
}





