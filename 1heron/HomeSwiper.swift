//
//  HomeSwiper.swift
//  1heron
//
//  Created by Tomi on 2020/4/16.
//  Copyright © 2020 lintaoming. All rights reserved.
//

import SwiftUI
import Combine
import SDWebImageSwiftUI

struct HomeSwiper<Content: View>: View {
    private var numberOfImages: Int
    private var delay: Double
    private var content: Content
    private var timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    @State private var currentIndex: Int = 0
    @State private var viewState: CGSize = CGSize.zero
    @State private var isDrag: Bool = false
    
    init(numberOfImages: Int, delay: Double = 5, @ViewBuilder content: () -> Content) {
        self.numberOfImages = numberOfImages
        self.delay = delay
        self.timer = Timer.publish(every: Double(delay), on: .main, in: .common).autoconnect()
        self.content = content()
    }
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                self.content
            }
            .frame(width: geometry.size.width, alignment: .leading)
            .offset(x: CGFloat(self.currentIndex) * -geometry.size.width, y: 0)
            .offset(x: self.viewState.width)
            .animation(.spring())
            .onReceive(self.timer) { _ in
                print(self.timer)
                self.currentIndex = (self.currentIndex + 1) % 3
            }
            .gesture(DragGesture()
                .onChanged { value in
                    self.isDrag = true
                    self.viewState = value.translation
                }
                .onEnded { value in
                    let currentIndex = self.currentIndex
                    if value.translation.width < -100 {
                        if (self.currentIndex + 1) % 3 == 0 {
                            self.viewState = .zero
                            return
                        }
                        self.viewState = .zero
                        self.currentIndex = (self.currentIndex + 1) % 3
                    }
                    if value.translation.width > 100 {
                        if self.currentIndex % 3 <= 0 {
                            self.viewState = .zero
                            return
                        }
                        self.viewState = .zero
                        self.currentIndex = (self.currentIndex - 1) % 3
                    }
                    if self.currentIndex != currentIndex {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                           self.isDrag = false
                       }
                    }
                    self.viewState = .zero
                }
            )
            .onAppear()
        }
    }
}

struct HomeSwiper_Previews: PreviewProvider {
    static var previews: some View {
        HomeSwiper(numberOfImages: 3) {
            ForEach(0 ..< 3) { item in
                WebImage(url: URL(string: "\(IMAGE_DOMAIN)ad/151056372240931.jpg"))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width:SCREEN.width)
            }
        }
        .background(Color.red)
    }
}
