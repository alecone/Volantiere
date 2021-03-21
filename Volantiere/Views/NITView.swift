//
//  MainMenu.swift
//  Volantiere
//
//  Created by Alexandru Cone on 26/02/21.
//

import SwiftUI

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

struct NitView: View {
    
    var socket: TCPClient
    var messageHandler: MessageHandler
    
    @State var isStayActive: Bool = false
    @State var isKeyOn: Bool = false
    @State var speed: Double = 0
    @State var isVrPressed: Bool = false
    @State var isBackPressed: Bool = false
    let scalingFactor: Double = 0.75
    let touchPadWidth: Double = 256
    let touchPadHeight: Double = 384
    
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
                    Button(action: {sendClima()}, label: {
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
                        .frame(width: CGFloat(touchPadWidth*scalingFactor), height: CGFloat(touchPadHeight*scalingFactor), alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .highPriorityGesture(DragGesture(minimumDistance: 10, coordinateSpace: .local).onChanged({gest in
                            onTouchPadEvent(in: gest.location, isEnded: false)
                        }).onEnded({ gest in
                            onTouchPadEvent(in: gest.location, isEnded: true)
                        }))
                        .onTapGesture(perform: sendOk)
                }
            }
        }.onAppear(perform: setMessageHandler)
    }
    
    func setMessageHandler() -> Void {
        messageHandler.setFeedbackFunc(feedback: feedbackFromServer)
        messageHandler.startThread()
    }
    
    func sendStayActive(isOn active: Bool) -> Void {
        if active {
            addMessageToQueue(add: messages.ACTIVE.rawValue)
        } else {
            addMessageToQueue(add: messages.NOT_ACTIVE.rawValue)
        }
    }
    
    func sendKeyStatus(isOn key: Bool) -> Void {
        if key {
            addMessageToQueue(add: messages.KEY_ON.rawValue)
        } else {
            addMessageToQueue(add: messages.KEY_OFF.rawValue)
        }
    }
    
    func sendVolume(direction volume: volumeDirection) -> Void {
        switch volume {
        case .up:
            addMessageToQueue(add: messages.VOL_UP.rawValue)
        case .down:
            addMessageToQueue(add: messages.VOL_DOWN.rawValue)
        case .mute:
            addMessageToQueue(add: messages.MUTE.rawValue)
        }
    }
    
    func sendPhone() -> Void {
        addMessageToQueue(add: messages.PHONE.rawValue)
    }
    
    func sendViewMax() -> Void {
        addMessageToQueue(add: messages.MAX.rawValue)
    }
    
    func sendMediaSorce() -> Void {
        addMessageToQueue(add: messages.SOURCE.rawValue)
    }
    
    func sendClima() -> Void {
        addMessageToQueue(add: messages.CLIMA.rawValue)
    }
    
    func sendBack(pressure upDown: Bool) -> Void {
        if upDown {
            if !self.isBackPressed {
                addMessageToQueue(add: messages.BACK_DOWN.rawValue)
            }
            self.isBackPressed = true
        } else {
            addMessageToQueue(add: messages.BACK_UP.rawValue)
            self.isBackPressed = false
        }
    }
    
    func onSpeedChanged(_ changed: Bool) -> Void {
        let mex: String = messages.SPEED.rawValue + String(Int(speed))
        addMessageToQueue(add: mex)
    }
    
    func startSendingVR() -> Void {
        if !self.isVrPressed {
            addMessageToQueue(add: messages.VR_DOWN.rawValue)
        }
        self.isVrPressed = true
    }
    func stopSendingVR() -> Void {
        self.isVrPressed = false
        addMessageToQueue(add: messages.VR_UP.rawValue)
    }
    
    func normalizeFingerPosition(in position: CGPoint) -> CGPoint {
        var normalizedPosition: CGPoint = position
        
        normalizedPosition.x = normalizedPosition.x / CGFloat(scalingFactor)
        normalizedPosition.y = normalizedPosition.y / CGFloat(scalingFactor)
        normalizedPosition.x = normalizedPosition.x < 0 ? 0 : normalizedPosition.x
        normalizedPosition.y = normalizedPosition.y < 0 ? 0 : normalizedPosition.y
        normalizedPosition.x = normalizedPosition.x > CGFloat(touchPadWidth) ? CGFloat(touchPadWidth) : normalizedPosition.x
        normalizedPosition.y = normalizedPosition.y > CGFloat(touchPadHeight) ? CGFloat(touchPadHeight) : normalizedPosition.y
        
        return normalizedPosition
    }
    
    func onTouchPadEvent(in position: CGPoint, isEnded end: Bool) -> Void {
        let normalizedPosition: CGPoint = normalizeFingerPosition(in: position)
        if end {
            let mex = messages.DRAGOFF.rawValue + String(Int(normalizedPosition.x)) + "_" + String(Int(normalizedPosition.y))
            addMessageToQueue(add: mex)
        } else {
            let mex = messages.DRAGON.rawValue + String(Int(normalizedPosition.x)) + "_" + String(Int(normalizedPosition.y))
            addMessageToQueue(add: mex)
        }
    }
    func sendOk() -> Void {
        print("OK")
        addMessageToQueue(add: messages.OKBTN.rawValue)
    }
    
    func feedbackFromServer(received ok: String) -> Void {
        print("Received feedback \(ok)")
    }
    
    func addMessageToQueue(add message: String) -> Void {
        messageHandler.postMessage(message)
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
            NitView(socket: TCPClient(), messageHandler: MessageHandler(socket: TCPClient()))
                .preferredColorScheme(.dark)
                
        }
    }
}
