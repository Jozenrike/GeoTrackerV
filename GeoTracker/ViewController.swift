//
//  ViewController.swift
//  GeoTracker
//
//  Created by Familia on 12/2/17.
//  Copyright © 2017 GeoTracker. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate{

    
    
    @IBOutlet weak var open: UIBarButtonItem!
    var mapView: GMSMapView?
    var link :String = "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson"
    let locationManager = CLLocationManager()
    
    var altitud:String = ""
    var longitud:String = ""
    var latitud:String = ""
    var contador=0
    var coordenadas = CLLocationManager().location?.coordinate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //GMSServices .provideAPIKey("AIzaSyBdl76_Mr4cOTYE0zziCgseU4Fyqr2238k")
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
        self.locationManager.startMonitoringSignificantLocationChanges()
        open.target = self.revealViewController()
        open.action = #selector(SWRevealViewController.revealToggle(_:))
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
            let camera = GMSCameraPosition.camera(withLatitude: (coordenadas?.latitude)!, longitude: (coordenadas?.longitude)!, zoom: 12)
            //let camera = GMSCameraPosition.camera(withLatitude: 42.844504, longitude: -2.680372, zoom: 12)
            mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
            //viewMap = mapView
            mapView?.isMyLocationEnabled = true
            mapView?.settings.myLocationButton = true
            mapView?.mapType = kGMSTypeHybrid
            mapView?.padding = UIEdgeInsetsMake (75, 0, 0, 0)
            
            
            
            mapView?.settings.compassButton = true
            
            //mapView?.padding = UIEdgeInsetsMake(<#T##top: CGFloat##CGFloat#>, <#T##left: CGFloat##CGFloat#>, <#T##bottom: CGFloat##CGFloat#>, <#T##right: CGFloat##CGFloat#>)
            view = mapView
            
            ponerMarcasMapa()
            
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func ponerMarcasMapa(){
        Alamofire.request(link).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                var i = 0
                while i < json["features"].count{
                    
                    let currentLocation1 = CLLocationCoordinate2DMake(json["features"][i]["geometry"]["coordinates"][1].doubleValue, json["features"][i]["geometry"]["coordinates"][0].doubleValue)
                    let marker1 = GMSMarker(position: currentLocation1)
                    
                    var fullName = json["features"][i]["properties"]["title"].stringValue
                    let fullNameArr = fullName.characters.split{$0 == "-"}.map(String.init)
                    
                    var fullName2 = fullNameArr[1]
                    let fullNameArr2 = fullName2.characters.split{$0 == ","}.map(String.init)
                    var fullSnippet = ""
                    if fullNameArr2.count == 2{
                        let sinEspacio = fullNameArr2[1].characters.split{$0 == " "}.map(String.init)
                        fullSnippet = sinEspacio[0]+"\n"
                    }
                    
                    
                    marker1.title = fullNameArr2[0].substring(from: fullNameArr2[0].index(after: fullNameArr2[0].startIndex))
                    
                    let milisecond = json["features"][i]["properties"]["time"].intValue
                    let dateVar = Date.init(timeIntervalSince1970: TimeInterval(milisecond)/1000);
                    let dateFormatter = DateFormatter();
                    dateFormatter.timeStyle = .medium
                    dateFormatter.dateStyle = .long
                    dateFormatter.string(from: dateVar)
                    
                    marker1.snippet = fullSnippet+dateFormatter.string(from: dateVar)+"\n"+fullNameArr[0]

                    
                    marker1.map = self.mapView
                    if (json["features"][i]["properties"]["tsunami"].intValue == 0){
                        marker1.icon = GMSMarker.markerImage(with: UIColor.brown)
                    }
                    else{
                        
                        marker1.icon = GMSMarker.markerImage(with: UIColor.blue)
                    }
                    
                    i += 1
                    
                }
                
            case .failure(let error):
                print(error)
            }
        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        longitud = "\(locValue.longitude)"
        latitud = "\(locValue.latitude)"
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 12)
        self.mapView?.camera = camera
        self.dismiss(animated: true, completion: nil)
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error \(error)")
    }
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
         self.dismiss(animated: true, completion: nil)
    }
    @IBAction func openSearchAddress(_ sender: UIBarButtonItem) {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        self.locationManager.startUpdatingLocation()
        self.present(autoCompleteController, animated: true, completion: nil)
    }
}

