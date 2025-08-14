//
//  SwiftUIView.swift
//  Melody Practice
//
//  Created by 이신원 on 8/4/25.
//

import SwiftUI

struct PlayIntroView: View {
    @Environment(ModelData.self) var modelData
    
    var body: some View {
        VStack {
            CoverFlowList(
                itemWidth: 600,
                enableReflection: true,
                spacing: 10,
                rotation: 50,
                items: modelData.plays.prefix(3)
            ){ item in
                CoverFlowCard(item: item)
            }
            .frame(height: 500)
        }
    }
}

#Preview {
    PlayIntroView()
}
