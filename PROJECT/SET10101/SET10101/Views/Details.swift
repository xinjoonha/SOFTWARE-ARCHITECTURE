//
//  Details.swift
//  SET10101
//
//  Created by 신준하 on 11/20/24.
//

import SwiftUI

struct Details: View
{
    var vehicle: Vehicle?
    @StateObject private var communications = Communications()
    @State private var dispatch: Dispatch? = nil
    @State private var patient: Patient? = nil
    @State private var isLoading: Bool = true
    
    // Added State variables for alerts
    @State private var showStartRescueConfirmation = false
    @State private var showFinishRescueConfirmation = false

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading Dispatch Details...")
                    .font(.title)
                    .padding()
            } else if let dispatch = dispatch, let patient = patient {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Dispatch Details")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 8)

                    HStack {
                        Text("Patient Name:")
                            .fontWeight(.semibold)
                        Text("\(patient.firstName) \(patient.lastName)")
                    }

                    HStack {
                        Text("Date of Birth:")
                            .fontWeight(.semibold)
                        Text(patient.dateOfBirth.formatted(date: .long, time: .omitted))
                    }

                    HStack {
                        Text("Address:")
                            .fontWeight(.semibold)
                        Text(patient.address)
                    }

                    HStack {
                        Text("Condition:")
                            .fontWeight(.semibold)
                        Text(dispatch.condition)
                    }

                    Spacer()

                    // Button depends on dispatch status
                    if dispatch.status == "pending" {
                        Button(action: {
                            // Show confirmation alert
                            self.showStartRescueConfirmation = true
                        }) {
                            Text("Start Rescue")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        .padding(.top, 16)
                        // Confirmation Alert for Start Rescue
                        .alert(isPresented: $showStartRescueConfirmation) {
                            Alert(
                                title: Text("Start Rescue"),
                                message: Text("Are you sure you want to start the rescue?"),
                                primaryButton: .default(Text("Start")) {
                                    guard let dispatch = self.dispatch else {
                                        print("No dispatch available to start rescue.")
                                        return
                                    }
                                    Task {
                                        do {
                                            try await communications.startRescue(dispatch: dispatch)
                                            // Update dispatch status locally
                                            DispatchQueue.main.async {
                                                self.dispatch?.status = "active"
                                            }
                                        } catch {
                                            print("Error starting rescue: \(error)")
                                        }
                                    }
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    } else if dispatch.status == "active" {
                        Button(action: {
                            // Show confirmation alert
                            self.showFinishRescueConfirmation = true
                        }) {
                            Text("Finish Rescue")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.green)
                                .cornerRadius(8)
                        }
                        .padding(.top, 16)
                        // Confirmation Alert for Finish Rescue
                        .alert(isPresented: $showFinishRescueConfirmation) {
                            Alert(
                                title: Text("Finish Rescue"),
                                message: Text("Are you sure you want to finish the rescue?"),
                                primaryButton: .default(Text("Finish")) {
                                    guard let dispatch = self.dispatch else {
                                        print("No dispatch available to finish rescue.")
                                        return
                                    }
                                    Task {
                                        do {
                                            try await communications.finishRescue(dispatch: dispatch)
                                            // Reset dispatch and patient after finishing rescue
                                            DispatchQueue.main.async {
                                                self.dispatch = nil
                                                self.patient = nil
                                            }
                                            // Optionally fetch the next dispatch
                                            await fetchDispatchAndPatientDetails()
                                        } catch {
                                            print("Error finishing rescue: \(error)")
                                        }
                                    }
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }

                }
                .padding()
            } else {
                VStack {
                    Text("No dispatch details available.")
                        .font(.title)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()

                    Button(action: {
                        Task {
                            await fetchDispatchAndPatientDetails()
                        }
                    }) {
                        Text("Fetch Dispatch Details")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.gray)
                            .cornerRadius(8)
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            Task {
                await fetchDispatchAndPatientDetails()
            }
        }
    }

    // Fetch Dispatch and Patient Details
    private func fetchDispatchAndPatientDetails() async {
        isLoading = true
        do {
            if let result = try await communications.fetchDispatchInfo() {
                DispatchQueue.main.async {
                    self.dispatch = result.0
                    self.patient = result.1
                    print("Fetched dispatch: \(self.dispatch!)")
                    print("Fetched patient: \(self.patient!)")
                }
            } else {
                print("No dispatch found.")
                DispatchQueue.main.async {
                    self.dispatch = nil
                    self.patient = nil
                }
            }
        } catch {
            print("Error fetching dispatch details: \(error)")
        }
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
}
