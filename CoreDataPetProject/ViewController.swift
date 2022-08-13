//
//  ViewController.swift
//  CoreDataPetProject
//
//  Created by Антон Филиппов on 08.08.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    // MARK: Fields
    var context: NSManagedObjectContext!
    lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .none
        return df
    }()
    var selectedCar: Car!
    
    // MARK: IBOutlets
    @IBOutlet weak var segmentedControl: UISegmentedControl! {
        didSet {
            updeateSegmentedControl()
        }
    }
    @IBOutlet weak var markLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var carImageVIew: UIImageView!
    @IBOutlet weak var lastStartedLabel: UILabel!
    @IBOutlet weak var numberOfTripsLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var myChoiseImage: UIImageView!
    
    // MARK: IBActions
    @IBAction func segmentedControlPressed(_ sender: UISegmentedControl) {
        updeateSegmentedControl()
        segmentedControl.selectedSegmentTintColor = .white
        let whiteTextAttribute = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let blackTextAttribute = [NSAttributedString.Key.foregroundColor: UIColor.black]
        UISegmentedControl.appearance().setTitleTextAttributes(whiteTextAttribute, for: .normal)
        UISegmentedControl.appearance().setTitleTextAttributes(blackTextAttribute, for: .selected)
    }
    
    @IBAction func startEngineButtonPressed() {
        selectedCar.timesDriven += 1
        selectedCar.lastStarted = Date()
        do {
            try context.save()
            insertDataFrom(seletedCar: selectedCar)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func rateButtonPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Rate it", message: "Rate this car, please", preferredStyle: .alert)
        let rateAction = UIAlertAction(title: "Rate", style: .default) { action in
            if let text = alertController.textFields?.first?.text {
                self.update(rating: (text as NSString).doubleValue)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        alertController.addTextField { textField in
            textField.keyboardType = .numberPad
        }
        alertController.addAction(rateAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func updeateSegmentedControl() {
        let fetchRequest: NSFetchRequest<Car> = Car.fetchRequest()
        let mark = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)
        fetchRequest.predicate = NSPredicate(format: "mark == %@", mark!)
        
        do {
            let res = try context.fetch(fetchRequest)
            selectedCar = res.first
            insertDataFrom(seletedCar: selectedCar!)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    
    // MARK: Work with file data
    private func insertDataFrom(seletedCar car: Car) {
        carImageVIew.image = UIImage(data: car.imageData!)
        markLabel.text = car.mark
        modelLabel.text = car.model
        myChoiseImage.isHidden = !(car.myChoice)
        ratingLabel.text = "\(car.myRating)/10.0"
        numberOfTripsLabel.text = "\(car.timesDriven)"
        lastStartedLabel.text = "\(dateFormatter.string(from: car.lastStarted!))"
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
    
    // MARK: Utility
    private func getColorDictionary(_ colorDictionary: [String : Float]) -> UIColor {
        guard let red = colorDictionary["red"],
              let green = colorDictionary["green"],
              let blue = colorDictionary["blue"] else { return UIColor() }
        
        return UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1.0)
    }
    
    private func findAllCars() -> [Car] {
        let fetchRequest: NSFetchRequest<Car> = Car.fetchRequest()
        do {
            let res = try context.fetch(fetchRequest)
            return res
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return []
    }
    
    private func findBestCar(from allCars: [Car]) -> Car? {
        var maxRating = allCars.first?.myRating
        var bestCar: Car?
        for car in allCars {
            if (maxRating != nil) && car.myRating >= maxRating! {
                bestCar = car
                maxRating = car.myRating
            }
        }
        return bestCar
    }
    
    private func update(rating: Double) {
        selectedCar.myRating = rating
        let allCars = findAllCars()
        let bestCar = findBestCar(from: allCars)
        for car in allCars {
            car.myChoice = bestCar == nil ? false : car == bestCar
        }
        do {
            try context.save()
            insertDataFrom(seletedCar: selectedCar)
        } catch let error as NSError {
            let alertController = UIAlertController(title: "Wrong value", message: "Wrong input", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default)
            alertController.addAction(okAction)
            present(alertController, animated: true)
            print(error.localizedDescription)
        }
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ratingLabel.adjustsFontSizeToFitWidth = true
        ratingLabel.minimumScaleFactor = 0.2
        
        lastStartedLabel.adjustsFontSizeToFitWidth = true
        lastStartedLabel.minimumScaleFactor = 0.2
        
        numberOfTripsLabel.adjustsFontSizeToFitWidth = true
        numberOfTripsLabel.minimumScaleFactor = 0.2
        
        
        getDataFromFile()
        
        
        
        
    }
    
    
}

