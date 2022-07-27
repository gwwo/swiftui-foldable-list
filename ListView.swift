//
//  ListView.swift
//  Foldable List
//
//  Created by gwwo on 27/7/2022.
//

import SwiftUI


struct ListView: View {
    @EnvironmentObject var list: ListModel
    @StateObject var visual = ListVisualModel()

    
    var body: some View {

        return ScrollView {
            VStack(spacing:0) {
                ForEach(0..<visual.pairs.count, id: \.self) { index in
                    let pair = visual.pairs[index]
                    let isHead = index == 0
                    let isTail = index == visual.pairs.count - 1
                    
                    if !isHead {
                        FoldView(content: pair.topHalf, role: .top(isTail: isTail), degree: pair.degree)
                            .animation(.easeInOut(duration: pair.duration ?? 0).delay(pair.delay ?? 0), value: pair.degree)
                    }
                    if !isTail {
                        FoldView(content: pair.bottomHalf, role: .bottom(isHead: isHead), degree: pair.degree)
                            .animation(.easeInOut(duration: pair.duration ?? 0).delay(pair.delay ?? 0), value: pair.degree)
                    }
                }
            }
            .padding(.vertical, 60).padding(.horizontal, 10)
        }
        .onAppear {
            switch list.state {
            case .folded:
                visual.fold(with: list.info).start(onComplete: {
                    list.tap(entry: .resume)
                })
            case _: return
            }
        }
        .onChange(of: list.state) { state in
            print("onChange", state)
            switch state {
            case .folding:
                visual.fold().start(.fromBottom(cascadeTime: 0.2, rotateTime: 1.2), onComplete: {
                    list.state = .folded
                })
            case .unfolding:
                visual.unfold(with: list.info).start(.fromTop(cascadeTime: 0.2, rotateTime: 1.2), onComplete: {
                    list.state = .unfolded
                })
            case _: return
            }
        }
    }
}

