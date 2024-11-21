//
//  CalloutUpdate.swift
//  SET10101
//
//  Created by 신준하 on 11/20/24.
//

import SwiftUI

struct CalloutUpdate: View
{
    @Binding var currentStatus: String // Shared status binding
    
    @State private var actionsTaken: String = ""
    @State private var timeSpentMinutes: Int = 0
    @State private var timeSpentSeconds: Int = 0
    @State private var additionalNotes: String = ""
    
    var body: some View
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
                Text("Call-Out Update")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 8)

                VStack(alignment: .leading)
                {
                    Text("Actions Taken")
                    
                    ZStack(alignment: .topLeading) // Align text to the top-left
                    {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
                        
                        TextEditor(text: $actionsTaken)
                            .padding(8) // Add padding inside the editor
                            .frame(height: 120) // Larger box
                            .foregroundColor(.primary)
                    }
                }

                VStack(alignment: .leading)
                {
                    Text("Time Spent (Minutes & Seconds)")
                    
                    HStack
                    {
                        Picker("Minutes", selection: $timeSpentMinutes)
                        {
                            ForEach(0..<60, id: \.self)
                            {
                                Text("\($0) min")
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 100)
                        
                        Picker("Seconds", selection: $timeSpentSeconds)
                        {
                            ForEach(0..<60, id: \.self)
                            {
                                Text("\($0) sec")
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 100)
                    }
                    .padding(.top, 4)
                }

                VStack(alignment: .leading)
                {
                    Text("Additional Notes")
                    
                    ZStack(alignment: .topLeading) // Align text to the top-left
                    {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
                        
                        TextEditor(text: $additionalNotes)
                            .padding(8) // Add padding inside the editor
                            .frame(height: 120) // Larger box
                            .foregroundColor(.primary)
                    }
                }

                Spacer()

                Button(action:
                        {
                    submitCalloutDetails()
                })
                {
                    Text("Submit Updates")
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
    
    private func submitCalloutDetails()
    {
        print("Actions Taken: \(actionsTaken)")
        print("Time Spent: \(timeSpentMinutes) min, \(timeSpentSeconds) sec")
        print("Additional Notes: \(additionalNotes)")
        // Add backend or database logic here
    }
}

#Preview
{
    CalloutUpdate(currentStatus: .constant("Available"))
}
