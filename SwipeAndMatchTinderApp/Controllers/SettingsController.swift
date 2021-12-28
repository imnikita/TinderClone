//
//  SettingsController.swift
//  SwipeAndMatchTinderApp
//
//  Created by user on 01.09.2021.
//

import UIKit
import Firebase
import SDWebImage
import JGProgressHUD

// MARK: - SettingsControllerDelegate
protocol SettingsControllerDelegate {
    func didSaveSettings()
}


// MARK: - SettingsController
class SettingsController: UITableViewController {

    
    // MARK: - Properties
    var user: User?
    var delegate: SettingsControllerDelegate?
    
    // MARK: - UI Properties
    lazy var image1Button = createButton(selector: #selector(handleSelectPhoto))
    lazy var image2Button = createButton(selector: #selector(handleSelectPhoto))
    lazy var image3Button = createButton(selector: #selector(handleSelectPhoto))
    
    lazy var header: UIView = {
        let header = UIView()
        let padding: CGFloat = 16
        header.addSubview(image1Button)
        image1Button.anchor(top: header.topAnchor,
                            leading: header.leadingAnchor,
                            bottom: header.bottomAnchor,
                            trailing: nil,
                            padding: .init(top: padding, left: padding,
                                           bottom: padding, right: 0))
        image1Button.widthAnchor.constraint(equalTo: header.widthAnchor,
                                            multiplier: 0.45).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [image2Button,
                                                       image3Button])
        stackView.axis = .vertical
        stackView.spacing = padding
        stackView.distribution = .fillEqually
        
        header.addSubview(stackView)
        stackView.anchor(top: header.topAnchor,
                         leading: image1Button.trailingAnchor,
                         bottom: header.bottomAnchor,
                         trailing: header.trailingAnchor,
                         padding: .init(top: padding, left: padding,
                                        bottom: padding, right: padding))
        return header
    }()
    
    static let minSeekingAge = 18
    static let maxSeekingAge = 100
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .interactive
        
        fetchCurrentUser()
    }
    
    // MARK: - TableView methods
    
    override func tableView(_ tableView: UITableView,
                            viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return header
        }
        
        let sectionLabel = HeaderLabel()
        
        switch section {
        case 1:
            sectionLabel.text = "Name"
        case 2:
            sectionLabel.text = "Profession"
        case 3:
            sectionLabel.text = "Age"
        case 4:
            sectionLabel.text = "Bio"
        default:
            sectionLabel.text = "Seeking age range"
        }
        sectionLabel.font = UIFont.boldSystemFont(ofSize: 16)
        return sectionLabel
        
    }
    
    override func tableView(_ tableView: UITableView,
                            heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? 300 : 40
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 0 : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt
                                indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 5 {
            let ageCell = AgeRangeCell(style: .default, reuseIdentifier: nil)
            ageCell.minSlider.addTarget(self,
                                        action: #selector(handleMinAgeChanged),
                                        for: .valueChanged)
            
            let minSeekingAge = user?.minSeekingAge ?? SettingsController.minSeekingAge
            let maxSeekingAge = user?.maxSeekingAge ?? SettingsController.maxSeekingAge
            
            ageCell.minLabel.text = "Age: \(minSeekingAge)"
            ageCell.minSlider.value = Float(maxSeekingAge)
            
            ageCell.maxSlider.addTarget(self,
                                        action: #selector(handleMaxAgeChanged),
                                        for: .valueChanged)
            ageCell.maxLabel.text = "Age: \(minSeekingAge)"
            ageCell.maxSlider.value = Float(maxSeekingAge)
            return ageCell
        }
        
        let cell = SettingsCell(style: .default, reuseIdentifier: nil)
        
        
        switch indexPath.section {
        case 1:
            cell.textField.placeholder = "Enter your name"
            cell.textField.text = user?.userName
            cell.textField.addTarget(self, action: #selector(handleNameChange),
                                     for: .editingChanged)
        case 2:
            cell.textField.placeholder = "Enter your profession"
            cell.textField.text = user?.profession
            cell.textField.addTarget(self,
                                     action: #selector(handleProfessionChange),
                                     for: .editingChanged)
        case 3:
            cell.textField.placeholder = "Type your age"
            cell.textField.addTarget(self,
                                     action: #selector(handleAgeChange),
                                     for: .editingChanged)
            if let age = self.user?.age {
                cell.textField.text = String(age)
            }
            
        default:
            cell.textField.placeholder = "your bio"

        }
        
        return cell
        
        
    }
    
    // MARK: - Methods
    fileprivate func setupNavigationBar() {
        navigationItem.title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                           style: .plain,
                                                           target: self,
                                                           action:
                                                            #selector(handleCancel))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Save", style: .plain,
                            target: self, action: #selector(handleSave)),
            UIBarButtonItem(title: "Log out", style: .plain,
                            target: self, action: #selector(handleLogOut)),
        ]
    }
    
    @objc fileprivate func handleCancel() {
        self.dismiss(animated: true)
    }
    
    @objc fileprivate func handleLogOut() {
        do {
            try Auth.auth().signOut()
        } catch let error {
            print(error.localizedDescription)
        }
        self.dismiss(animated: true)
    }
    
    @objc fileprivate func handleSave() {
        guard let currentUser = Auth.auth().currentUser?.uid else { return }
        
        let data = [
            "uid": currentUser,
            "fullName": user?.userName ?? "",
            "age": user?.age ?? -1,
            "profession": user?.profession ?? "",
            "imageUrl1": user?.imageUrl1 ?? "",
            "imageUrl2": user?.imageUrl2 ?? "",
            "imageUrl3": user?.imageUrl3 ?? "",
            "minSeekingAge": user?.minSeekingAge ?? -1,
            "maxSeekingAge": user?.maxSeekingAge ?? -1
        ] as [String : Any]
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Saving settings"
        hud.show(in: view)
        
        Firestore.firestore().collection("users")
            .document(currentUser).setData(data) { error in
                hud.dismiss()
                if let error = error {
                    print(error)
                    return
                }
                self.dismiss(animated: true) {
                    self.delegate?.didSaveSettings()
                }
            }
    }
    
    @objc fileprivate func handleNameChange(textField: UITextField) {
        self.user?.userName = textField.text
    }
    
    @objc fileprivate func handleAgeChange(textField: UITextField) {
        self.user?.age = Int(textField.text ?? "")
    }
    
    @objc fileprivate func handleProfessionChange(textField: UITextField) {
        self.user?.profession = textField.text
    }
    
    @objc fileprivate func handleMinAgeChanged(slider: UISlider) {
        let indexPath = IndexPath(row: 0, section: 5)
        let ageRangeCell = tableView.cellForRow(at: indexPath) as! AgeRangeCell
        ageRangeCell.minLabel.text = "Min: \(Int(slider.value))"
        self.user?.minSeekingAge = Int(slider.value)
    }
    
    @objc fileprivate func handleMaxAgeChanged(slider: UISlider) {
        let indexPath = IndexPath(row: 0, section: 5)
        let ageRangeCell = tableView.cellForRow(at: indexPath) as! AgeRangeCell
        ageRangeCell.maxLabel.text = "Max: \(Int(slider.value))"
        self.user?.maxSeekingAge = Int(slider.value)
    }
    
    @objc fileprivate func handleSelectPhoto(button: UIButton) {
        let imagePickerController = CustomImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageButton = button
        present(imagePickerController, animated: true)
    }

    fileprivate func fetchCurrentUser() {
        guard let currentUser = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(currentUser)
            .getDocument { snapshot, error in
                if let error = error {
                    print(error)
                    return
                }
                guard let userDict = snapshot?.data() else { return }
                self.user = User(dictionary: userDict)
                self.loadUserPhotos()
                self.tableView.reloadData()
            }
    }
    
    fileprivate func loadUserPhotos() {
        if let image1Url = user?.imageUrl1, let url = URL(string: image1Url) {
            SDWebImageManager.shared
                .loadImage(with: url, options: .continueInBackground,
                           progress: nil) { image, _, _, _, _, _ in
                    self.image1Button
                        .setImage(image?.withRenderingMode(.alwaysOriginal),
                                  for: .normal)
                }
        }
        
        if let image1Url = user?.imageUrl2, let url = URL(string: image1Url) {
            SDWebImageManager.shared
                .loadImage(with: url, options: .continueInBackground,
                           progress: nil) { image, _, _, _, _, _ in
                    self.image2Button
                        .setImage(image?.withRenderingMode(.alwaysOriginal),
                                  for: .normal)
                }
        }
        
        if let image1Url = user?.imageUrl3, let url = URL(string: image1Url) {
            SDWebImageManager.shared
                .loadImage(with: url, options: .continueInBackground,
                           progress: nil) { image, _, _, _, _, _ in
                    self.image3Button
                        .setImage(image?.withRenderingMode(.alwaysOriginal),
                                  for: .normal)
                }
        }

    }
    
    fileprivate func createButton(selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Select photo", for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        return button
    }
    
}


extension SettingsController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let selectedImage = info[.originalImage] as? UIImage
        let imageButton = (picker as? CustomImagePickerController)?.imageButton
        imageButton?.setImage(selectedImage?.withRenderingMode(.alwaysOriginal),
                              for: .normal)
        dismiss(animated: true)
        
        let fileName = UUID().uuidString
        let reference = Storage.storage()
            .reference(withPath: "/images\(fileName)")
        
        guard let uploadData = selectedImage?
                .jpegData(compressionQuality: 0.75) else { return }
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Uploading image"
        hud.show(in: view)
        reference.putData(uploadData, metadata: nil) { _, error in
            hud.dismiss()
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            reference.downloadURL { url, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                if imageButton == self.image1Button {
                    self.user?.imageUrl1 = url?.absoluteString
                } else if imageButton == self.image2Button {
                    self.user?.imageUrl2 = url?.absoluteString
                } else {
                    self.user?.imageUrl3 = url?.absoluteString
                }
                
            }
        }
    }
}


class CustomImagePickerController: UIImagePickerController {
    var imageButton: UIButton?
}

class HeaderLabel: UILabel {
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.insetBy(dx: 16, dy: 0))
    }
}
