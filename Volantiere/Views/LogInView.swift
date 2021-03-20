//
//  LogInView.swift
//  Volantiere
//
//  Created by Alexandru Cone on 24/02/21.
//

import SwiftUI

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

struct LogInView: View {
    @EnvironmentObject var raspberries: Raspberries
    @EnvironmentObject var IP: GlobalIP
    var socket: TCPClient
    
    @State private var ip1 = ""
    @State private var ip2 = ""
    @State private var ip3 = ""
    @State private var ip4 = ""
    @State private var goToRecents = false
    @State private var goToMain = false
    @State private var showingAlert = false
    @State private var showTextFieldAlert = false
    @State private var newRaspoName: String?
    @State private var showConnecting: Bool = false
    @State private var showingConnNOK = false
    
    
    var body: some View {
        ZStack {
            VStack {
                Image("raspberry").resizable().frame(width: 300, height: 300, alignment: .top)
                
                Text("VolantiereApp")
                    .font(.title)
                    .fontWeight(.heavy)
                    .foregroundColor(Color("AccentColor"))
                    .multilineTextAlignment(.center)
                    .padding(.top, 15)
                
                Text("Raspberry IP address").font(.subheadline).fontWeight(.heavy).foregroundColor(Color("AccentColor")).multilineTextAlignment(.center)
                    .padding(.top, 5)
                
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 10.0, content: {
                    TextField(IP.ip.split(separator: ".").count == 0 ? "255" : String(IP.ip.split(separator: ".")[0]), text: self.$ip1).keyboardType(.numberPad).multilineTextAlignment(.center).textFieldStyle(RoundedBorderTextFieldStyle()).onChange(of: ip1, perform: { value in
                        self.ip1 = validate(ip1)
                    })
                    TextField(IP.ip.split(separator: ".").count == 0 ? "255" : String(IP.ip.split(separator: ".")[1]), text: self.$ip2).keyboardType(.numberPad).multilineTextAlignment(.center)
                        .textFieldStyle(RoundedBorderTextFieldStyle()).onChange(of: ip2, perform: { value in
                            self.ip2 = validate(ip2)
                        })
                    TextField(IP.ip.split(separator: ".").count == 0 ? "255" : String(IP.ip.split(separator: ".")[2]), text: self.$ip3).keyboardType(.numberPad).multilineTextAlignment(.center)
                        .textFieldStyle(RoundedBorderTextFieldStyle()).onChange(of: ip3, perform: { value in
                            self.ip3 = validate(ip3)
                        })
                    TextField(IP.ip.split(separator: ".").count == 0 ? "255" : String(IP.ip.split(separator: ".")[3]), text: self.$ip4).keyboardType(.numberPad).multilineTextAlignment(.center)
                        .textFieldStyle(RoundedBorderTextFieldStyle()).onChange(of: ip4, perform: { value in
                            self.ip4 = validate(ip4)
                        })
                }).padding(.vertical, 20).padding(.horizontal, 80)
                Button(action: {self.connect()}, label: {
                    HStack{
                        Text("CONNECT")
                            .multilineTextAlignment(.center)
                    }.padding(.horizontal, 70).padding(.vertical, 10)
                })
                .disabled(self.showConnecting)
                .background(Color("AccentColor"))
                .foregroundColor(.white).cornerRadius(35)
                .alert(isPresented: $showingAlert) {
                    wrongIpAlert
                }
                .alert(isPresented: $showingConnNOK, content: {
                    connectionFailed
                })
                .textFieldAlert(isPresented: $showTextFieldAlert, content: askNewRaspName)
                if self.showConnecting {
                    ProgressView().progressViewStyle(DarkBlueShadowProgressViewStyle()).zIndex(/*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
                }
                Spacer()
                HStack {
                    Text("Recent Raspberry?")
                    Button(action: self.openRecentRaspberries, label: {
                        Text("Raspberries").foregroundColor(Color("AccentColor"))
                    })
                    .disabled(self.showConnecting)
                }.padding()
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 50)
                    .onEnded { _ in
                        hideKeyboard()
                    }
            )
        }
        .zIndex(0)
        .navigate(to: MainMenu(socket: socket), when: $goToMain)
        .sheet(isPresented: $goToRecents, content: {
            RecentRaspberries(isPresented: $goToRecents)
        })
    }
    
    /// Unused
    // inout is used in order to change string inside the func
    func validateIp(from ip: inout String?, max length: Int){
        if ip!.count > 3 {
            ip = String(ip!.prefix(length))
        }
    }
    
    func validate(_ ip: String) -> String {
        var newIp: String = ip
        if ip.count > 3 {
            newIp = String(ip.prefix(3))
        }
        return newIp
    }
    
    func connect() -> Void {
        self.showConnecting = true
        if !IP.loaded {
            IP.ip = ip1 + "." + ip2 + "." + ip3 + "." + ip4
        } else {
            // Reset flag
            IP.loaded = false
        }
        let ipOk = validateIpAddress(in: IP.ip)
        if ipOk {
            print("Connecting to \(IP.ip)")
            socket.setAddress(newAddress: IP.ip)
            socket.setPort(newPort: 9001)
            switch socket.connect(timeout: 10) {
            case .success:
                print("Connected 🎉")
                self.showConnecting = false
                self.goToMain = true
                break
            case .failure(let error):
                self.showConnecting = false
                self.showingConnNOK = true
                print("💩 \(error)")
            }
            // Check if already saved
            let connectedRaspberry: Raspberry = Raspberry(id: UUID(), name: "", ip: IP.ip)
            let saved: Bool = JSONHelper.raspberryAlreadySaved(check: connectedRaspberry)
            if !saved {
                self.showTextFieldAlert = true
            }
        } else {
            print("Showing alert for bad connection")
            self.showingAlert = true
            self.showConnecting = false
        }
    }
    
    func openRecentRaspberries() -> Void {
        print("open recent raspberries")
        self.goToRecents = true
    }
    
    func validateIpAddress(in ip: String) -> Bool {
        var ret: Bool = false
        let ipList = ip.split(separator: ".")
        for _ip in ipList {
            if _ip.count < 4 && _ip.count >= 0 {
                if Int(_ip)! >= 0 && Int(_ip)! < 256 {
                    ret = true
                }
                else {
                    ret = false
                    break
                }
            } else {
                ret = false
                break
            }
        }
        
        return ret
    }
    
    func nameToSavedReady() -> Void {
        if self.newRaspoName?.count == 0 {
            print("Giving default name")
            self.newRaspoName = "MyRaspberry"
        }
        // Save it
        print("Saving \(self.newRaspoName ?? "") with IP \(self.IP)")
        let connectedRaspberry: Raspberry = Raspberry(id: UUID(), name: self.newRaspoName!, ip: IP.ip)
        JSONHelper.saveRaspberry(new: connectedRaspberry)
        
        // Update global variable
        raspberries.raspberries = JSONHelper.loadRaspberries()
    }
    
    func askNewRaspName() -> TextFieldAlert {
        return TextFieldAlert(title: "New Raspberry", message: "Give it a name", text: self.$newRaspoName, caller: nameToSavedReady)
    }
    
    var wrongIpAlert = Alert(title: Text("IP address malformed"), message: Text("IP address seams incorrect, try again!"), dismissButton: .default(Text("OK")))
    
    var connectionFailed = Alert(title: Text("Connection Failed"), message: Text("Connection error"), dismissButton: .default(Text("OK")))
}

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView(socket: TCPClient())
    }
}
