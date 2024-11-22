//
//  Status.swift
//  SET10101
//
//  Created by 신준하 on 11/21/24.
//

import SwiftUI

struct Status: View
{
    var vehicle: Vehicle? // Fetched vehicle information
    var isLoading: Bool
    var communications: Communications
    var onRefresh: () async -> Void // Callback to refresh vehicle data
    
    var body: some View
    {
        VStack(spacing: 16)
        {
            Text("Current Status")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 8)
            
            if isLoading
            {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
            else if let vehicle = vehicle
            {
                Text(vehicle.status.capitalized)
                    .font(.title)
                    .foregroundColor(vehicle.status == "available" ? .green : .red)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(vehicle.status == "available" ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                    .cornerRadius(8)
                
                Spacer()
                
                Button(action:
                {
                    Task
                    {
                        do
                        {
                            try await communications.toggleStatus()
                            await onRefresh() // Refresh the status after toggling
                        }
                        catch
                        {
                            print("Error toggling status: \(error)")
                        }
                    }
                })
                {
                    Text(vehicle.status == "available" ? "Set to Engaged" : "Set to Available")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(vehicle.status == "available" ? Color.red : Color.green)
                        .cornerRadius(8)
                }
                .padding(.top, 16)
            }
            else
            {
                Text("Unable to fetch vehicle information.")
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
}
