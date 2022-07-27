//
//  FoldViewControl.swift
//  Foldable List
//
//  Created by gwwo on 27/7/2022.
//

import SwiftUI

struct FoldDynamic {
    var degree: Double
    var height: CGFloat
}

enum FoldRole: Equatable {
    case top(isTail: Bool)
    case bottom(isHead: Bool)
    var alignment: Alignment {
        switch self {
        case .top: return .top
        case .bottom: return .bottom
        }
    }
    var needTopBorder: Bool {
        switch self{
        case .bottom(isHead: true): return false
        case _: return true
        }
    }
    var bottomPadding: CGFloat {
        switch self {
        case .top(isTail: false): return 30
        case _: return 0
        }
    }
}

extension View {
    func fold(for role: FoldRole, to degree: Double, updating dynamic: Binding<FoldDynamic>) -> some View{
        self.modifier(FoldShadow(role: role, degree: degree))
            .modifier(FoldRotate3D(role: role, degree: degree, dynamic: dynamic))
    }
}

struct FoldShadow: AnimatableModifier {
    var animatableData: Double{
        get{ degree }
        set{ degree = newValue }
    }
    var role: FoldRole
    var degree: Double
    
    func body(content: Content) -> some View {
        let gradient: [Double]
        switch(role){
        case .top: gradient = [0.3, 0.4, 0.4, 0.5, 0.6]
        case .bottom(isHead: false): gradient =  [0.6, 0.5, 0.4, 0.3]
        case .bottom(isHead: true): gradient = [0.2]
        }
        let factor = pow((degree/90), 2)
        let colors: [Color] = gradient.map{Color.black.opacity( $0 * factor)}
        let gradientLayer = LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: UnitPoint(x: 0, y: 0),
            endPoint: UnitPoint(x: 0, y: 1))
        
        return content.overlay(gradientLayer)
    }
}




struct FoldRotate3D: GeometryEffect {
    var role: FoldRole
    var degree: Double
    @Binding var dynamic: FoldDynamic

    var animatableData: Double {
        get { degree }
        set { degree = newValue }
    }
    var m34: CGFloat = -1/2000.0
    func effectAsTop(size: CGSize, extraHeight: CGFloat) -> ProjectionTransform {
        var transform3d = CATransform3DIdentity
        transform3d.m34 = m34
        transform3d = CATransform3DRotate(transform3d, CGFloat(Angle(degrees: -degree).radians), 1, 0, 0)
        transform3d = CATransform3DTranslate(transform3d, -size.width/2.0, 0, 0)
        let heightVisible = size.height - extraHeight
        let height = (heightVisible * transform3d.m22 + transform3d.m42) / ( heightVisible * transform3d.m24 + transform3d.m44)
        DispatchQueue.main.async {
            dynamic = FoldDynamic(
                degree: degree,
                height: height
            )
        }
        let affineTransform = CGAffineTransform(translationX: size.width/2.0, y: 0)
        return ProjectionTransform(transform3d).concatenating(ProjectionTransform(affineTransform))
    }
    func effectAsBottom(size: CGSize) -> ProjectionTransform {
        var transform3d = CATransform3DIdentity
        transform3d.m34 = m34
        transform3d = CATransform3DRotate(transform3d, CGFloat(Angle(degrees: degree).radians), 1, 0, 0)
        transform3d = CATransform3DTranslate(transform3d, -size.width/2.0, -size.height, 0)
        DispatchQueue.main.async {
            dynamic = FoldDynamic(
                degree: degree,
                height: -transform3d.m42 / transform3d.m44
            )
        }
        let affineTransform = CGAffineTransform(translationX: size.width/2.0, y: size.height)
        return ProjectionTransform(transform3d).concatenating(ProjectionTransform(affineTransform))
    }
    func effectValue(size: CGSize) -> ProjectionTransform {
        switch(role){
        case .top:
            return effectAsTop(size: size, extraHeight: role.bottomPadding)
        case .bottom:
            return effectAsBottom(size: size)
        }
    }
}
