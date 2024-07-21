//
//  DefaultButtonStyle.swift
//  SampleSQLiteAppProject
//
//  Created by 佐藤汰一 on 2024/07/20.
//

import SwiftUI

struct DefaultButtonStyle: ButtonStyle {
    
    init(foregroundColor: Color, backgroundColor: Color, borderWidth: CGFloat, borderRadius: CGFloat) {
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.borderWidth = borderWidth
        self.borderRadius = borderRadius
    }
    
    private let foregroundColor: Color
    private let backgroundColor: Color
    private let borderWidth: CGFloat
    private let borderRadius: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(foregroundColor)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: borderRadius))
            .overlay {
                RoundedRectangle(cornerRadius: borderRadius)
                    .stroke(lineWidth: borderWidth)
            }
    }
}

extension Button {
    
    func defaultButtonStyle(foregroundColor: Color = .black,
                            backgroundColor: Color = .white,
                            borderWidth: CGFloat = .zero,
                            borderRadius: CGFloat = .zero) -> some View {
        
        return self.buttonStyle(DefaultButtonStyle(foregroundColor: foregroundColor,
                                                   backgroundColor: backgroundColor,
                                                   borderWidth: borderWidth,
                                                   borderRadius: borderRadius))
    }
}
