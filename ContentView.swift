//
//  ContentView.swift
//  Foldable List
//
//  Created by gwwo on 27/7/2022.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var list = ListModel()
    var body: some View {
        ListView().environmentObject(list)
            .backgroundColor(Color.brown)
            .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
