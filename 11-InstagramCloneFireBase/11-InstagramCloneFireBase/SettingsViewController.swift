//
//  SettingsViewController.swift
//  11-InstagramCloneFireBase
//
//  Created by Berk Kaya on 24.10.2022.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func logoutClicked(_ sender: Any) {
        do{
            //Cikis yapmak icin hem firebaseden logout yapiyoruz hem de giris sayfasina yonlendiriyoruz.
            try  Auth.auth().signOut()
            self.performSegue(withIdentifier: "toViewController", sender: nil)
        } catch {
            print("error")
        }
       
    }
}
