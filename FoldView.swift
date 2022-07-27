//
//  FoldView.swift
//  Foldable List
//
//  Created by gwwo on 27/7/2022.
//

import SwiftUI



struct FoldView: View {

    @EnvironmentObject var list: ListModel
    
    var content: EntryContent?
    var role: FoldRole
    var degree: Double
    var height: CGFloat = 60
    
    @State private var dynamic: FoldDynamic = FoldDynamic(degree: 90, height: 0)
    
    var body: some View {
        Button(action: {
            if let content = content {
                list.tap(entry: content.entry)
            }
        }) {
            VStack(spacing: 0){
                Rectangle().fill(Color.gray.opacity(0.2)).frame(height: role.needTopBorder ? 1 : 0)
                EntryView(content: dynamic.degree > 84 ? nil : content)
            }
            .frame(height: role.needTopBorder ? height : height - 1)
            .contentShape(Rectangle())
        }
        .buttonStyle(FoldButtonStyle())
        .padding(.bottom, role.bottomPadding)
        .backgroundColor(.white)
        .fold(for: role, to: degree, updating: $dynamic)
        .drawingGroup()
        .frame(height: dynamic.height, alignment: role.alignment)
        .disabled(list.state != .unfolded)
        
    }
}


struct FoldButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        ZStack{
            configuration.label
            Color.gray.opacity(configuration.isPressed ? 0.3: 0)
        }
    }
}


extension View {
    func backgroundColor(_ color: Color) -> some View {
        modifier(BackgroundView(color: color))
    }
}

struct BackgroundView : ViewModifier{
    let color: Color
    func body(content: Content) -> some View {
        ZStack {
            color
            content
        }
    }
}


