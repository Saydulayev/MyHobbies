//
//  AnimatedText.swift
//  MyHobbies
//
//  Created by Akhmed on 09.10.23.
//

import SwiftUI

struct AnimatedText: View {
    let text: String
    @State private var visibleCharacters: Int = 0

    var body: some View {
        HStack(spacing: 0) {
            withAnimation {
                ForEach(Array(text.enumerated()), id: \.offset) { offset, character in
                    Text(String(character))
                        .opacity(offset < visibleCharacters ? 1 : 0)
                }
            }
        }
        .onAppear {
            let total = text.count

            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                withAnimation {
                    visibleCharacters += 1
                }

                if visibleCharacters >= total {
                    timer.invalidate()
                }
            }
        }
    }
}



#Preview {
    AnimatedText(text: "")
}
