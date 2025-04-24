//
//  MapViewController.swift
//  My Contact List
//
//  Created by Andrew Lawrence on 4/2/25.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var sgmtMapType: UISegmentedControl!
    var contacts: [Contact] = []
    var locationManager: CLLocationManager!
    var hasCentered = false // Flag to zoom only once

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize and configure the location manager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()

        // Configure the map view
        mapView.showsUserLocation = true
        mapView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Get contacts from Core Data
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "Contact")
        var fetchedObjects: [NSManagedObject] = []

        do {
            fetchedObjects = try context.fetch(request)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

        contacts = fetchedObjects as! [Contact]

        // Remove all annotations
        self.mapView.removeAnnotations(self.mapView.annotations)

        // Go through all contacts
        for contact in contacts {
            let address = "\(contact.streetAddress!), \(contact.city!) \(contact.state!)"
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(address) { (placemarks, error) in
                self.processAddressResponse(contact, withPlacemarks: placemarks, error: error)
            }
        }
    }

    private func processAddressResponse(_ contact: Contact, withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        if let error = error {
            print("Geocode Error: \(error)")
        } else {
            var bestMatch: CLLocation?
            if let placemarks = placemarks, placemarks.count > 0 {
                bestMatch = placemarks.first?.location
            }

            if let coordinate = bestMatch?.coordinate {
                let mp = MapPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
                mp.title = contact.contactName
                mp.subtitle = contact.streetAddress
                mapView.addAnnotation(mp)
            } else {
                print("Didn't find any matching locations")
            }
        }
    }

    // Handle location authorization changes
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            print("Location permission not granted")
        }
    }

    // Zoom to user's location and drop pin (once)
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard !hasCentered else { return }
        hasCentered = true

        var span = MKCoordinateSpan()
        span.latitudeDelta = 0.2
        span.longitudeDelta = 0.2
        let viewRegion = MKCoordinateRegion(center: userLocation.coordinate, span: span)
        mapView.setRegion(viewRegion, animated: true)

        // Create new pin
        let mp = MapPoint(latitude: userLocation.coordinate.latitude,
                          longitude: userLocation.coordinate.longitude)
        mp.title = "You"
        mp.subtitle = "Are here"
        let email = UserDefaults.standard.string(forKey: "userEmail") ?? "you@example.com"
        mp.email = email

        // Keep only the last annotation
        if let lastAnnotation = self.mapView.annotations.last {
            mapView.removeAnnotations(self.mapView.annotations)
            mapView.addAnnotation(lastAnnotation)
        }

        // Then add the new one
        mapView.addAnnotation(mp)
    }


    // IBAction for the "Find Me!" button
    @IBAction func findUser(_ sender: Any) {
        mapView.showsUserLocation = true
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    @IBAction func mapTypeChanged(_ sender: Any) {
        switch sgmtMapType.selectedSegmentIndex {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .hybrid
        case 2:
            mapView.mapType = .satellite
        default:
            break
        }
    }


}

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


