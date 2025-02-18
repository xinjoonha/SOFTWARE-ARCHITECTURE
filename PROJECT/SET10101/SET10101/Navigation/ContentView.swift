//
//  ContentView.swift
//  SET10101
//
//  Created by 신준하 on 11/20/24.
//

import SwiftUI

struct ContentView: View
{
    @StateObject private var communications = Communications() // Shared across tabs
    @State private var vehicle: Vehicle? // Vehicle fetched from Firestore
    @State private var isLoading: Bool = true // Loading state for fetching vehicle data
    
    var body: some View
    {
        TabView
        {
            
            Home(vehicle: vehicle)
                .tabItem
                {
                    Image(systemName: "newspaper.fill")
                    Text("Dispatch")
                }

            Aknowledgements()
                .tabItem
                {
                    Image(systemName: "person.fill")
                    Text("Aknowledgements")
                }
        }
        .onAppear
        {
            Task
            {
                await fetchVehicleStatus()
            }
        }
    }
    
    private func fetchVehicleStatus() async
    {
        isLoading = true
        do
        {
            vehicle = try await communications.fetchStatus() // Fetch the vehicle data
        }
        catch
        {
            print("Error fetching vehicle status: \(error)")
            vehicle = nil
        }
        isLoading = false
    }
}
