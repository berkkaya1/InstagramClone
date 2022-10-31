//
//  FeedViewController.swift
//  11-InstagramCloneFireBase
//
//  Created by Berk Kaya on 24.10.2022.
//

import UIKit
import Firebase
import SDWebImage

class FeedViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {

    
   
    @IBOutlet weak var tableView: UITableView!
    
    var userEmailArray = [String]()
    var userCommentArray = [String]()
    var likeArray = [Int]()
    var userImageArray = [String]()
    var documentIDArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        
        getDataFromFireStore()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userEmailArray.count
    }
    
    //Table view'e prototype cell ekledigimiz icin farkli bir sey yazıyoruz.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedCell
        cell.userEmailLabel.text = userEmailArray[indexPath.row]
        cell.likeLabel.text = String(likeArray[indexPath.row])
        cell.commentLabel.text = userCommentArray[indexPath.row]
        //async olarak yapmamız gerekiyor image'i indirip uygulamaya yüklememiz gerekiyor. Harici kutuphane
        //kullanacagiz. (SDWEBIMAGE)
        cell.userImageView.sd_setImage(with: URL(string: userImageArray[indexPath.row]))
        //her posta ozel document id yi alıp labele yerlestirdik (cell icinde hidden label olarak tanimladik)
        //bunun amaci like' butonuna basilinca uniq id kullanarak o posta like attirmak sadece.
        cell.documentIdLabel.text = documentIDArray[indexPath.row]
        return cell
    }
    
    //anlik data cekmek:
    func getDataFromFireStore(){
        let fireStoreDatabase = Firestore.firestore()
        //filtreleme yaparak gostermek icin orderby ekledik (azalarak gitmesi icin descending true)
        fireStoreDatabase.collection("Posts").order(by: "date",descending: true).addSnapshotListener { snapshot, error in
            if error != nil {
                //print(error?.localizedDescription)
            }else{
                if snapshot?.isEmpty != true && snapshot != nil {
                    self.userImageArray.removeAll(keepingCapacity: false)
                    self.userEmailArray.removeAll(keepingCapacity: false)
                    self.userCommentArray.removeAll(keepingCapacity: false)
                    self.likeArray.removeAll(keepingCapacity: false)
                    self.documentIDArray.removeAll(keepingCapacity: false)
                    
                    for document in snapshot!.documents {
                      let documentID = document.documentID
                        self.documentIDArray.append(documentID)
                        
                       // print(documentID)
                        
                        if let postedBy =  document.get("postedBy") as? String {
                            self.userEmailArray.append(postedBy)
                        }
                        if let postComment = document.get("postComment") as? String {
                            self.userCommentArray.append(postComment)
                        }
                        if let likes = document.get("likes") as? Int {
                            self.likeArray.append(likes)
                        }
                        if let imageURL = document.get("imageURL") as? String {
                            self.userImageArray.append(imageURL)
                        }
                    }
                    
                    self.tableView.reloadData()
                    
                    
                }
               
            }
        }
        
    }

}
