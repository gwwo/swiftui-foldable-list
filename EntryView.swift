//
//  EntryView.swift
//  Foldable List
//
//  Created by gwwo on 27/7/2022.
//

import SwiftUI

struct EntryView: View, Animatable {
    var content: EntryContent?
    var body: some View {
        GeometryReader{ geometry in
            HStack(alignment: .center, spacing:0) {
                
                if let content = content {
                    Text("\(content.leading)").foregroundColor(.gray)
                        .font(.system(size: 11)).lineLimit(1)
                        .frame(minWidth: geometry.size.width * 0.08, alignment: .center)
                    
                    Text(content.left).foregroundColor(.black)
                        .font(.system(size: 16)).fontWeight(.bold).minimumScaleFactor(0.7)
                        .frame(maxWidth:.infinity)
                        .padding(.horizontal,5)
                    
                    Text(content.right).foregroundColor(.black)
                        .font(.system(size: 13)).minimumScaleFactor(0.8)
                        .frame(width: geometry.size.width * 0.5)
                }
            }.position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }.padding(5)
    }
}
