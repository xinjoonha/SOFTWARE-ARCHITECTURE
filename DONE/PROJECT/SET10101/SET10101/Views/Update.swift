//
//  CalloutUpdate.swift
//  SET10101
//
//  Created by 신준하 on 11/20/24.
//

import SwiftUI

struct Update: View
{
    var vehicle: Vehicle?
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var actionsTaken: String = ""
    @State private var timeSpentMinutes: Int = 0
    @State private var timeSpentSeconds: Int = 0
    @State private var additionalNotes: String = ""
    @State private var isLoading: Bool = true
    @State private var dispatchId: String = ""
    
    @StateObject private var communications = Communications()
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading Dispatch Details...")
                    .font(.title)
                    .padding()
            } else {
                if let status = vehicle?.status, status == "available" {
                    Text("Dispatch details will be here when engaged.")
                        .font(.title)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Add or edit details")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.bottom, 8)
                        
                        // Actions taken section
                        VStack(alignment: .leading) {
                            Text("Actions taken")
                            
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
                                
                                TextEditor(text: $actionsTaken)
                                    .padding(8)
                                    .frame(height: 120)
                                    .foregroundColor(.primary)
                            }
                        }
                        
                        // Time spent section
                        VStack(alignment: .leading) {
                            Text("Time spent (minutes & seconds)")
                            
                            HStack {
                                Picker("Minutes", selection: $timeSpentMinutes) {
                                    ForEach(0..<60, id: \.self) {
                                        Text("\($0) min")
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(width: 100)
                                
                                Picker("Seconds", selection: $timeSpentSeconds) {
                                    ForEach(0..<60, id: \.self) {
                                        Text("\($0) sec")
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(width: 100)
                            }
                            .padding(.top, 4)
                        }
                        
                        // Additional notes section
                        VStack(alignment: .leading) {
                            Text("Additional notes")
                            
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
                                
                                TextEditor(text: $additionalNotes)
                                    .padding(8)
                                    .frame(height: 120)
                                    .foregroundColor(.primary)
                            }
                        }
                        
                        Spacer()
                        
                        // Submit button
                        Button(action: {
                            submitCalloutDetails()
                        }) {
                            Text("Submit updates")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.green)
                                .cornerRadius(8)
                        }
                        .padding(.top, 16)
                    }
                    .padding()
                }
            }
        }
        .onAppear
        {
            Task
            {
                await fetchDispatchDetails()
            }
        }
    }
    
    //
    private func fetchDispatchDetails()
    async
    {
        isLoading = true
        do {
            // Fetch dispatch details from Communications class
            let dispatchDetails = try await communications.fetchDispatchDetails()
            
            // Split timeSpent into minutes and seconds
            let timeComponents = dispatchDetails.timeSpent.split(separator: ",")
            let minutes = Int(timeComponents.first ?? "0") ?? 0
            let seconds = Int(timeComponents.last ?? "0") ?? 0
            
            // Update state variables on the main thread
            DispatchQueue.main.async {
                self.dispatchId = dispatchDetails.dispatchId
                self.actionsTaken = dispatchDetails.actionsTaken
                self.timeSpentMinutes = minutes
                self.timeSpentSeconds = seconds
                self.additionalNotes = dispatchDetails.additionalNotes
                self.isLoading = false
            }
        } catch {
            print("Error fetching dispatch details: \(error)")
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    //
    private func submitCalloutDetails()
    {
        print("Actions taken: \(actionsTaken)")
        print("Time spent: \(timeSpentMinutes) min, \(timeSpentSeconds) sec")
        print("Additional notes: \(additionalNotes)")
        
        let timeSpent = "\(timeSpentMinutes),\(timeSpentSeconds)"
        
        Task
        {
            do {
                try await communications.updateDispatchDetails(
                    dispatchId: dispatchId,
                    actionsTaken: actionsTaken,
                    timeSpent: timeSpent,
                    additionalNotes: additionalNotes
                )
                print("Dispatch details updated successfully.")
            } catch {
                print("Error updating dispatch details: \(error)")
            }
        }
        
        DispatchQueue.main.async {
            self.dismiss()
        }

    }

}
