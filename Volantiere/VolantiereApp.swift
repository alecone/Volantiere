//
//  VolantiereApp.swift
//  Volantiere
//
//  Created by Alexandru Cone on 24/02/21.
//

import SwiftUI

class GlobalIP: ObservableObject {
    @Published var ip: String = ""
    @Published var loaded: Bool = false
}

@main
struct VolantiereApp: App {
    @StateObject var raspberries = Raspberries()
    @StateObject var IP = GlobalIP()
    var socket: TCPClient = TCPClient()
    
    var body: some Scene {
        WindowGroup {
            LogInView(socket: socket)
                .environmentObject(raspberries)
                .environmentObject(IP)
        }
    }
}
