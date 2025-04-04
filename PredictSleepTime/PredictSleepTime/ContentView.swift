//
//  ContentView.swift
//  PredictSleepTime
//
//  Created by Pawara Navojith on 04/04/2025.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUpTime: Date = Calendar.current.date(byAdding: .hour, value: 8, to: Date()) ?? .now
    @State private var sleepFor = 8.0
    @State private var coffeeAmount = 0
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    
    var body: some View {
        NavigationStack {
            ZStack {
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(red: 252 / 255, green: 70 / 255, blue: 107 / 255),
                        Color(red: 63 / 255, green: 94 / 255, blue: 251 / 255),
                    ]),
                    center: .top,
                    startRadius: 0,
                    endRadius: 500
                )
                .ignoresSafeArea()
                
                VStack(spacing:0){
                    Text("RestWell")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top,20)
                    Form {
                        
                        VStack( alignment: .leading, spacing:5){
                            Text("When do you want to wake up?")
                                .font(.title3)
                            DatePicker("Wake Up", selection: $wakeUpTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .environment(\.locale, Locale(identifier: "en_US"))
                        }
                        
                        
                        VStack( alignment: .leading, spacing:5){
                            Text("Expected hours of sleep?")
                                .font(.title3)
                            Stepper("\(sleepFor.formatted()) hours", value: $sleepFor, in: 1...20, step: 0.25)
                        }
                        
                        VStack( alignment: .leading, spacing:5){
                            Text("Daily coffee intake?")
                                .font(.title3)
                            Stepper("\(coffeeAmount) cups", value: $coffeeAmount, in: 0...20)
                        }
                        VStack(alignment: .center, spacing: 0){
                            Button("Predict", action: calculate)
                                .buttonStyle(.borderedProminent)
                            
                        }
                        .padding(.bottom, 5)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .padding()
            }
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK") {}
        } message: {
            Text(alertMessage)
        }
    }
    
    func calculate() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepPredictionModel(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUpTime)
            let hours = (components.hour ?? 0) * 60 * 60
            let minutes = (components.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Double(hours + minutes), estimatedSleep: sleepFor, coffee: Double(coffeeAmount))
            let bedtime = wakeUpTime-prediction.actualSleep
            var formattedBedtime: String {
                let formatter = DateFormatter()
                formatter.dateFormat = "h:mm a"
                return formatter.string(from: bedtime).uppercased()
            }

            let totalMinutes = Int(prediction.actualSleep / 60)
            let actualHours = totalMinutes / 60
            let actualMinutes = totalMinutes % 60
            alertMessage = "You will get \(actualHours) hours and \(actualMinutes) minutes of sleep"

            alertTitle = "Your ideal bedtime is \(formattedBedtime)"
        } catch {
            alertTitle = "Error"
            alertMessage = "Error occured when predicting ideal bedtime"
        }
        
        showAlert = true
    }
}

#Preview {
    ContentView()
}
