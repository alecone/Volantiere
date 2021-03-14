//
//  MainMenu.swift
//  Volantiere
//
//  Created by Alexandru Cone on 26/02/21.
//

import SwiftUI

enum volumeDirection {
    case up
    case down
    case mute
}

struct MainMenu: View {
    
    var socket: TCPClient
    @State var isStayActive: Bool = false
    @State var isKeyOn: Bool = false
    @State var speed: Double = 0
    
    var body: some View {
        VStack {
            // Stay active toggle
            HStack {
                Spacer()
                Toggle(isOn: $isStayActive) {
                    Text("Stay Active").italic().foregroundColor(Color("AccentColor")).fontWeight(.semibold)
                }.toggleStyle(SwitchToggleStyle(tint: Color("AccentColor")))
                if isStayActive {
                    // Send stay active
                } else {
                    // Send Bus sleep
                }
            }.padding()
            // Key status toggle
            HStack {
                Spacer()
                Toggle(isOn: $isKeyOn) {
                    Text("Key Status").italic().foregroundColor(Color("AccentColor")).fontWeight(.semibold)
                }.toggleStyle(SwitchToggleStyle(tint: Color("AccentColor")))
                if isKeyOn {
                    // Send key on
                } else {
                    // Send Key off
                }
            }.padding()
            // All other buttons and touchpad
            HStack {
                // First column of items: volume buttons
                VStack {
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Image(systemName: "speaker.wave.3.fill")
                            .padding()
                            .background(Color("AccentColor"))
                            .foregroundColor(.white)
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                            .font(.title2)
                    })
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Image(systemName: "speaker.wave.1.fill")
                            .padding()
                            .background(Color("AccentColor"))
                            .foregroundColor(.white)
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                            .font(.title2)
                    })
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Image(systemName: "speaker.slash.fill")
                            .padding()
                            .background(Color("AccentColor"))
                            .foregroundColor(.white)
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                            .font(.title2)
                    })
                }
                // Second column of items: phone, vr, max
                VStack {
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Image(systemName: "phone.fill")
                            .padding()
                            .background(Color("AccentColor"))
                            .foregroundColor(.white)
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                            .font(.title2)
                    })
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Image(systemName: "mic.fill")
                            .padding()
                            .background(Color("AccentColor"))
                            .foregroundColor(.white)
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                            .font(.title2)
                    })
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Image(systemName: "light.max")
                            .padding()
                            .background(Color("AccentColor"))
                            .foregroundColor(.white)
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                            .font(.title2)
                    })
                }
                // Third column of items: phone, vr, max
                VStack {
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Image(systemName: "music.note")
                            .padding()
                            .background(Color("AccentColor"))
                            .foregroundColor(.white)
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                            .font(.title2)
                    })
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Image(systemName: "thermometer.snowflake")
                            .padding()
                            .background(Color("AccentColor"))
                            .foregroundColor(.white)
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                            .font(.title2)
                    })
                }
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    Image(systemName: "arrowshape.turn.up.backward.fill")
                        .padding()
                        .background(Color("AccentColor"))
                        .foregroundColor(.white)
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                        .font(.title2)
                })
            }.padding()
            VStack {
                Image("bg-kv")
                    .resizable()
                    .frame(width: 201, height: 295, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            }.padding()
            Spacer()
            HStack {
                Image(systemName: "speedometer")
                    .foregroundColor(Color("AccentColor"))
                    .font(.title2)
                Slider(value: $speed, in: 0...500, step: 1, onEditingChanged: onSpeedChanged(_:))
                Text("\(Int(speed)) km/h")
                    .foregroundColor(Color("AccentColor"))
                    .font(.title2)
            }.padding()
        }
    }
    
    func sendStayActive(isOn active: Bool) -> Void {
        if active {
            
        } else {
            
        }
    }
    
    func sendVolume(direction volume: volumeDirection) -> Void {
        switch volume {
        case .up:
            print("Volume up")
        case .down:
            print("Volume down")
        case .mute:
            print("Mute")
        }
    }
    
    func sendPhone() -> Void {
        print("Send phone button")
    }
    
    func sendVR(pressure upDown: Bool) -> Void {
        if upDown {
            print("VR press")
        } else {
            print("VR released")
        }
    }
    
    func sendViewMax() -> Void {
        print("Send View Max")
    }
    
    func onSpeedChanged(_ changed: Bool) -> Void {
        print("Speed \(changed ? "changed" : "not changed") to \(speed)")
    }
}

struct DarkBlueShadowProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ProgressView(configuration)
            .shadow(color: Color(red: 0, green: 0, blue: 0.6),
                    radius: 4.0, x: 1.0, y: 2.0)
    }
}

struct MainMenu_Previews: PreviewProvider {
    static var previews: some View {
        MainMenu(socket: TCPClient())
    }
}
