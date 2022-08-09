//
//  ViewController.swift
//  CoreDataPetProject
//
//  Created by Антон Филиппов on 08.08.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController {

     var context: NSManagedObjectContext!
    
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var markLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var carImageVIew: UIImageView!
    @IBOutlet weak var lastStartedLabel: UILabel!
    @IBOutlet weak var numberOfTripsLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var myChoiseImage: UIImageView!
    
    @IBAction func segmentedControlPressed(_ sender: UISegmentedControl) {
    }
    
    
    @IBAction func startEngineButtonPressed() {
    }
    
    @IBAction func rateButtonPressed(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

