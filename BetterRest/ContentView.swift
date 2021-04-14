//
//  ContentView.swift
//  BetterRest
//
//  Created by Anthony Da cruz on 20/02/2021.
//

import SwiftUI

struct ContentView: View {
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var coffeeAmount = 1
    
    @State private var sleepTime = Date()
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 5)
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    func calculateBedTime() {
        let model = SleepCalculator()
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        
        do {
            let prediction = try model.prediction(input: SleepCalculatorInput(wake: Double(hour+minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount)))
            
            sleepTime = wakeUp - prediction.actualSleep
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            alertTitle = "Your ideal bedtime is..."
            alertMessage = formatter.string(from: sleepTime)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        
        //showingAlert = true
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Ideal bedtime is \(alertMessage)")
                    .fontWeight(.heavy)
                    .font(.title2)
                    .padding()
                Form {
                    Section(header: Text("⏰ When do you want to wake up?")) {
                        DatePicker("Please enter a Date", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .onChange(of: wakeUp, perform: { value in
                                calculateBedTime()
                            })
                    }
                    
                    Section(header: Text("😴 Desired amount of sleep")){
                    
                        Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
                            Text("\(sleepAmount, specifier: "%g") hours")
                        }.onChange(of: sleepAmount, perform: { value in
                            calculateBedTime()
                        })
                    }
                    
                    Section(header: Text("☕️ Daily coffee intake")){
                        Stepper(value: $coffeeAmount, in: 1...20){
                                if coffeeAmount == 1 {
                                    Text("1 cup")
                                } else {
                                    Text("\(coffeeAmount) cups")
                                }
                            }
                        .onChange(of: coffeeAmount, perform: { value in
                            calculateBedTime()
                        })
                        LazyVGrid(columns: columns) {
                            ForEach((0...coffeeAmount-1), id: \.self) {
                                Text("☕️").tag($0)
                            }
                        }
                    }
                }
                .alert(isPresented: $showingAlert, content: {
                    Alert(title:Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("Ok")))
                })
                .navigationTitle("Better Rest")
            }
        }.onAppear(perform: {
            calculateBedTime()
        })
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
