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
    func fetchDispatchInfo()
    async throws
    {
        /*
         
         1. check status of the oldest callout with the 'pending' status
         2. fetch patient ID
         3. fetch first & last name
                  date of birth
                  condition
                  address
         
         patientId (inside callout, used to connect a patient to the callout):
         /callouts/[callout document with a UID]/patientId
         
         patient information:
         /patients/[patient document with a UID]/firstName (string)
         /patients/[patient document with a UID]/lastName (string)
         /patients/[patient document with a UID]/patientId (string)
         /patients/[patient document with a UID]/dateOfBirth (timestamp)
         /patients/[patient document with a UID]/condition (string)
         /patients/[patient document with a UID]/address (string)
         
         */
    }
    
    func startRescue()
    async throws
    {
        /*
         
         1. update callout status to 'active'
         2. update vehicle status to 'engaged'
         3. start sending GPS location every 30 seconds
         
         sending GPS location is writing coordinates to firebase database
         
         callout status path:
         /callouts/[callout document with a UID]/status
         
         vehicle status path:
         /vehicles/[vehicle document with a UID]/status
         
         coordinates path:
         /vehicles/[vehicle document with a UID]/coordinates
         
         */
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

}
