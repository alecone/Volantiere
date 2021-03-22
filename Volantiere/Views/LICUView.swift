//
//  LICUView.swift
//  Volantiere
//
//  Created by Alexandru Cone on 20/03/21.
//

import SwiftUI

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

extension Binding {
    func onChange(_ handler: @escaping () -> Void) -> Binding<Value> {
        return Binding(
            get: { self.wrappedValue },
            set: { selection in
                self.wrappedValue = selection
                handler()
        })
    }
}

struct LicuView: View {
    
    var socket: TCPClient
    var messageHandler: MessageHandler
    
    @State var isCanThreadOn: Bool = false
    @State var isHandBreakOn: Bool = true
    @State var isKeyOn: Bool = true
    @State var isHeadLightsOn: Bool = false
    @State var speed: Double = 0
    @State var currentGear: gear = .N
    @State private var selectedCharisma = charisma.sport
    
    var body: some View {
        VStack {
            // Hand break toggle
            HStack {
                Spacer()
                Toggle(isOn: $isCanThreadOn.didSet(execute: sendStartCanThread(toggle:))) {
                    Text("CAN Active").italic().foregroundColor(Color("AccentColor")).fontWeight(.bold)
                }
                .toggleStyle(SwitchToggleStyle(tint: Color("AccentColor")))
            }.padding()
            // Hand break toggle
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
            .disabled(!self.isKeyOn)
            // Gear botton
            HStack {
                // First column of items: volume buttons
                Image(systemName: "gearshape.2.fill")
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
            }.padding(.vertical)
            // Headlights toggle
            HStack {
                Spacer()
                Toggle(isOn: $isHeadLightsOn.didSet(execute: sendHeadsLight(isOn:))) {
                    Text("Head lights").italic().foregroundColor(Color("AccentColor")).fontWeight(.semibold)
                }
                .toggleStyle(SwitchToggleStyle(tint: Color("AccentColor")))
            }
            .padding()
            .disabled(!self.isKeyOn)
            // Charisma picker
//            Picker("Charisma", selection: $selectedCharisma) {
//                Text(charisma.strada.rawValue.uppercased())
//                Text(charisma.sport.rawValue.uppercased())
//                Text(charisma.corsa.rawValue.uppercased())
//            }
//            .padding()
//            .pickerStyle(SegmentedPickerStyle())
            Spacer()
        }.onAppear(perform: setMessageHandler)
    }
    
    func setMessageHandler() -> Void {
        messageHandler.setFeedbackFunc(feedback: feedbackFromServer)
        messageHandler.startThread()
    }
    
    func buildGearButton(gear: gear, lable: String) -> some View {
        return Button(action: {sendGear(position: gear)}, label: {
            HStack{
                Text(lable)
                    .multilineTextAlignment(.center)
            }.padding(.horizontal, 10).padding(.vertical, 5)
        })
        .disabled(!self.isKeyOn)
        .background(Color("AccentColor"))
        .foregroundColor(.white).cornerRadius(50)
        .scaleEffect((self.currentGear == gear) ? 1.5 : 0.8)
    }
    
    func sendHBActive(isOn active: Bool) -> Void {
        if active {
            addMessageToQueue(add: messages.EPB_ON.rawValue)
        } else {
            addMessageToQueue(add: messages.EPB_OFF.rawValue)
        }
    }
    
    func sendKeyStatus(isOn key: Bool) -> Void {
        if key {
            addMessageToQueue(add: messages.KEY_ON.rawValue)
        } else {
            addMessageToQueue(add: messages.KEY_OFF.rawValue)
        }
    }
    
    func onSpeedChanged(_ changed: Bool) -> Void {
        let mex: String = messages.SPEED.rawValue + String(Int(speed))
        addMessageToQueue(add: mex)
    }
    
    func sendGear(position gear: gear) -> Void {
        self.currentGear = gear
        let sGear: String
        switch gear {
        case .R:
            sGear = "R"
        case .P:
            sGear = "P"
        case .N:
            sGear = "N"
        case .One:
            sGear = "1"
        case .Two:
            sGear = "2"
        case .Three:
            sGear = "3"
        case .Four:
            sGear = "4"
        case .Five:
            sGear = "5"
        case .Six:
            sGear = "6"
        case .Seven:
            sGear = "7"
        }
        let mex = messages.GEAR.rawValue + sGear
        addMessageToQueue(add: mex)
    }
    
    func sendHeadsLight(isOn lights: Bool) -> Void {
        if lights {
            addMessageToQueue(add: messages.LIGHT_ON.rawValue)
        } else {
            addMessageToQueue(add: messages.LIGHT_OFF.rawValue)
        }
    }
    
    func sendStartCanThread(toggle on: Bool) -> Void {
        if on {
            messageHandler.postMessage(messages.ACTIVE.rawValue)
        }
        else {
            messageHandler.postMessage(messages.NOT_ACTIVE.rawValue)
        }
    }
    
    func onCharismaChanged() -> Void {
        print("Charisma is \(selectedCharisma.rawValue)")
        messageHandler.postMessage(messages.CHARISMA.rawValue + selectedCharisma.rawValue.uppercased())
    }
    
    func feedbackFromServer(received ok: String) -> Void {
        print("Received feedback \(ok)")
    }
    
    func addMessageToQueue(add message: String) -> Void {
        messageHandler.postMessage(message)
    }
}

struct LicuView_Previews: PreviewProvider {
    static var previews: some View {
        LicuView(socket: TCPClient(), messageHandler: MessageHandler(socket: TCPClient()))
    }
}

