//
//  RecentRaspberries.swift
//  Volantiere
//
//  Created by Alexandru Cone on 26/02/21.
//

import SwiftUI

struct RecentRaspberries: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var raspberries: Raspberries
    
    var body: some View {
        NavigationView {
            List {
                ForEach(raspberries.raspberries) { name in
                    Section(header: Text(name.name)) {
                        RaspberryRow(isPresented: $isPresented, raspberry: name)
                    }
                }
            }
            .navigationBarTitle("Recent Raspberries")
            .listStyle(GroupedListStyle())
        }
    }
}

//struct RecentRaspberries_Previews: PreviewProvider {
//    static var previews: some View {
//        RecentRaspberries()
//    }
//}
