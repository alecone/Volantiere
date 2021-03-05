//
//  RecentRaspberries.swift
//  Volantiere
//
//  Created by Alexandru Cone on 26/02/21.
//

import SwiftUI

struct RecentRaspberries: View {
    let raspies = JSONHelper.loadRaspberries()
    var body: some View {
        NavigationView {
            List {
                ForEach(raspies) { name in
                    Section(header: Text(name.name)) {
                        Text(name.ip)
                    }
                }
            }
            .navigationBarTitle("Recent Raspberries")
            .listStyle(GroupedListStyle())
        }
    }
}

struct RecentRaspberries_Previews: PreviewProvider {
    static var previews: some View {
        RecentRaspberries()
    }
}
