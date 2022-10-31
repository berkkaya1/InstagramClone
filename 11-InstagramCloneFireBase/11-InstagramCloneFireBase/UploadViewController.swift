//
//  UploadViewController.swift
//  11-InstagramCloneFireBase
//
//  Created by Berk Kaya on 24.10.2022.
//

import UIKit
import Firebase

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var uploadButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
    }
    
    //Fotografi seciyoruz.
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    //Fotografi sectikten sonra
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true)
    }
  
    @IBAction func uploadButtonClicked(_ sender: Any) {
        let storage = Storage.storage()
        //hangi klasorle calisacagiz nereye kaydedecegiz onu belirtmek icin.
        //bu komple storage bolumu
        let storageReference = storage.reference()
        //olusturdugumuz media klasorune gitmek icin.
        let mediaFolder = storageReference.child("media")
        
        //dosyayi kayit islemi: (uiimage olarak kaydedemiyoruz data olmasi lazim.)
        if let data = imageView.image?.jpegData(compressionQuality: 0.5){
            //her bir fotografi farkli kaydetmek icin uniq id olusturuyoruz.
            let uuid = UUID().uuidString
            //gorselin referansi.
            let imageReference = mediaFolder.child("\(uuid).jpg")
            imageReference.putData(data) { metadata, error in
                if error != nil {
                    self.makeAlert(titleInput: "Error", messageInput: error?.localizedDescription ?? "Upload is failed")
                }else {
                    imageReference.downloadURL { url, error in
                        if error == nil {
                            let imageURL = url?.absoluteString
                            //print("Yuklenen Fotograf Url: \(imageURL)")
                            
                            //Database islemleri: (kullanici verileri dbye kaydedecek)
                            let firestoreDatabase = Firestore.firestore()
                            var firestoreReference : DocumentReference? = nil
                            let firestorePost = ["imageURL" : imageURL!, "postedBy" : Auth.auth().currentUser!.email!, "postComment" : self.commentTextField.text!,
                                                 "date" : FieldValue.serverTimestamp(), "likes" : 0 ] as [String : Any]
                            
                            firestoreReference = firestoreDatabase.collection("Posts").addDocument(data: firestorePost, completion: { error in
                                if error != nil {
                                    self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error")
                                } else {
                                    self.imageView.image = UIImage(named: "selectImage.jpg")
                                    self.commentTextField.text = ""
                                    self.tabBarController?.selectedIndex = 0
                                }
                            })
                            
                        }
                    }
                }
            }
            
        }
    }
    
    func makeAlert(titleInput: String, messageInput: String){
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
    
}
