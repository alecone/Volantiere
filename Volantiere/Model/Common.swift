//
//  Common.swift
//  Volantiere
//
//  Created by Alexandru Cone on 21/03/21.
//

import Foundation

// Enums
enum ActiveAlert {
    case ipNOK, connectKO
}

enum volumeDirection {
    case up
    case down
    case mute
}

enum charisma: String, CaseIterable, Identifiable, Equatable {
    case strada
    case sport
    case corsa

    var id: String { self.rawValue }
}

enum messages: String {
    // Host type
    case HOST_REQ = "GETHOSTTYPE"
    case NIT = "NIT"
    case LICU = "LICU"
    // Feedback messages
    case OK = "OK"
    case NOK = "NOK"
    // Universal
    case DISCONNECT = "DISCONNECT"
    case KEY_ON = "KEYON"
    case KEY_OFF = "KEYOFF"
    case SPEED = "SPEED_"
    // NIT function
    case ACTIVE = "ACTIVE"
    case NOT_ACTIVE = "NOTACTIVE"
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
    /// TouchPad
    case OKBTN = "OKBTN"
    case DRAGON = "DRAGON_"
    case DRAGOFF = "DRAGOFF_"
    // LICU function
    case EPB_ON = "EPB_ON"
    case EPB_OFF = "EPB_OFF"
    case LIGHT_ON = "HL_ON"
    case LIGHT_OFF = "HL_OFF"
    case GEAR = "GEAR_"
    case CHARISMA = "CHARISMA_"
}
enum gear {
    case R, P, N, One, Two, Three, Four, Five, Six, Seven
}

// Dispatches
extension DispatchQueue {

    static func connectToServer(socket: TCPClient, ip: String, feedback: ((Bool) -> Void)? = nil) {
        print("Connecting to: \(ip)")
        var ok: Bool = false
        DispatchQueue.global(qos: .background).async {
            socket.setAddress(newAddress: ip)
            socket.setPort(newPort: 9001)
            let result = socket.connect(timeout: 10)
            switch result {
            case .success:
                ok = true
            case .failure(let error):
                print(error)
            }
            if let feedback = feedback {
                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                    feedback(ok)
                })
            }
        }
    }
    
    static func checkServerType(socket: TCPClient, feedback: ((String) -> Void)? = nil) {
        var hostType: String = messages.NOK.rawValue
        DispatchQueue.global(qos: .background).async {
            let ask: String = messages.HOST_REQ.rawValue
            let result = socket.send(string: ask)
            switch result {
            case .success:
                while Int(socket.bytesAvailable() ?? 0) == 0 {
                    Thread.sleep(forTimeInterval: 0.1)
                }
                guard let data = socket.read(Int(socket.bytesAvailable() ?? 32)) else { break }
                if let response = String(bytes: data, encoding: .utf8) {
                    if response != messages.NOK.rawValue {
                        hostType = response
                    }
                }
            case .failure(let error):
                print(error)
            }
            if let feedback = feedback {
                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                    feedback(hostType)
                })
            }
        }
    }
}

struct Queue<T> {
    private var elements: [T] = []
    
    mutating func enqueue(_ value: T) {
        elements.append(value)
    }
    
    mutating func dequeue() -> T? {
        guard !elements.isEmpty else {
            return nil
        }
        return elements.removeFirst()
    }
    
    var head: T? {
        return elements.first
    }
    
    var tail: T? {
        return elements.last
    }
}

final class MessageHandler {
    // Public
    var socket: TCPClient
    var feedback: ((String) -> Void)?
    
    // Private
    private var messagesInQueued: Queue<String> = Queue<String>()
    private var queue = DispatchQueue(label: "volantiere.messages.queue", attributes: .concurrent)
    private var stop = false
    
    // Initializer
    internal init(socket: TCPClient, feedback: ((String) -> Void)? = nil) {
        self.socket = socket
        self.feedback = feedback
    }

    // Public var
    var lastMessage: String? {
        return queue.sync {
            messagesInQueued.dequeue()
        }
    }

    // Public funcs
    func setFeedbackFunc(feedback newFeedback: ((String) -> Void)? = nil) -> Void {
        self.feedback = newFeedback
    }
    
    func postMessage(_ newMessage: String) {
        queue.sync(flags: .barrier) {
            messagesInQueued.enqueue(newMessage)
        }
    }
    
    func stopThread() -> Void {
        self.stop = true
    }
    
    func startThread() -> Void {
        var toSend: String?
        var ok: Bool = false
        var feed: String = messages.NOK.rawValue
        DispatchQueue.global(qos: .background).async {
            print("Starting sending dequeue thread")
            while !self.stop {
                toSend = self.lastMessage
                if toSend != nil {
                    // Send it
                    let result = self.socket.send(string: toSend!)
                    switch result {
                    case .success:
                        while Int(self.socket.bytesAvailable() ?? 0) == 0 {
                            Thread.sleep(forTimeInterval: 0.001)
                        }
                        guard let data = self.socket.read(Int(self.socket.bytesAvailable() ?? 32)) else { break }
                        if let response = String(bytes: data, encoding: .utf8) {
                            if response == "OK" {
                                ok = true
                            } else {
                                ok = false
                                feed = response
                            }
                        }
                    case .failure(let error):
                        print(error)
                    }
                    if !ok {
                        if let feedback = self.feedback {
                            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                                feedback(feed)
                            })
                        }
                    }
                } else {
                    // Wait a little bit
                    Thread.sleep(forTimeInterval: 0.001)
                }
            }
            print("Stopped thread")
        }
    }
}
