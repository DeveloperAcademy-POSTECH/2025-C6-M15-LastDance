//
//  ResponseView.swift
//  LastDance
//
//  Created by donghee on 10/19/25.
//

import SwiftData
import SwiftUI

struct ResponseView: View {
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var viewModel: ResponseViewModel
    @Query private var allArtworks: [Artwork]
    let artworkId: Int

    init(artworkId: Int) {
        self.artworkId = artworkId
        _viewModel = StateObject(wrappedValue: ResponseViewModel(artworkId: artworkId))
    }

    private var artwork: Artwork? {
        allArtworks.first { $0.id == artworkId }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ResponseContentView(
                    artwork: artwork,
                    viewModel: viewModel
                )
            }
            BlurEffectView()
        }
        .background(LDColor.color5)
        .ignoresSafeArea(.container, edges: .bottom)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            CustomWhiteNavigationBar(title: artwork?.title ?? "작품 반응") {
                router.popLast()
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

// MARK: - ResponseContentView

struct ResponseContentView: View {
    let artwork: Artwork?
    @ObservedObject var viewModel: ResponseViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ArtworkBackgroundView(artwork: artwork)
                    .offset(y: -120)
                    .ignoresSafeArea(.container, edges: .top)
                    .padding(.bottom, -120)

                ReactionListView(viewModel: viewModel)
                    .padding(.top, 20)
            }
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer().frame(height: 343 - 120 - 40)
                    ReactionHeaderView(count: viewModel.reactions.count)
                }
            }
        }
        .scrollToMinDistance(minDisntance: 32)
    }
}

// MARK: - ReactionListView

struct ReactionListView: View {
    @ObservedObject var viewModel: ResponseViewModel

    var body: some View {
        ReactionItemsView(viewModel: viewModel)
    }
}

// MARK: - ReactionHeaderView

struct ReactionHeaderView: View {
    let count: Int

    var body: some View {
        HStack {
            Text("반응")
                .font(LDFont.heading03)
            Text("\(count)")
                .font(LDFont.regular03)
                .foregroundColor(LDColor.color6)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.black)
                .clipShape(Circle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 4)
    }
}

// MARK: - ReactionItemsView

struct ReactionItemsView: View {
    @ObservedObject var viewModel: ResponseViewModel

    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(viewModel.reactions.indices, id: \.self) { index in
                ReactionItemView(
                    reaction: viewModel.reactions[index],
                    viewModel: viewModel
                )
                .padding(.horizontal, 20)

                if index < viewModel.reactions.count - 1 {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: 2)
                        .background(Color(red: 0.94, green: 0.94, blue: 0.94))
                        .padding(.bottom, 16)
                }
            }
        }
        .padding(.bottom, 120)
    }
}

// MARK: - BlurEffectView

struct BlurEffectView: View {
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                LinearGradient(
                    gradient: Gradient(colors: [
                        LDColor.color5.opacity(0),
                        LDColor.color5,
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 100 + geometry.safeAreaInsets.bottom)
                .offset(y: geometry.safeAreaInsets.bottom)
                .allowsHitTesting(false)
            }
        }
    }
}

