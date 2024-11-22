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
        
        do {
            // 1. Query the oldest dispatch with 'pending' status
            let dispatchSnapshot = try await db.collection("dispatches")
                .whereField("status", isEqualTo: "pending")
                .order(by: "date", descending: false)
                .limit(to: 1)
                .getDocuments()
            
            guard let dispatchDocument = dispatchSnapshot.documents.first else {
                print("No pending dispatches found.")
                return nil
            }
            
            // Extract dispatch information
            let dispatchData = dispatchDocument.data()
            guard let date = (dispatchData["date"] as? Timestamp)?.dateValue(),
                  let patientId = dispatchData["patientId"] as? String,
                  let condition = dispatchData["condition"] as? String,
                  let status = dispatchData["status"] as? String else {
                print("Invalid dispatch data format: \(dispatchData)")
                return nil
            }
            
            let dispatch = Dispatch(
                id: dispatchDocument.documentID,
                date: date,
                patientId: patientId,
                status: status,
                condition: condition
            )
            
            // 2. Fetch the patient information using patientId
            let patientSnapshot = try await db.collection("patients")
                .whereField("patientId", isEqualTo: patientId)
                .limit(to: 1)
                .getDocuments()
            
            guard let patientDocument = patientSnapshot.documents.first else {
                print("No patient found for patientId: \(patientId)")
                return nil
            }
            
            // Extract patient information
            let patientData = patientDocument.data()
            guard let firstName = patientData["firstName"] as? String,
                  let lastName = patientData["lastName"] as? String,
                  let dateOfBirth = (patientData["dateOfBirth"] as? Timestamp)?.dateValue(),
                  let address = patientData["address"] as? String else {
                print("Invalid patient data format: \(patientData)")
                return nil
            }
            
            let patient = Patient(
                id: patientDocument.documentID,
                firstName: firstName,
                lastName: lastName,
                dateOfBirth: dateOfBirth,
                address: address
            )
            
            return (dispatch, patient)
        } catch {
            print("Error fetching dispatch or patient information: \(error)")
            throw error
        }
    }
    
    //
    func startRescue(dispatch: Dispatch)
    async throws
    {
        let db = Firestore.firestore()

        // Debugging log to ensure the correct ID is being used
        print("Dispatch ID: \(dispatch.id)")

        do {
            // Update dispatch status to 'active'
            try await db.collection("dispatches")
                .document(dispatch.id) // Use the correct document ID
                .updateData(["status": "active"])

            print("Successfully updated dispatch status to 'active'")
            
            // Example: Start sending GPS location every 30 seconds
            Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { timer in
                Task {
                    do {
                        // Replace with actual GPS coordinates retrieval
                        let coordinates = GeoPoint(latitude: 37.7749, longitude: -122.4194)
                        try await db.collection("vehicles").document("vehicleID").updateData([
                            "coordinates": coordinates
                        ])
                        print("Updated GPS coordinates: \(coordinates)")
                    } catch {
                        print("Failed to update GPS coordinates: \(error)")
                        timer.invalidate()
                    }
                }
            }
        } catch {
            print("Error updating dispatch status: \(error)")
            throw error
        }
    }


    // Helper methods to simulate GPS location
    private func getCurrentLatitude() -> Double {
        // Simulate getting current latitude
        return 55.9533 // Replace with actual GPS data
    }

    private func getCurrentLongitude() -> Double {
        // Simulate getting current longitude
        return -3.1883 // Replace with actual GPS data
    }

    
    func finishRescue()
    async throws
    {
        /*
         
         1. update callout status to 'finished'
         2. update vehicle status to 'available'
         3. stop sending GPS location
         
         */
    }
    
    //
    func toggleStatus()
    async throws
    {
        print("TOGGLESTATUS.SWIFT:TOGGLING STATUS")

        let vehicleId = "001" // Hardcoded vehicle ID
        let db = Firestore.firestore()
        let vehicleDocumentRef = db.collection("vehicles").document(vehicleId)
        
        // Fetch the current status
        let vehicleDocument = try await vehicleDocumentRef.getDocument()
        guard let vehicleData = vehicleDocument.data(),
              let currentStatus = vehicleData["status"] as? String else
        {
            print("TOGGLESTATUS.SWIFT:UNABLE-TO-RETRIEVE-CURRENT-STATUS")
            return
        }
        
        // Determine the new status
        let newStatus = currentStatus == "available" ? "engaged" : "available"
        print("TOGGLESTATUS.SWIFT:CURRENT STATUS: \(currentStatus), NEW STATUS: \(newStatus)")
        
        // Update the status in Firestore
        try await vehicleDocumentRef.updateData(["status": newStatus])
        print("TOGGLESTATUS.SWIFT:SUCCESSFULLY-UPDATED-STATUS")
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

}
