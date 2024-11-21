//
//  DispatchDetails.swift
//  SET10101
//
//  Created by 신준하 on 11/20/24.
//

import SwiftUI

struct DispatchDetails: View
{
    @Binding var currentStatus: String // Shared status binding
    
    var body: some View
    {
        VStack
        {
            if currentStatus == "Available"
            {
                Text("Dispatch details will be here when engaged.")
                    .font(.title)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            else
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
                        Text("John Doe")
                    }

                    HStack
                    {
                        Text("NHS Number:")
                            .fontWeight(.semibold)
                        Text("123456789")
                    }

                    HStack
                    {
                        Text("Address:")
                            .fontWeight(.semibold)
                        Text("123 Main Street, Edinburgh")
                    }

                    HStack
                    {
                        Text("Condition:")
                            .fontWeight(.semibold)
                        Text("Chest Pain")
                    }

                    Spacer()

                    Button(action:
                    {
                        print("Start Rescue button tapped")
                    })
                    {
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
        }
    }
}

#Preview
{
    DispatchDetails(currentStatus: .constant("Available"))
}
