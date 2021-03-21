//
//  LICUView.swift
//  Volantiere
//
//  Created by Alexandru Cone on 20/03/21.
//

import SwiftUI

enum gear {
    case R, P, N, One, Two, Three, Four, Five, Six, Seven
}

struct LicuView: View {
    
    var socket: TCPClient
    @State var isHandBreakOn: Bool = true
    @State var isKeyOn: Bool = false
    @State var isHeadLightsOn: Bool = false
    @State var speed: Double = 0
    @State var currentGear: gear = .P
    
    var body: some View {
        VStack {
            // Stay active toggle
            HStack {
                Spacer()
                Toggle(isOn: $isHandBreakOn.didSet(execute: sendHBActive(isOn:))) {
                    Text("Hand break").italic().foregroundColor(Color("AccentColor")).fontWeight(.semibold)
                }
                .toggleStyle(SwitchToggleStyle(tint: Color("AccentColor")))
            }.padding()
            // Key status toggle
            HStack {
                Spacer()
                Toggle(isOn: $isKeyOn.didSet(execute: sendKeyStatus(isOn:))) {
                    Text("Key Status").italic().foregroundColor(Color("AccentColor")).fontWeight(.semibold)
                }
                .toggleStyle(SwitchToggleStyle(tint: Color("AccentColor")))
            }.padding(.horizontal)
            // Speed
            HStack {
                Text("\(Int(speed)) km/h")
                    .foregroundColor(Color("AccentColor"))
                    .font(.title2)
                Slider(value: $speed, in: 0...100, step: 1, onEditingChanged: onSpeedChanged(_:))
                Image(systemName: "speedometer")
                    .foregroundColor(Color("AccentColor"))
                    .font(.title2)
            }.padding()
            // Gear botton
            HStack {
                // First column of items: volume buttons
                Image(systemName: "gearshape.2.fill")
                    .padding()
                    .foregroundColor(Color("AccentColor"))
                    .font(.title2)
                VStack {
                    HStack{
                        buildGearButton(gear: .R, lable: "R")
                        buildGearButton(gear: .P, lable: "P")
                        buildGearButton(gear: .N, lable: "N")
                    }
                    HStack {
                        buildGearButton(gear: .One, lable: "1")
                        buildGearButton(gear: .Two, lable: "2")
                        buildGearButton(gear: .Three, lable: "3")
                        buildGearButton(gear: .Four, lable: "4")
                        buildGearButton(gear: .Five, lable: "5")
                        buildGearButton(gear: .Six, lable: "6")
                        buildGearButton(gear: .Seven, lable: "7")
                    }
                }
            }.padding()
            // Headlights toggle
            HStack {
                Spacer()
                Toggle(isOn: $isHeadLightsOn.didSet(execute: sendHeadsLight(isOn:))) {
                    Text("Head lights").italic().foregroundColor(Color("AccentColor")).fontWeight(.semibold)
                }
                .toggleStyle(SwitchToggleStyle(tint: Color("AccentColor")))
            }.padding()
            Spacer()
        }
    }
    
    func buildGearButton(gear: gear, lable: String) -> some View {
        return Button(action: {sendGear(position: gear)}, label: {
            HStack{
                Text(lable)
                    .multilineTextAlignment(.center)
            }.padding(.horizontal, 15).padding(.vertical, 10)
        })
        .disabled(!self.isKeyOn)
        .background(Color("AccentColor"))
        .foregroundColor(.white).cornerRadius(50)
        .scaleEffect((self.currentGear == gear) ? 1.4 : 0.8)
    }
    
    func sendHBActive(isOn active: Bool) -> Void {
        if active {
            DispatchQueue.sendToServer(socket: socket, message: messages.ACTIVE.rawValue, feedback: feedbackFromServer)
        } else {
            DispatchQueue.sendToServer(socket: socket, message: messages.NOT_ACTIVE.rawValue, feedback: feedbackFromServer)
        }
    }
    
    func sendKeyStatus(isOn key: Bool) -> Void {
        if key {
            DispatchQueue.sendToServer(socket: socket, message: messages.KEY_ON.rawValue, feedback: feedbackFromServer)
        } else {
            DispatchQueue.sendToServer(socket: socket, message: messages.KEY_OFF.rawValue, feedback: feedbackFromServer)
        }
    }
    
    func onSpeedChanged(_ changed: Bool) -> Void {
        let mex: String = messages.SPEED.rawValue + String(Int(speed)) + "|"
        DispatchQueue.sendToServer(socket: socket, message: mex, feedback: feedbackFromServer)
    }
    
    func sendGear(position gear: gear) -> Void {
        self.currentGear = gear
    }
    
    func sendHeadsLight(isOn lights: Bool) -> Void {
        
    }
    
    func feedbackFromServer(received ok: Bool) -> Void {
        print("Received feedback \(ok ? "OK" : "NOK")")
    }
}

struct LicuView_Previews: PreviewProvider {
    static var previews: some View {
        LicuView(socket: TCPClient())
    }
}

