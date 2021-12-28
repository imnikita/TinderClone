//
//  RegistrationViewModel.swift
//  SwipeAndMatchTinderApp
//
//  Created by user on 29.08.2021.
//

import UIKit
import Firebase


class RegistrationViewModel {
    
    // MARK: - Properties
    var fullName: String? { didSet { checkFormValidity() }}
    var email: String? { didSet { checkFormValidity() }}
    var password: String? { didSet { checkFormValidity() }}
    var bindableIsFormValid = Bindable<Bool>()
    var bindableImage = Bindable<UIImage>()
    var bindableIsRegistering = Bindable<Bool>()
    
    // MARK: - Methods
    func checkFormValidity() {
        let isFormValid = fullName?.isEmpty == false &&
        email?.isEmpty == false && password?.isEmpty == false && bindableImage.value != nil
        bindableIsFormValid.value = isFormValid
    }
    
    func performRegistration(completion: @escaping (Error?) -> Void) {
        bindableIsRegistering.value = true
        guard let email = email, let password = password else { return }
        Auth.auth().createUser(withEmail: email,
                               password: password) { result, error in
            if let error = error {
                completion(error)
                return
            }
            self.saveImageToFirebase(completion: completion)
        }
    }
    
    fileprivate func saveImageToFirebase(completion: @escaping (Error?) -> Void) {
        let fileName = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(fileName)")
        guard let imageData = self
                .bindableImage.value?.jpegData(compressionQuality: 0.75) else {
            return
        }
        ref.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(error)
                return
            }
            ref.downloadURL { url, error in
                if let error = error {
                    completion(error)
                    return
                }
                self.bindableIsRegistering.value = false
                guard let imageUrl = url?.absoluteString else { return }
                self.saveUserToFirestore(imageUrl: imageUrl, completion: completion)
            }
        }
    }
    
    fileprivate func saveUserToFirestore(imageUrl: String, completion: @escaping (Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let documentData:  [String : Any] = ["fullName": fullName ?? "",
                            "uid": uid,
                            "imageUrl1": imageUrl,
                            "age": 18,
                            "minSeekingAge" : SettingsController.minSeekingAge,
                            "minSeekingAge" : SettingsController.maxSeekingAge]
        Firestore.firestore().collection("users").document(uid)
            .setData(documentData) { error in
                if let error = error {
                    completion(error)
                    return
                }
                completion(nil)
            }
    }
    
}
