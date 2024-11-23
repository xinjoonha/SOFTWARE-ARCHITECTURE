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
                        }) {
                            Text("Start Rescue")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        .padding(.top, 16)
                    } else if dispatch.status == "active" {
                        Button(action: {
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
                        }) {
                            Text("Finish Rescue")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.green)
                                .cornerRadius(8)
                        }
                        .padding(.top, 16)
                    }

                }
                .padding()
            } else {
                Text("No dispatch details available.")
                    .font(.title)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()
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
