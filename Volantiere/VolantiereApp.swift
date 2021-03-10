//
//  VolantiereApp.swift
//  Volantiere
//
//  Created by Alexandru Cone on 24/02/21.
//

import SwiftUI

@main
struct VolantiereApp: App {
    @StateObject var raspberries = Raspberries()
    var socket: TCPClient = TCPClient()
    
    var body: some Scene {
        WindowGroup {
            LogInView(socket: socket).environmentObject(raspberries)
        }
    }
}
