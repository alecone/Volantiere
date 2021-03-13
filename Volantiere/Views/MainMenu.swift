//
//  MainMenu.swift
//  Volantiere
//
//  Created by Alexandru Cone on 26/02/21.
//

import SwiftUI

struct MainMenu: View {
    
    var socket: TCPClient
    
    var body: some View {
        Button(action: {
            print("Going to connect")
        }) {
            Image(systemName: "pip.exit")
        }
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
