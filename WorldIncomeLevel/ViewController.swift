//
//  ViewController.swift
//  WorldIncomeLevel
//
//  Created by Jo Thorpe on 10/8/15.
//  Copyright © 2015 Metropolis Studios LTD. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, UIPopoverPresentationControllerDelegate {
    
    var contentController : UITableViewController!
    var areaListTable: UITableView!
    var selectedItemIndex: Int!
     var locationManager: CLLocationManager!
    
    
    
    
    var regionNames = [
        "Prok & Fitch - One of These Days"
    ]
    
    var regionCodes = [
        "1"
    ]
    
    
    @IBOutlet var areaListBtn: UIBarButtonItem!
    @IBOutlet var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        contentController = UITableViewController()
        areaListTable = UITableView()
        areaListTable.dataSource = self
        areaListTable.delegate = self
        contentController.tableView = areaListTable
        selectedItemIndex = -1
        mapView.delegate = self
    }

    @IBAction func showAreaList(_ sender: AnyObject) {
        contentController.modalPresentationStyle = UIModalPresentationStyle.popover
        let popOverPC: UIPopoverPresentationController = contentController.popoverPresentationController!
        popOverPC.barButtonItem = areaListBtn
        popOverPC.permittedArrowDirections = UIPopoverArrowDirection.any
        popOverPC.delegate = self
        present(contentController, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
//MARK: Table View
    func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell{
            
            var cell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier")
            if cell == nil{
                cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "cellIdentifier")
                cell.textLabel?.text = regionNames[indexPath.row]
            }
            cell.accessoryType = UITableViewCellAccessoryType.none
            return cell
    }
    func tableView(_ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int{
            return regionNames.count
    }
    
    
    //
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle{
        return .fullScreen
    }
    func presentationController(_ controller: UIPresentationController,
        viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController?{
            let navController:UINavigationController = UINavigationController(rootViewController: controller.presentedViewController)
        controller.presentedViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action:#selector(done))
            areaListTable.reloadData()
            selectedItemIndex = -1
            return navController
    }
    
    func done (){
        presentedViewController?.dismiss(animated: true, completion: nil)
        mapSearch()
    }
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController){
        mapSearch()
    }
    
    //MARK: UITableView Delegate
    func tableView(_ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath){
            let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
            selectedCell.accessoryType = UITableViewCellAccessoryType.checkmark
            selectedItemIndex = indexPath.row
    }
    func tableView(_ tableView: UITableView,
        didDeselectRowAt indexPath: IndexPath){
            let deselectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
            deselectedCell.accessoryType = UITableViewCellAccessoryType.none
    }
    
    //
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController){
        areaListTable.reloadData()
        selectedItemIndex = -1
    }
    
    //
    func mapSearch(){
        if selectedItemIndex == -1{
            return
        }
        //Map search for Level Income in the selected region area
        let url = URL(string: "http://www.thisismetropolis.com/jaysontest/index2.json")
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil{
                print("no internet")
            }
            else
                if let content = data
                {
                    
                    do {
                        print("ok")
                        let json = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        print(json)
                        let dataArray = json.object(at: 1) as! NSArray
                        DispatchQueue.main.async(execute: {
                            self.displayRegionIncomeLevel(dataArray as [AnyObject])
                        })
                    }catch{
                        print("Some error occured")
                    }
            }}
        // Call the resume() method to start the NSURLSession task
        task.resume()
    }
    
    //
    func displayRegionIncomeLevel(_ data:[AnyObject]){
        if data.count == 0{
            return
        }
        //1
        // Change the Map Region to the first lon/lat in the array of dictionaries
        //let regionLongitude = 51.234836
        //let regionLatitude = -0.581481
        //let wantedrecordid = "1"
        let center:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude:51.234836 , longitude: -0.581481)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        self.mapView.setRegion(region, animated: true)
        // Loop through all items and display them on the map
        var lon:Double!
        var lat:Double!
        var annotationView:MKPinAnnotationView!
        var pointAnnotation:CustomPointAnnotation!
        //2
        for item in data{
            
            let obj = item as! Dictionary<String,AnyObject>
            //get co-ords of shop
            lat = obj["latitude"]!.doubleValue
            lon = obj["longitude"]!.doubleValue
            
            
            pointAnnotation = CustomPointAnnotation()
            //goes to the title of the object income level
            //let incomeLevel:Dictionary<String, AnyObject> = obj["incomeLevel"] as! Dictionary<String, AnyObject>
            //looks in the object income level for the value of value
            //MINE should look for the file corresponsing to storeID
            //MINE for each recordID, check if it is
            //let incomeLevelValue = (incomeLevel["value"] as! String)
            //checks the string under value, sets image name as high income is oecd else just the value (if it hasnt got a colon)
           // if incomeLevelValue == "High income: OECD" || incomeLevelValue == "High income: nonOECD"{
                pointAnnotation.pinCustomImageName = "High income"
           // }else{
              //  pointAnnotation.pinCustomImageName = (incomeLevel["value"] as! String)
            //}
            
            //MINE
            //get first store, get lat and lang,  draw pin on map, do for for all stores
            
            //3
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            //annotate with address and phone number
            pointAnnotation.title = obj["name"] as? String
            pointAnnotation.subtitle = obj["number"] as? String
           
            annotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "pin")
            self.mapView.addAnnotation(annotationView.annotation!)
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView{
            print("hi")
            
            //Perform a segue here to navigate to another viewcontroller
            // On tapping the disclosure button you will get here
            
            let placemark = MKPlacemark(coordinate: view.annotation!.coordinate, addressDictionary: nil)
            // The map item is the shop location
           let mapItem = MKMapItem(placemark: placemark)
            
           let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeTransit]
           mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
    
    func mapView(_ mapView: MKMapView,
        viewFor annotation: MKAnnotation) -> MKAnnotationView?{
            
            let reuseIdentifier = "pin"
            
            var v = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
            if v == nil {
                v = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
                v!.canShowCallout = true
            }
            else {
                v!.annotation = annotation
            }
        
        let button = UIButton(type: .detailDisclosure) as UIButton // button with info sign in it
        
        v?.rightCalloutAccessoryView = button
        
            let customPointAnnotation = annotation as! CustomPointAnnotation
            v!.image = UIImage(named:customPointAnnotation.pinCustomImageName)
        
            return v
    }
    

}

