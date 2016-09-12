//
//  ViewController.swift
//  GeoFenceCodeChallenge
//
//  Created by Justin Doan on 9/9/16.
//  Copyright © 2016 Justin Doan. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var map: MKMapView!
    @IBOutlet var tableView: UITableView!
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        locationAuthStatus()
        
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        if let location = locationManager.location {
            centerMapOnLocation(location)
        }
        
        updateMap()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(ViewController.handleTap(_:)))
        gestureRecognizer.delegate = self
        map.addGestureRecognizer(gestureRecognizer)
        
    }
    
    func handleTap(gestureReconizer: UILongPressGestureRecognizer) {
        
        let location = gestureReconizer.locationInView(map)
        let coordinate = map.convertPoint(location,toCoordinateFromView: map)
        
        centerMapOnLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        map.addAnnotation(annotation)
        
        var rad = 0.0
        var id = ""
        var entry = false
        var exit = false
        var msg = ""
        
        let alert = UIAlertController(title: "New Notification", message: "Do you want to add a location alert here?", preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "NO", style: .Default, handler: { (action) -> Void in
            self.map.removeAnnotation(annotation)
        }))
        
        alert.addAction(UIAlertAction(title: "YES", style: .Default, handler: { (action) -> Void in
            let newAlert = UIAlertController(title: "", message: "Create alert for:", preferredStyle: .Alert)
            
            newAlert.addAction(UIAlertAction(title: "Exit", style: .Default, handler: { (action) -> Void in
                exit = true
                
                let newNewAlert = UIAlertController(title: "", message: "Activate alert with X meters", preferredStyle: .Alert)
                
                newNewAlert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                    textField.placeholder = "Meters"
                    textField.textAlignment = NSTextAlignment.Center
                    textField.keyboardType = .DecimalPad
                })
                
                newNewAlert.addAction(UIAlertAction(title: "Continue", style: .Default, handler: { (action) -> Void in
                    let txtMeters = newNewAlert.textFields![0] as UITextField
                    
                    if let meters = txtMeters.text where meters != "" {
                        rad = Double(meters)!
                        
                        let msgAlert = UIAlertController(title: "", message: "Enter a message for the notification", preferredStyle: .Alert)
                        
                        msgAlert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                            textField.placeholder = "Message"
                            textField.textAlignment = NSTextAlignment.Center
                            //textField.keyboardType = .DecimalPad
                        })
                        
                        msgAlert.addAction(UIAlertAction(title: "Continue", style: .Default, handler: { (action) -> Void in
                            let txtMessage = msgAlert.textFields![0] as UITextField
                            
                            if let message = txtMessage.text where message != "" {
                                msg = message
                                
                                let titleAlert = UIAlertController(title: "", message: "What do you want to call this notification", preferredStyle: .Alert)
                                
                                titleAlert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                                    textField.placeholder = "Title"
                                    textField.textAlignment = NSTextAlignment.Center
                                    //textField.keyboardType = .DecimalPad
                                })
                                
                                titleAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action) -> Void in
                                    self.map.removeAnnotation(annotation)
                                }))
                                
                                titleAlert.addAction(UIAlertAction(title: "Finish", style: .Default, handler: { (action) -> Void in
                                    let txtTitle = titleAlert.textFields![0] as UITextField
                                    
                                    if let title = txtTitle.text where title != "" {
                                        id = title
                                        
                                        self.createGeoAlert(coordinate.latitude, longitude: coordinate.longitude, radius: rad, regionid: id, forEntry: entry, forExit: exit, msg: msg)
                                        
                                        self.map.removeAnnotation(annotation)
                                        self.tableView.reloadData()
                                        self.updateMap()
                                    }
                                }))
                                self.presentViewController(titleAlert, animated: true, completion: nil)
                            }
                        }))
                        self.presentViewController(msgAlert, animated: true, completion: nil)
                    }
                }))
                self.presentViewController(newNewAlert, animated: true, completion: nil)
            }))
            
            newAlert.addAction(UIAlertAction(title: "Entry", style: .Default, handler: { (action) -> Void in
                entry = true
                
                let newNewAlert = UIAlertController(title: "", message: "Activate alert with X meters", preferredStyle: .Alert)
                
                newNewAlert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                    textField.placeholder = "Meters"
                    textField.textAlignment = NSTextAlignment.Center
                    textField.keyboardType = .DecimalPad
                })
                
                newNewAlert.addAction(UIAlertAction(title: "Continue", style: .Default, handler: { (action) -> Void in
                    let txtMeters = newNewAlert.textFields![0] as UITextField
                    
                    if let meters = txtMeters.text where meters != "" {
                        rad = Double(meters)!
                        
                        let msgAlert = UIAlertController(title: "", message: "Enter a message for the notification", preferredStyle: .Alert)
                        
                        msgAlert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                            textField.placeholder = "Message"
                            textField.textAlignment = NSTextAlignment.Center
                            //textField.keyboardType = .DecimalPad
                        })
                        
                        msgAlert.addAction(UIAlertAction(title: "Continue", style: .Default, handler: { (action) -> Void in
                            let txtMessage = msgAlert.textFields![0] as UITextField
                            
                            if let message = txtMessage.text where message != "" {
                                msg = message
                                
                                let titleAlert = UIAlertController(title: "", message: "What do you want to call this notification", preferredStyle: .Alert)
                                
                                titleAlert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                                    textField.placeholder = "Title"
                                    textField.textAlignment = NSTextAlignment.Center
                                    //textField.keyboardType = .DecimalPad
                                })
                                
                                titleAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action) -> Void in
                                    self.map.removeAnnotation(annotation)
                                }))
                                
                                titleAlert.addAction(UIAlertAction(title: "Finish", style: .Default, handler: { (action) -> Void in
                                    let txtTitle = titleAlert.textFields![0] as UITextField
                                    
                                    if let title = txtTitle.text where title != "" {
                                        id = title
                                        
                                        self.createGeoAlert(coordinate.latitude, longitude: coordinate.longitude, radius: rad, regionid: id, forEntry: entry, forExit: exit, msg: msg)
                                        
                                        self.map.removeAnnotation(annotation)
                                        self.tableView.reloadData()
                                        self.updateMap()
                                    }
                                }))
                                self.presentViewController(titleAlert, animated: true, completion: nil)
                            }
                        }))
                        self.presentViewController(msgAlert, animated: true, completion: nil)
                    }
                }))
                self.presentViewController(newNewAlert, animated: true, completion: nil)
            }))
            
            newAlert.addAction(UIAlertAction(title: "Both", style: .Default, handler: { (action) -> Void in
                exit = true
                entry = true
                let newNewAlert = UIAlertController(title: "", message: "Activate alert with X meters", preferredStyle: .Alert)
                
                newNewAlert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                    textField.placeholder = "Meters"
                    textField.textAlignment = NSTextAlignment.Center
                    textField.keyboardType = .DecimalPad
                })
                
                newNewAlert.addAction(UIAlertAction(title: "Continue", style: .Default, handler: { (action) -> Void in
                    let txtMeters = newNewAlert.textFields![0] as UITextField
                    
                    if let meters = txtMeters.text where meters != "" {
                        rad = Double(meters)!
                        
                        let msgAlert = UIAlertController(title: "", message: "Enter a message for the notification", preferredStyle: .Alert)
                        
                        msgAlert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                            textField.placeholder = "Message"
                            textField.textAlignment = NSTextAlignment.Center
                            //textField.keyboardType = .DecimalPad
                        })
                        
                        msgAlert.addAction(UIAlertAction(title: "Continue", style: .Default, handler: { (action) -> Void in
                            let txtMessage = msgAlert.textFields![0] as UITextField
                            
                            if let message = txtMessage.text where message != "" {
                                msg = message
                                
                                let titleAlert = UIAlertController(title: "", message: "What do you want to call this notification", preferredStyle: .Alert)
                                
                                titleAlert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                                    textField.placeholder = "Title"
                                    textField.textAlignment = NSTextAlignment.Center
                                    //textField.keyboardType = .DecimalPad
                                })
                                
                                titleAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action) -> Void in
                                    self.map.removeAnnotation(annotation)
                                }))
                                
                                titleAlert.addAction(UIAlertAction(title: "Finish", style: .Default, handler: { (action) -> Void in
                                    let txtTitle = titleAlert.textFields![0] as UITextField
                                    
                                    if let title = txtTitle.text where title != "" {
                                        id = title
                                        
                                        self.createGeoAlert(coordinate.latitude, longitude: coordinate.longitude, radius: rad, regionid: id, forEntry: entry, forExit: exit, msg: msg)
                                        
                                        self.map.removeAnnotation(annotation)
                                        self.tableView.reloadData()
                                        self.updateMap()
                                    }
                                }))
                                self.presentViewController(titleAlert, animated: true, completion: nil)
                            }
                        }))
                        self.presentViewController(msgAlert, animated: true, completion: nil)
                    }
                }))
                self.presentViewController(newNewAlert, animated: true, completion: nil)
            }))
            self.presentViewController(newAlert, animated: true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            map.showsUserLocation = true
            
            
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func updateMap() {
        
        map.removeOverlays(map.overlays)
        map.removeAnnotations(map.annotations)
        
        let notifications = UIApplication.sharedApplication().scheduledLocalNotifications
        for notification in notifications! {
            
            getPlacemarkFromLocation(CLLocation(latitude: notification.userInfo!["COORDINATE_LAT"] as! Double, longitude: notification.userInfo!["COORDINATE_LON"] as! Double))
            let circle = MKCircle(centerCoordinate: CLLocationCoordinate2D(latitude: notification.userInfo!["COORDINATE_LAT"] as! Double, longitude: notification.userInfo!["COORDINATE_LON"] as! Double), radius: notification.userInfo!["RADIUS"] as! Double)
            map.addOverlay(circle)
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKindOfClass(MKCircle){
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.fillColor = UIColor.blueColor().colorWithAlphaComponent(0.1)
            circleRenderer.strokeColor = UIColor.blueColor()
            circleRenderer.lineWidth = 1
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000)
        
        map.setRegion(coordinateRegion, animated: true)
    }
    

    func createGeoAlert(latitude : Double, longitude : Double, radius : Double, regionid : String, forEntry : Bool, forExit : Bool, msg : String) {
        let alarm = UILocalNotification()
        
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        
        let region = CLCircularRegion(center: coordinate, radius: radius, identifier: regionid)
        region.notifyOnEntry = forEntry
        region.notifyOnExit = forExit
        
        
        alarm.region = region
        alarm.regionTriggersOnce = false
        alarm.soundName = "CTPN 100 Percent.mp3"
        alarm.alertBody = msg
        alarm.userInfo = [ "REGION_ID" : regionid, "COORDINATE_LAT" : coordinate.latitude, "COORDINATE_LON" : coordinate.longitude, "RADIUS" : radius]
        
        UIApplication.sharedApplication().scheduleLocalNotification(alarm)
    }
    
    func removeGeoAlert(regionid : String) {
        let notifications = UIApplication.sharedApplication().scheduledLocalNotifications
        
        guard let _notifications = notifications else {
            return
        }
        
        for notification in _notifications {
            if let userInfo = notification.userInfo {
                if let id = userInfo["REGION_ID"] as? String {
                    if id == regionid {
                        UIApplication.sharedApplication().cancelLocalNotification(notification)
                        return
                    }
                }
            }
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKindOfClass(Annotation) {
            let annoView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Default")
            annoView.pinTintColor = UIColor.redColor()
            annoView.animatesDrop = true
            return annoView
        } else if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
        return nil
        
    }
    
    
    
    func createAnnotationForLocation(location: CLLocation) {
        let alertLocation = Annotation(coordinate: location.coordinate)
        map.addAnnotation(alertLocation)
    }
    
    func getPlacemarkFromLocation(location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation (location) { (placemarks: [CLPlacemark]?, error: NSError?) -> Void in
            
            if let marks = placemarks where marks.count > 0 {
                if let location = marks[0].location {
                    //valid coordinates found
                    self.createAnnotationForLocation(location)
                }
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let notifications = UIApplication.sharedApplication().scheduledLocalNotifications
        if notifications != nil {
            return notifications!.count
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) //as! FillupTableViewCell]
        
        if let notifications = UIApplication.sharedApplication().scheduledLocalNotifications {
            
            let notification = notifications[indexPath.row]
            if let userInfo = notification.userInfo {
                if let id = userInfo["REGION_ID"] as? String {
                    cell.textLabel?.text = id
                }
                if notification.region?.notifyOnEntry == true && notification.region?.notifyOnExit == true {
                    if let title = notification.alertBody {
                        cell.detailTextLabel?.text = "On Entry and Exit: \(title)"
                    }
                } else if notification.region?.notifyOnEntry == true {
                    if let title = notification.alertBody {
                        cell.detailTextLabel?.text = "On Entry: \(title)"
                    }
                } else if notification.region?.notifyOnExit == true {
                    if let title = notification.alertBody {
                        cell.detailTextLabel?.text = "On Exit: \(title)"
                    }
                }
                
            }
        } else {
            cell.textLabel!.text = "Tap the map to add a location alert"
        }

        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow!;
        
        let notifications = UIApplication.sharedApplication().scheduledLocalNotifications
        
        guard let _notifications = notifications else {
            return
        }
        
        let notification = _notifications[indexPath.row]
        
        centerMapOnLocation(CLLocation(latitude: notification.userInfo!["COORDINATE_LAT"] as! Double, longitude: notification.userInfo!["COORDINATE_LON"] as! Double))
        
        print(indexPath.row)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if let notifications = UIApplication.sharedApplication().scheduledLocalNotifications {
                let notification = notifications[indexPath.row]
                let id = notification.region?.identifier
                self.removeGeoAlert(id!)
                self.tableView.reloadData()
                self.updateMap()
            }
        }
    }
    
    @IBAction func locate(sender: AnyObject) {
        if let location = locationManager.location {
            centerMapOnLocation(location)
        }
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

