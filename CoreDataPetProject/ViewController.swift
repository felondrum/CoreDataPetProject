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
    
    lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .none
        return df
    }()
    
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
    
    private func insertDataFrom(seletedCar car: Car) {
        carImageVIew.image = UIImage(data: car.imageData!)
        markLabel.text = car.mark
        modelLabel.text = car.model
        myChoiseImage.isHidden = !(car.myChoice)
        ratingLabel.text = "\(car.myRating)/10.0"
        numberOfTripsLabel.text = "\(car.timesDriven)"
        lastStartedLabel.text = "\(dateFormatter.string(from: car.lastStarted!))"
        segmentedControl.tintColor = car.tintColor as? UIColor
    }
    
    
    private func getDataFromFile() {
        
        let fetchRequest: NSFetchRequest<Car> = Car.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "mark != nil")
        
        var records = 0
        
        do {
            records = try context.count(for: fetchRequest)
            print("is data there?")
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        guard records == 0 else { return }
        
        guard let pathToFile = Bundle.main.path(forResource: "data", ofType: "plist"),
              let dataArray = NSArray(contentsOfFile: pathToFile) else { return }
        
        for dictinary in dataArray {
            let entity = NSEntityDescription.entity(forEntityName: "Car", in: context)
            let car = NSManagedObject(entity: entity!, insertInto: context) as! Car
            
            let carDictionary = dictinary as! [String : AnyObject]
            car.mark = carDictionary["mark"] as? String
            car.model = carDictionary["model"] as? String
            car.myRating = carDictionary["rating"] as! Double
            car.lastStarted = carDictionary["lastStarted"] as? Date
            car.timesDriven = carDictionary["timesDriven"] as! Int16
            car.myChoice = carDictionary["myChoice"] as! Bool
            
            if let imageName = carDictionary["imageName"] as? String {
                let image = UIImage(named: imageName)
                let imageData = image?.pngData()
                car.imageData = imageData
            }
            
            if let colorDictionary = carDictionary["tintColot"] as? [String : Float] {
                car.tintColor = getColorDictionary(colorDictionary)
            }
            
        }
        
    }
    
    private func getColorDictionary(_ colorDictionary: [String : Float]) -> UIColor {
        guard let red = colorDictionary["red"],
              let green = colorDictionary["green"],
              let blue = colorDictionary["blue"] else { return UIColor() }
        
        return UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ratingLabel.adjustsFontSizeToFitWidth = true
        ratingLabel.minimumScaleFactor = 0.2
        
        lastStartedLabel.adjustsFontSizeToFitWidth = true
        lastStartedLabel.minimumScaleFactor = 0.2
        
        numberOfTripsLabel.adjustsFontSizeToFitWidth = true
        numberOfTripsLabel.minimumScaleFactor = 0.2
        
        
        getDataFromFile()
        
        let fetchRequest: NSFetchRequest<Car> = Car.fetchRequest()
        let mark = segmentedControl.titleForSegment(at: 0)
        fetchRequest.predicate = NSPredicate(format: "mark == %@", mark!)
        
        do {
            let res = try context.fetch(fetchRequest)
            let selectedCar = res.first
            insertDataFrom(seletedCar: selectedCar!)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        
    }
    
    
}

