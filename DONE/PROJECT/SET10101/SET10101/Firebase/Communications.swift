//
//  Communications.swift
//  SET10101
//
//  Created by 신준하 on 11/20/24.
//

import SwiftUI
import Foundation
import Firebase
import FirebaseFirestore
import UIKit
import CoreLocation

class Communications: NSObject, ObservableObject, CLLocationManagerDelegate
{
    private var locationManager: CLLocationManager?
    private var locationTimer: Timer?
    private var db = Firestore.firestore()
    private var vehicleId = "001"
    
    //
    func fetchDispatchInfo()
    async throws -> (Dispatch, Patient)?
    {
        let db = Firestore.firestore()
        let vehicleId = "001" // Replace with your actual vehicleId or fetch it dynamically if needed

        do {
            // 1. Check if there's an active dispatch assigned to this vehicle
            let activeDispatchSnapshot = try await db.collection("dispatches")
                .whereField("status", isEqualTo: "active")
                .whereField("vehicleId", isEqualTo: vehicleId)
                .limit(to: 1)
                .getDocuments()
            
            if let dispatchDocument = activeDispatchSnapshot.documents.first {
                print("Found an active dispatch for vehicleId: \(vehicleId)")
                // Extract and return the dispatch and patient information
                return try await extractDispatchAndPatient(from: dispatchDocument)
            } else {
                print("No active dispatch found for vehicleId: \(vehicleId). Checking for pending dispatches.")
                // 2. If no active dispatch, query the oldest pending dispatch
                let pendingDispatchSnapshot = try await db.collection("dispatches")
                    .whereField("status", isEqualTo: "pending")
                    .order(by: "date", descending: false)
                    .limit(to: 1)
                    .getDocuments()
                
                guard let dispatchDocument = pendingDispatchSnapshot.documents.first else {
                    print("No pending dispatches found.")
                    return nil
                }
                
                // Extract and return the dispatch and patient information
                return try await extractDispatchAndPatient(from: dispatchDocument)
            }
        } catch {
            print("Error fetching dispatch or patient information: \(error)")
            throw error
        }
    }
    
    //
    func startRescue(dispatch: Dispatch, vehicle: Vehicle)
    async throws
    {
        let db = Firestore.firestore()

        // Debugging log to ensure the correct ID is being used
        print("Dispatch ID: \(dispatch.id)")

        do {
            // Update dispatch status to 'active' and add vehicleId '001'
            try await db.collection("dispatches")
                .document(dispatch.id)
                .updateData([
                    "status": "active",
                    "vehicleId": "001"
                ])

            print("Successfully updated dispatch with status 'active' and vehicleId '001'")

            try await db.collection("vehicles")
                .document(vehicle.id)
                .updateData([
                    "status": "engaged"
                ])
            
            DispatchQueue.main.async
            {
                self.startUpdatingLocation()
            }

        } catch {
            print("Error updating dispatch status: \(error)")
            throw error
        }
    }

    //
    func finishRescue(dispatch: Dispatch)
    async throws
    {
        let db = Firestore.firestore()

        do {
            // Update dispatch status to 'completed' and remove vehicleId
            try await db.collection("dispatches")
                .document(dispatch.id)
                .updateData([
                    "status": "completed",
                    "vehicleId": FieldValue.delete()
                ])

            // Update vehicle status to 'available'
            try await db.collection("vehicles")
                .document("001") // Replace with actual vehicleId if needed
                .updateData([
                    "status": "available"
                ])

            DispatchQueue.main.async
            {
                self.stopUpdatingLocation()
            }
            
            print("Successfully finished rescue and updated dispatch and vehicle status.")
        } catch {
            print("Error finishing rescue: \(error)")
            throw error
        }
    }
    
    //
    func fetchStatus()
    async throws -> Vehicle
    {
        let vehicleId = "001" // Hardcoded vehicle ID
        let vehicleRef = Firestore.firestore().collection("vehicles").document(vehicleId)
        
        do
        {
            // Fetch vehicle document
            let snapshot = try await vehicleRef.getDocument()
            
            guard let data = snapshot.data() else
            {
                print("FETCHSTATUS.SWIFT:NO-DATA-FOUND for vehicle ID: \(vehicleId)")
                throw NSError(domain: "FETCHSTATUS", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data found for vehicle ID \(vehicleId)"])
            }
            
            // Extract fields
            guard let coordinates = data["coordinates"] as? GeoPoint,
                  let status = data["status"] as? String else
            {
                print("FETCHSTATUS.SWIFT:INVALID-DATA-FORMAT")
                throw NSError(domain: "FETCHSTATUS", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid data format"])
            }
            
            // Return mapped Vehicle object
            return Vehicle(id: vehicleId, coordinates: coordinates, status: status)
        }
        catch
        {
            print("FETCHSTATUS.SWIFT:ERROR FETCHING VEHICLE DATA - \(error)")
            throw error // Propagate the error to the caller
        }
    }

    //
    func fetchDispatchDetails()
    async throws -> (dispatchId: String, actionsTaken: String, timeSpent: String, additionalNotes: String)
    {
        let vehicleId = "001" // The vehicle ID to search for

        let dispatchesRef = Firestore.firestore().collection("dispatches")
        
        // Query the 'dispatches' collection for documents where 'vehicleId' == '001'
        let query = dispatchesRef.whereField("vehicleId", isEqualTo: vehicleId)
        
        do {
            let querySnapshot = try await query.getDocuments()
            
            guard let document = querySnapshot.documents.first else {
                throw NSError(domain: "FETCH_DISPATCH_DETAILS", code: 0, userInfo: [NSLocalizedDescriptionKey: "No dispatch found for vehicle ID \(vehicleId)"])
            }
            
            let dispatchId = document.documentID
            let data = document.data()
            
            let actionsTaken = data["actionsTaken"] as? String ?? ""
            let timeSpent = data["timeSpent"] as? String ?? "0,0"
            print("Fetched timeSpent: \(timeSpent)")
            
            let additionalNotes = data["additionalNotes"] as? String ?? ""
            
            return (dispatchId, actionsTaken, timeSpent, additionalNotes)

        } catch {
            print("Error fetching dispatch details: \(error)")
            throw error
        }
    }

    //
    func updateDispatchDetails(dispatchId: String, actionsTaken: String, timeSpent: String, additionalNotes: String)
    async throws
    {
        let db = Firestore.firestore()
        let dispatchRef = db.collection("dispatches").document(dispatchId)
        
        do {
            // Update or create the fields in the dispatch document
            try await dispatchRef.setData([
                "actionsTaken": actionsTaken,
                "timeSpent": timeSpent,
                "additionalNotes": additionalNotes
            ], merge: true) // Using merge to avoid overwriting existing data
            print("Dispatch details updated successfully.")
        } catch {
            print("Error updating dispatch details: \(error)")
            throw error
        }
    }

    
    
    
    
    
    
    
    
    
    
    // GPS
    
    //
    func startUpdatingLocation()
    {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
        
        // Schedule timer to update coordinates every 15 seconds
        locationTimer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(updateCoordinates), userInfo: nil, repeats: true)
    }

    //
    func stopUpdatingLocation()
    {
        locationManager?.stopUpdatingLocation()
        locationManager = nil
        locationTimer?.invalidate()
        locationTimer = nil
    }

    //
    @objc private func updateCoordinates()
    {
        guard let location = locationManager?.location else {
            print("Location data is not available.")
            return
        }
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let coordinates = GeoPoint(latitude: latitude, longitude: longitude)
        
        Task {
            do {
                try await db.collection("vehicles").document(vehicleId).updateData([
                    "coordinates": coordinates
                ])
                print("Coordinates successfully updated to Firestore: \(coordinates)")
            } catch {
                print("Error updating coordinates: \(error.localizedDescription)")
            }
        }
    }
    
    //
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        switch status
        {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager?.startUpdatingLocation()
        case .denied, .restricted:
            print("Location access denied.")
            // Handle denial
        default:
            break
        }
    }
    
    
    
    
    
    
    
    
    // HELPER FUNCTIONS
    
    //
    private func extractDispatchAndPatient(from dispatchDocument: DocumentSnapshot)
    async throws -> (Dispatch, Patient)
    {
        let db = Firestore.firestore()
        let dispatchData = dispatchDocument.data() ?? [:]

        guard let date = (dispatchData["date"] as? Timestamp)?.dateValue(),
              let patientId = dispatchData["patientId"] as? String,
              let condition = dispatchData["condition"] as? String,
              let status = dispatchData["status"] as? String else {
            print("Invalid dispatch data format: \(dispatchData)")
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid dispatch data format"])
        }
        
        let dispatch = Dispatch(
            id: dispatchDocument.documentID,
            date: date,
            patientId: patientId,
            status: status,
            condition: condition
        )
        
        // Fetch the patient information using patientId
        let patientSnapshot = try await db.collection("patients")
            .whereField("patientId", isEqualTo: patientId)
            .limit(to: 1)
            .getDocuments()
        
        guard let patientDocument = patientSnapshot.documents.first else {
            print("No patient found for patientId: \(patientId)")
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No patient found"])
        }
        
        let patientData = patientDocument.data()
        guard let firstName = patientData["firstName"] as? String,
              let lastName = patientData["lastName"] as? String,
              let dateOfBirth = (patientData["dateOfBirth"] as? Timestamp)?.dateValue(),
              let address = patientData["address"] as? String else {
            print("Invalid patient data format: \(patientData)")
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid patient data format"])
        }
        
        let patient = Patient(
            id: patientDocument.documentID,
            firstName: firstName,
            lastName: lastName,
            dateOfBirth: dateOfBirth,
            address: address
        )
        
        return (dispatch, patient)
    }
}
