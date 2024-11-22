//
//  Details.swift
//  SET10101
//
//  Created by 신준하 on 11/20/24.
//

import SwiftUI

struct Details: View
{
    var vehicle: Vehicle? // Fetched vehicle information
    @StateObject private var communications = Communications() // Shared instance for fetching data
    @State private var dispatch: Dispatch? = nil
    @State private var patient: Patient? = nil
    @State private var isLoading: Bool = true
    
    var body: some View
    {
        VStack
        {
            if isLoading
            {
                ProgressView("Loading Dispatch Details...")
                    .font(.title)
                    .padding()
            }
            else if let status = vehicle?.status, status == "available"
            {
                Text("Dispatch details will be here when engaged.")
                    .font(.title)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            else if let dispatch = dispatch, let patient = patient
            {
                VStack(alignment: .leading, spacing: 16)
                {
                    Text("Dispatch Details")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 8)

                    HStack
                    {
                        Text("Patient Name:")
                            .fontWeight(.semibold)
                        Text("\(patient.firstName) \(patient.lastName)")
                    }

                    HStack
                    {
                        Text("Date of Birth:")
                            .fontWeight(.semibold)
                        Text(patient.dateOfBirth.formatted(date: .long, time: .omitted))
                    }

                    HStack
                    {
                        Text("Address:")
                            .fontWeight(.semibold)
                        Text(patient.address)
                    }
                    
                    HStack
                    {
                        Text("Condition:")
                            .fontWeight(.semibold)
                        Text(dispatch.condition)
                    }

                    Spacer()

                    Button(action: {
                        guard let dispatch = self.dispatch else {
                            print("No dispatch available to start rescue.")
                            return
                        }
                        Task {
                            do {
                                try await communications.startRescue(dispatch: dispatch)
                            } catch {
                                print("Error starting rescue: \(error)")
                            }
                        }
                    }) {
                        Text("Start Rescue")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .padding(.top, 16)


                }
                .padding()
            }
            else
            {
                Text("No dispatch details available.")
                    .font(.title)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .onAppear
        {
            Task
            {
                await fetchDispatchAndPatientDetails()
            }
        }
    }
    
    //
    private func fetchDispatchAndPatientDetails()
    async
    {
        isLoading = true
        do
        {
            if let result = try await communications.fetchDispatchInfo() {
                self.dispatch = result.0
                self.patient = result.1
                print("Fetched dispatch: \(self.dispatch!)")
                print("Fetched patient: \(self.patient!)")
            }
            else
            {
                print("No pending dispatch found.")
            }
        }
        catch
        {
            print("Error fetching dispatch details: \(error)")
        }
        
        isLoading = false
    }
}
