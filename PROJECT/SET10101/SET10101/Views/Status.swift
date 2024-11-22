//
//  Status.swift
//  SET10101
//
//  Created by 신준하 on 11/21/24.
//

import SwiftUI

struct Status: View
{
    @Binding var currentStatus: String
    @StateObject var communications: Communications
    
    var body: some View
    {
        VStack(spacing: 16)
        {
            Text("Current Status")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 8)
            
            Text(currentStatus)
                .font(.title)
                .foregroundColor(currentStatus == "Available" ? .green : .red)
                .padding()
                .frame(maxWidth: .infinity)
                .background(currentStatus == "Available" ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                .cornerRadius(8)
            
            Spacer()
            
            Button(action:
            {
                Task
                {
                    do
                    {
                        try await communications.toggleStatus()
                    }
                    catch
                    {
                        print("Error toggling status: \(error)")
                    }
                }
            })
            {
                Text(currentStatus == "Available" ? "Set to Engaged" : "Set to Available")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(currentStatus == "Available" ? Color.red : Color.green)
                    .cornerRadius(8)
            }
            .padding(.top, 16)
        }
        .padding()
    }

}

#Preview
{
    Status(currentStatus: .constant("Available"), communications: Communications())
}
