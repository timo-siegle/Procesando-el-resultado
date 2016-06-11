//
//  ViewController.swift
//  Procesando el resultado de la peticion
//
//  Created by Timo Siegle on 11.06.16.
//  Copyright © 2016 Timo Siegle. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var titulo: UILabel!
    @IBOutlet weak var autores: UILabel!
    @IBOutlet weak var portada: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let reachability: Reachability
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            return false
        }
        
        if reachability.isReachable() {
            self.fetchBookDetails(textField.text!)
        } else {
            
            // En caso de falla en Internet, se muestra una alerta indicando ese problema
            let alertController = UIAlertController(title: "Internet connection", message:
                "Please check your connection and try again!", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        return true
    }
    
    func fetchBookDetails(isbn: String) {
        
        titulo.text = "-"
        autores.text = "-"
        portada.image = nil
        
        let urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:\(isbn)"
        let url = NSURL(string: urls)
        let datos = NSData(contentsOfURL: url!)
    
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(datos!, options: NSJSONReadingOptions.MutableLeaves)
            let dico1 = json as! NSDictionary
            if dico1.allKeys.count > 0 {
                let dico2 = dico1["ISBN:\(isbn)"] as! NSDictionary
                titulo.text = dico2["title"] as! NSString as String
                
                let dico3 = dico2["cover"] as! NSDictionary
                let portadaString = dico3["large"] as! NSString as String

                let portadaUrl = NSURL(string: portadaString)
                let portadaData = NSData(contentsOfURL: portadaUrl!)
                portada.image = UIImage(data: portadaData!)
                
                var names = ""
                if dico2["authors"]?.count > 0 {
                    let dico4 = dico2["authors"] as! NSArray
                    let firstElem = dico4[0] as! NSDictionary
                    names = firstElem["name"] as! NSString as String
                    for item in dico4.dropFirst() {
                        let obj = item as! NSDictionary
                        let name = obj["name"] as! NSString as String
                        names += ", " + name
                    }
                } else {
                    names = "-"
                }
                autores.text = names
            }
        } catch {
            
        }
    }
}

