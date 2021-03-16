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

enum messages: String {
    // Feedback messages
    case OK = "OK"
    case NOK = "NOK"
    // Main function
    case ACTIVE = "ACTIVE"
    case NOT_ACTIVE = "NOTACTIVE"
    case KEY_ON = "KEYON"
    case KEY_OFF = "KEYOFF"
    case VOL_UP = "VOLUP"
    case VOL_DOWN = "VOLDW"
    case MUTE = "MUTE"
    case PHONE = "PHONE"
    case VR_DOWN = "VRDOWN"
    case VR_UP = "VRUP"
    case MAX = "MAX"
    case SOURCE = "SOURCE"
    case CLIMA = "CLIMA"
    case BACK_DOWN = "BACKDOWN"
    case BACK_UP = "BACKUP"
    case SPEED = "SPEED_"
    // TouchPad
    case OKBTN = "OKBTN"
    case DRAGON = "DRAGON_"
    case DRAGOFF = "DRAGOFF_"
}

extension Binding {
    func didSet(execute: @escaping (Value) -> Void) -> Binding {
        return Binding(
            get: {
                return self.wrappedValue
            },
            set: {
                self.wrappedValue = $0
                execute($0)
            }
        )
    }
}

extension DispatchQueue {

//    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
//        DispatchQueue.global(qos: .background).async {
//            background?()
//            if let completion = completion {
//                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
//                    completion()
//                })
//            }
//        }
//    }
    
    static func sendToServer(socket: TCPClient, message: String, feedback: ((Bool) -> Void)? = nil) {
        print("Sending to server: \(message)")
        var ok: Bool = true
        DispatchQueue.global(qos: .background).async {
            let result = socket.send(string: message)
            switch result {
            case .success:
                print("Sent. asking feedback")
                guard let data = socket.read(8) else { return }
                
                if let response = String(bytes: data, encoding: .utf8) {
                    if response != "OK" {
                        ok = false
                    }
                }
            case .failure(let error):
                print(error)
                ok = false
            }
            if let feedback = feedback {
                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                    feedback(ok)
                })
            }
        }
    }
}

struct MainMenu: View {
    
    var socket: TCPClient
    @State var isStayActive: Bool = false
    @State var isKeyOn: Bool = false
    @State var speed: Double = 0
    @State var isVrPressed: Bool = false
    @State var isBackPressed: Bool = false
    
    var body: some View {
        VStack {
            // Stay active toggle
            HStack {
                Spacer()
                Toggle(isOn: $isStayActive.didSet(execute: sendStayActive(isOn:))) {
                    Text("Stay Active").italic().foregroundColor(Color("AccentColor")).fontWeight(.semibold)
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
            // All other buttons and touchpad
            HStack {
                // First column of items: volume buttons
                VStack {
                    Button(action: {sendVolume(direction: .up)}, label: {
                        Image(systemName: "speaker.wave.3.fill")
                            .padding()
                            .background(Color("AccentColor"))
                            .foregroundColor(.white)
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                            .font(.title2)
                    })
                    Button(action: {sendVolume(direction: .down)}, label: {
                        Image(systemName: "speaker.wave.1.fill")
                            .padding()
                            .background(Color("AccentColor"))
                            .foregroundColor(.white)
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                            .font(.title2)
                    })
                    Button(action: {sendVolume(direction: .mute)}, label: {
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
                    Button(action: {sendPhone()}, label: {
                        Image(systemName: "phone.fill")
                            .padding()
                            .background(Color("AccentColor"))
                            .foregroundColor(.white)
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                            .font(.title2)
                    })
                    Button(action: {}, label: {
                        Image(systemName: "mic.fill")
                            .padding()
                            .background(Color("AccentColor"))
                            .foregroundColor(.white)
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                            .font(.title2)
                            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged({_ in
                                startSendingVR()
                            }).onEnded({_ in
                                stopSendingVR()
                            }))
                    })
                    .scaleEffect(self.isVrPressed ? 0.8 : 1.0)
                    Button(action: {sendViewMax()}, label: {
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
                    Button(action: {sendMediaSorce()}, label: {
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
                        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged({_ in
                            sendBack(pressure: true)
                        }).onEnded({_ in
                            sendBack(pressure: false)
                        }))
                })
                .scaleEffect(self.isBackPressed ? 0.8 : 1.0)
            }.padding()
            HStack {
                VStack {
                    Text("\(Int(speed)) km/h")
                        .foregroundColor(Color("AccentColor"))
                        .font(.title2)
                    Slider(value: $speed, in: 0...100, step: 1, onEditingChanged: onSpeedChanged(_:))
                    Image(systemName: "speedometer")
                        .foregroundColor(Color("AccentColor"))
                        .font(.title2)
                }
                VStack {
                    Image("bg-kv")
                        .resizable()
                        .frame(width: 201, height: 295, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .highPriorityGesture(DragGesture(minimumDistance: 10, coordinateSpace: .local).onChanged({gest in
                            onTouchPadEvent(in: gest.location, isEnded: false)
                        }).onEnded({ gest in
                            onTouchPadEvent(in: gest.location, isEnded: true)
                        }))
                        .onTapGesture(perform: sendOk)
                }
            }
        }
    }
    
    func sendStayActive(isOn active: Bool) -> Void {
        if active {
            print("Stay active ON")
            DispatchQueue.sendToServer(socket: socket, message: messages.ACTIVE.rawValue, feedback: feedbackFromServer)
        } else {
            print("Stay active OFF")
            DispatchQueue.sendToServer(socket: socket, message: messages.NOT_ACTIVE.rawValue, feedback: feedbackFromServer)
        }
    }
    
    func sendKeyStatus(isOn key: Bool) -> Void {
        if key {
            print("Key ON")
            DispatchQueue.sendToServer(socket: socket, message: messages.KEY_ON.rawValue, feedback: feedbackFromServer)
        } else {
            print("Key OFF")
            DispatchQueue.sendToServer(socket: socket, message: messages.KEY_OFF.rawValue, feedback: feedbackFromServer)
        }
    }
    
    func sendVolume(direction volume: volumeDirection) -> Void {
        switch volume {
        case .up:
            print("Volume up")
            DispatchQueue.sendToServer(socket: socket, message: messages.VOL_UP.rawValue, feedback: feedbackFromServer)
        case .down:
            print("Volume down")
            DispatchQueue.sendToServer(socket: socket, message: messages.VOL_DOWN.rawValue, feedback: feedbackFromServer)
        case .mute:
            print("Mute")
            DispatchQueue.sendToServer(socket: socket, message: messages.MUTE.rawValue, feedback: feedbackFromServer)
        }
    }
    
    func sendPhone() -> Void {
        print("Send phone button")
        DispatchQueue.sendToServer(socket: socket, message: messages.PHONE.rawValue, feedback: feedbackFromServer)
    }
    
    func sendViewMax() -> Void {
        print("Send View Max")
        DispatchQueue.sendToServer(socket: socket, message: messages.MAX.rawValue, feedback: feedbackFromServer)
    }
    
    func sendMediaSorce() -> Void {
        DispatchQueue.sendToServer(socket: socket, message: messages.SOURCE.rawValue, feedback: feedbackFromServer)
    }
    
    func sendClima() -> Void {
        DispatchQueue.sendToServer(socket: socket, message: messages.CLIMA.rawValue, feedback: feedbackFromServer)
    }
    
    func sendBack(pressure upDown: Bool) -> Void {
        if upDown {
            print("Back press")
            if !self.isBackPressed {
                DispatchQueue.sendToServer(socket: socket, message: messages.BACK_DOWN.rawValue, feedback: feedbackFromServer)
            }
            self.isBackPressed = true
        } else {
            print("Back release")
            DispatchQueue.sendToServer(socket: socket, message: messages.BACK_UP.rawValue, feedback: feedbackFromServer)
            self.isBackPressed = false
        }
    }
    
    func onSpeedChanged(_ changed: Bool) -> Void {
        print("Speed \(changed ? "changed" : "not changed") to \(speed)")
        let mex: String = messages.SPEED.rawValue + String(Int(speed))
        DispatchQueue.sendToServer(socket: socket, message: mex, feedback: feedbackFromServer)
    }
    
    func startSendingVR() -> Void {
        print("Start sending VR")
        if !self.isVrPressed {
            DispatchQueue.sendToServer(socket: socket, message: messages.VR_DOWN.rawValue, feedback: feedbackFromServer)
        }
        self.isVrPressed = true
    }
    func stopSendingVR() -> Void {
        print("Stop sendig VR")
        self.isVrPressed = false
        DispatchQueue.sendToServer(socket: socket, message: messages.VR_UP.rawValue, feedback: feedbackFromServer)
    }
    
    func onTouchPadEvent(in position: CGPoint, isEnded end: Bool) -> Void {
        if end {
            let mex = messages.DRAGOFF.rawValue + String(Int(position.x)) + "_" + String(Int(position.y))
            DispatchQueue.sendToServer(socket: socket, message: mex, feedback: feedbackFromServer)
        } else {
            let mex = messages.DRAGON.rawValue + String(Int(position.x)) + "_" + String(Int(position.y))
            DispatchQueue.sendToServer(socket: socket, message: mex, feedback: feedbackFromServer)
        }
    }
    func sendOk() -> Void {
        print("OK")
        DispatchQueue.sendToServer(socket: socket, message: messages.OKBTN.rawValue, feedback: feedbackFromServer)
    }
    
    func feedbackFromServer(received ok: Bool) -> Void {
        print("Received feedback \(ok ? "OK" : "NOK")")
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
        Group {
            MainMenu(socket: TCPClient())
                .preferredColorScheme(.dark)
                
        }
    }
}
