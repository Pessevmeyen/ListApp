//
//  ViewController.swift
//  ListApp
//
//  Created by Furkan Eruçar on 4.04.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var ac = UIAlertController()
    
    @IBOutlet weak var tableView: UITableView!
    
    var data = [NSManagedObject]() // Burda data'mız [String]'di fakat core Data kullandığımız için artık string array'i tutmayacağız. NSObject dediğimiz entitiy'lerin kod tarafında karşılığı olan veri tipini array olarak tutacağız.
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Şimdi de veritabanındaki veriyi kullanıcıya çekmemiz gerek.
        
        fetch()
        
        
    }
    
    
    
    @IBAction func didRemoveBarButtonItemTapped(_ sender: UIBarButtonItem) {
        presentAlert(title: "Uyarı!", message: "Listedeki bütün öğeleri silmek istediğinize emin misiniz?", defaultButtonTitle: "Evet", cancelButtonTitle: "Vazgeç") { _ in
            self.data.removeAll()
            self.tableView.reloadData()
        }

    }
    

    @IBAction func addBarButtonItemTapped(_ sender: UIBarButtonItem) {
        
        presentAddAlert()
        
    }
    
    // Yukarıda gene çok fazla alert gösterdik, bunu gene bir fonksiyona bağlarsak kod fazlalığından kurtuluruz.
    
    func presentAddAlert() {
        
        presentAlert(title: "Yeni eleman ekle", message: nil, defaultButtonTitle: "Ekle", cancelButtonTitle: "Vazgeç", isTextFieldAvaible: true, defaultButtonHandler: { _ in
            let text = self.ac.textFields?.first?.text
            if text != "" {
              
                // Burda kayıt işlemini yapacağız.
                
                let appDelegate = UIApplication.shared.delegate as? AppDelegate // Öncelikle ManagedObjectContext'e ulaşmamız lazım. Bu bizim veri tabanımız. Veri tabanımıza erişeceğiz ve oraya bilgiyi kaydedeceğiz.
                
                let managedObjectContext = appDelegate?.persistentContainer.viewContext // Burda da artık managedObjectContext dediğimiz nesne bizim veri tabanımızın ta kendisi. Artık bunun içine verileri kaydedebiliriz.
                
                let entity = NSEntityDescription.entity(forEntityName: "ListItem", in: managedObjectContext!) // Şimdi veri tabanımıza kaydedeğimiz entitiy'lerimizi oluşturmamız gerek. in: "<#T##NSManagedObjectContext#>" daha önce yaptığımız gibi gene bu tipi yukarda tanımladığımız için buraya yazıyoruz
                
                let listItem = NSManagedObject(entity: entity!, insertInto: managedObjectContext) // Şimdi de entity'nin hangi değerini değiştireceğimizi söyleyeceğiz. Çünkü içinde birden çok attribute olabilir. insertInto: nereye kaydediyor demek. Burda managedObjectContext veri tabanına kaydedeceğiz.
                
                listItem.setValue(text, forKey: "title")// şimdi burda title value'suna yukarda aldığımız "text" değerini atayarak veri tabanındaki değerini değiştireceğiz. Burda listItem'in "title" attribute'una text'i atayacak.
                // Veri tabanına atadık fakat bunları save etmek için bir save işlemi yapmamız gerek.
                
                try? managedObjectContext?.save()
                
                self.fetch()
            } else {
                self.presentWarningAlert()
            }
        })
    }
    
    func presentWarningAlert() {
        
        presentAlert(title: "Uyarı", message: "Liste elemanı boş olamaz!", cancelButtonTitle: "Tamam")
        
    }
    
    func presentAlert(title: String?, message: String?, preferredStyle: UIAlertController.Style = .alert, defaultButtonTitle: String? = nil,  cancelButtonTitle: String?, isTextFieldAvaible: Bool = false, defaultButtonHandler: ((UIAlertAction) -> Void)? = nil) {
        
        ac = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        
        if defaultButtonTitle != nil {
            let defaultButton = UIAlertAction(title: defaultButtonTitle, style: .default, handler: defaultButtonHandler)
            ac.addAction(defaultButton)
        }
        
        
        let cancelButton = UIAlertAction(title: cancelButtonTitle, style: .cancel)
        
        if isTextFieldAvaible {
            ac.addTextField()
        }
        
        ac.addAction(cancelButton)
        present(ac, animated: true)
    }
    
    func fetch() {
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        let managedObjectContext = appDelegate?.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ListItem") // Burda bir veri çekme isteği oluşturduk. Şimdi bu isteği göndereceğiz.
        data = try! managedObjectContext!.fetch(fetchRequest)
        
        tableView.reloadData()
        
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        let listItem = data[indexPath.row]
        cell.textLabel?.text = listItem.value(forKey: "title") as? String // Attribute'umuzun adını buraya yazıyoruz. Burda value'mizin değerini bilmediği için cast yapmamızı istiyor.
        return cell // Bunu daha önce çok yaptık fakat burda yeni bir bilgi geldi. return değeri UITableViewCell'den olmalı fakat direk return UITableViewCell tipi olarak döndüremeyiz. Bunu bir nesneye, objeye bağlamamız lazım. O yüzden değişken atayarak nesneleştiriyoruz. ya da direk return UITableViewCell() olarak yazabiliriz. Burda init ettiği için bir obje olarak return edecek.
    }
    
    // Şimdi de satırı sola kaydırdığımızda çıkacak seçenekleri oluşturalım.
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? { // Sağ taraftan swipe ettiğimizde çıkacak seçenekleri oluşturuyor. bi de leadingSwipeActionsConfigurationForRowAt var o da sol taraftanı. Ve return tipi olarak bi tane UISwipeActionsConfiguration bekliyor.
        
        let deleceAction = UIContextualAction(style: .normal, title: "Sil") { _, _, _ in
            // self.data.remove(at: indexPath.row) // ilgili row'daki item'i silecek.
            let appDelegate = UIApplication.shared.delegate as? AppDelegate // Öncelikle ManagedObjectContext'e ulaşmamız lazım. Bu bizim veri tabanımız. Veri tabanımıza erişeceğiz ve oraya bilgiyi kaydedeceğiz.
            
            let managedObjectContext = appDelegate?.persistentContainer.viewContext // Burda da artık managedObjectContext dediğimiz nesne bizim veri tabanımızın ta kendisi. Artık bunun içine verileri kaydedebiliriz.
            
            managedObjectContext?.delete(self.data[indexPath.row])
            
            try? managedObjectContext?.save()
            
            self.fetch()
            
        } // Aşağıda actions: tipini buraya yazıyoruz.
        
        deleceAction.backgroundColor = .systemRed
        
        // şimdi de düzenleme kısmı
        let editAction = UIContextualAction(style:.normal, title: "Düzenle") { _, _, _ in
            self.presentAlert(title: "Elemanı Düzenle", message: nil, defaultButtonTitle: "Düzenle", cancelButtonTitle: "Vazgeç", isTextFieldAvaible: true, defaultButtonHandler: { _ in
                let text = self.ac.textFields?.first?.text
                if text != "" {
                    // self.data[indexPath.row] = text! Artık direk verinin kendinisi değil veri tabanını editleyeceğiz.
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate // Öncelikle ManagedObjectContext'e ulaşmamız lazım. Bu bizim veri tabanımız. Veri tabanımıza erişeceğiz ve oraya bilgiyi kaydedeceğiz.
                    
                    let managedObjectContext = appDelegate?.persistentContainer.viewContext // Burda da artık managedObjectContext dediğimiz nesne bizim veri tabanımızın ta kendisi. Artık bunun içine verileri kaydedebiliriz.
                    
                    self.data[indexPath.row].setValue(text, forKey: "title")
                    
                    if managedObjectContext!.hasChanges {
                        try? managedObjectContext?.save()
                    }
                    
                    self.tableView.reloadData()
                } else {
                    self.presentWarningAlert()
                }
            })
        }
        
        let config = UISwipeActionsConfiguration(actions: [deleceAction, editAction]) // Burda bir "<#T##[UIContextualAction]#>" tipinde action tanımlamamızı bekliyor, sohbeti sil bi action, arşivle bir action. O zaman yukarıya bir action nesnesi oluşturucaz.
        
        return config
    }
    
    
    
    
}
