//
//  ListViewControl.swift
//  Foldable List
//
//  Created by gwwo on 27/7/2022.
//

import Foundation



class FoldableModel: ObservableObject {
    enum State {
        case unfolding
        case folding
        case unfolded
        case folded
    }
    
    private var onFolded: (() -> Void)?
    private var onUnfolded: (() -> Void)?
    
    
    @Published var state: FoldableModel.State = .folded {
        didSet(oldState) {
            print("from", oldState, "to", state)
            if oldState == .folding && state == .folded {
                onFolded?()
                onFolded = nil
            }
            if oldState == .unfolding && state == .unfolded {
                onUnfolded?()
                onUnfolded = nil
            }
        }
    }
    
    func fold() async {
        return await withCheckedContinuation { continuation in
            if state == .folded {
                continuation.resume(returning: ())
                return
            }
            DispatchQueue.main.async { [self] in
                state = .folding
            }
            onFolded = { continuation.resume(returning: ()) }
        }
    }
    
    func unfold() async {
        return await withCheckedContinuation { continuation in
            if state == .unfolded {
                continuation.resume(returning: ())
                return
            }
            DispatchQueue.main.async { [self] in
                state = .unfolding
            }
            onUnfolded = { continuation.resume(returning: ()) }
        }
    }
}



class ListVisualModel: ObservableObject{
    struct FoldPair {
        var topHalf: EntryContent?
        var bottomHalf: EntryContent?
        var degree: Double
        var duration: Double?
        var delay: Double?
        
        func changing(change : (inout FoldPair)->Void) -> FoldPair {
            var it = self
            change(&it)
            return it
        }
    }
    

    let limitFixedFolds = 2
    let limitBodyFolds = 20
    
    var numPairs: Int {
        limitFixedFolds * 2 + limitBodyFolds + 2
    }

    var pairs: [FoldPair] = []
    var numVisibleFront: Int {
        var i = 0
        while i < pairs.count && pairs[i].degree != 90 { i += 1 }
        return i == pairs.count ? pairs.count/2 + pairs.count%2 : i
    }
    var numVisibleBack: Int {
        var i = pairs.count - 1
        while i >= 0  && pairs[i].degree != 90 { i -= 1 }
        return i == -1 ? pairs.count/2 : pairs.count - 1 - i
        
    }
    
    var nextPairs: [FoldPair] = []
    
    struct Animation {
        var cascadeTime: Double
        var rotateTime: Double
        var reversed: Bool
        static func fromTop(cascadeTime: Double, rotateTime: Double)-> Self{
            Animation(cascadeTime: cascadeTime, rotateTime: rotateTime, reversed: false)
        }
        static func fromBottom(cascadeTime: Double, rotateTime: Double)-> Self{
            Animation(cascadeTime: cascadeTime, rotateTime: rotateTime, reversed: true)
        }
    }
    func start(_ animation: Animation? = nil, onComplete: (()->Void)? = nil) {

        var delay: Double = 0
        if let animation = animation {
            var i = animation.reversed ? pairs.count - 1 : 0
            var factor: Double = 0
            while i >= 0 && i < pairs.count {
                factor = abs(cos(pairs[i].degree * .pi / 180) - cos(nextPairs[i].degree * .pi / 180))
                nextPairs[i].delay = delay
                nextPairs[i].duration = max(0.6, factor) * animation.rotateTime
                i += animation.reversed ? -1 : 1
                delay += factor < 0.6 ? 0 : animation.cascadeTime
            }
            delay -= factor * animation.cascadeTime
            delay += max(0.6, factor) * animation.rotateTime
        }
        
        pairs = nextPairs
        objectWillChange.send()
        
        if let onComplete = onComplete {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay){
                onComplete()
            }
        }
    }
    
    
    func fold(with info: ListInfo? = nil) -> Self {
        
        let pairs: [FoldPair]
        
        if let info = info {
            _ = unfold(with: info)
            pairs = nextPairs
        } else {
            pairs = self.pairs
        }
        
        let degreesWhenFolded: [Double] =
            [60, 80, 83, 85] + Array(repeating: 90, count: pairs.count - 8) + [87, 87, 87, 87]

        nextPairs = pairs.enumerated().map { i, pair in
            pair.changing{ it in it.degree = degreesWhenFolded[i] }
        }
        return self
    }
    
    
    func unfold(with info: ListInfo) -> Self {
        
        let numFrontFolds = info.passed/2 + info.passed%2
        let numFixedFrontFolds = min(limitFixedFolds, numFrontFolds)
        let numBackFolds = info.remain/2 + info.remain%2
        let numFixedBackFolds = min(limitFixedFolds, numBackFolds)
        
        
        let pairsFromHead = [FoldPair(bottomHalf: info.head, degree: 0)] + Array(repeating: FoldPair(degree: 87), count: numFixedFrontFolds)
        let pairsFromTail = Array(repeating: FoldPair(degree: 87), count: numFixedBackFolds) + [FoldPair(topHalf: info.tail, degree: 0)]
        
        let pairsForBody: [FoldPair] = ( 0..<(info.body.count/2+info.body.count%2) ).map { i in
            FoldPair(topHalf: info.body[i*2],
                     bottomHalf: i*2+1 >= info.body.count ? nil : info.body[i*2+1],
                     degree: 0)
        }
        
        var numFlexibleFrontFolds = numFrontFolds - numFixedFrontFolds
        var numFlexibleBackFolds = numBackFolds - numFixedBackFolds
        
        var numFrontPairs = max(0, numVisibleFront - pairsFromHead.count)
        var numBackPairs = max(0, numVisibleBack - pairsFromTail.count)
        
        var balance = pairsForBody.count - numFrontPairs - numBackPairs
        
        if balance < 0 && balance + numFlexibleFrontFolds + numFlexibleBackFolds >= 0 {
            balance = -balance
            numFlexibleFrontFolds = balance * numFlexibleFrontFolds / (numFlexibleFrontFolds + numFlexibleBackFolds)
            numFlexibleBackFolds = balance - numFlexibleFrontFolds
        }
        else {
            if balance >= 0 {
                numFlexibleFrontFolds = 0
                numFlexibleBackFolds = 0
            }
            balance +=  numFlexibleFrontFolds + numFlexibleBackFolds
            
            let a = pairsFromHead.count + numFrontPairs
            let b = pairsFromTail.count + numBackPairs
            let forFair = (balance > 0 ? 1 : -1) * min(abs(a - b), abs(balance))
            numFrontPairs += (balance - forFair) / 2 + (a-b)*forFair<0 ? forFair : 0

        }
        
        
        let pairsForFrontFolds = Array(repeating: FoldPair(degree: 87), count: numFlexibleFrontFolds)
        let pairsForBackFolds = Array(repeating: FoldPair(degree: 87), count: numFlexibleBackFolds)
        let pairsVisible = pairsForFrontFolds + pairsForBody + pairsForBackFolds

        let numInvisiblePairs = numPairs - pairsFromHead.count - pairsFromTail.count - pairsVisible.count
        
        nextPairs = pairsFromHead +
                    pairsVisible[0..<numFrontPairs] +
                    Array(repeating: FoldPair(degree: 90), count: numInvisiblePairs) +
                    pairsVisible[numFrontPairs..<pairsVisible.count] +
                    pairsFromTail
        
        return self
    }
}

