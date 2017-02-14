//
//  BackTableVC.swift
//  GeoTracker
//
//  Created by Familia on 22/1/17.
//  Copyright © 2017 GeoTracker. All rights reserved.
//

import Foundation

class BackTableVC: UITableViewController {
    
    var tableArray = [String]()
    override func viewDidLoad() {
        tableArray = ["Por hora", "Por día","Por semana","Por mes"]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        
        cell.textLabel?.text = tableArray[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "filtroTiempo"){
            
            let destinationNavigationController = segue.destination as! UINavigationController

            let targetController = destinationNavigationController.topViewController as! ViewController
            
            if let roomCount = self.tableView.indexPath(for: (sender as? UITableViewCell)!)?.row {
                switch roomCount {
                case 0:
                    targetController.link = "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_hour.geojson"
                case 1:
                    targetController.link = "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson"
                case 2:
                    targetController.link = "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_week.geojson"
                case 3:
                    targetController.link = "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.geojson"
                default:
                    targetController.link = "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson"
                }
            }
            
        }
    }
}
