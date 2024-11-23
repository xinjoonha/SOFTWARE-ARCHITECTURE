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

class Communications: ObservableObject
{
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
            
            // Example: Start sending GPS location every 30 seconds
            Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { timer in
                Task {
                    do {
                        let coordinates = GeoPoint(latitude: 37.7749, longitude: -122.4194)
                        try await db.collection("vehicles").document("001").updateData([
                            "coordinates": coordinates
                        ])
                        print("Coordinates successfully updated to Firestore: \(coordinates)")
                    } catch {
                        print("Error updating coordinates: \(error.localizedDescription)")
                    }
                }
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
    async throws -> (actionsTaken: String, timeSpent: String, additionalNotes: String)
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
            
            let data = document.data()
            
            let actionsTaken = data["actionsTaken"] as? String ?? ""
            let timeSpent = data["timeSpent"] as? String ?? "0,0"
            let additionalNotes = data["additionalNotes"] as? String ?? ""
            
            return (actionsTaken, timeSpent, additionalNotes)
        } catch {
            print("Error fetching dispatch details: \(error)")
            throw error
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
    
    //
    private func getCurrentLatitude()
    -> Double
    {
        // Simulate getting current latitude
        return 55.9533 // Replace with actual GPS data
    }

    private func getCurrentLongitude()
    -> Double
    {
        // Simulate getting current longitude
        return -3.1883 // Replace with actual GPS data
    }
}
