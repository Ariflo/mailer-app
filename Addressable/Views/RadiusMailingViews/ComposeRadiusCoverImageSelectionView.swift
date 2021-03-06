//
//  ComposeRadiusCoverArtSelectionView.swift
//  Addressable
//
//  Created by Ari on 4/22/21.
//

import SwiftUI
import UIKit

struct ComposeRadiusCoverImageSelectionView: View {
    @ObservedObject var viewModel: ComposeRadiusViewModel

    init(viewModel: ComposeRadiusViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        if viewModel.loadingImages {
            VStack {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                Spacer()
            }.frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity,
                alignment: .center
            )
        } else if viewModel.mailingCoverImages.count < 1 && !viewModel.loadingImages {
            VStack {
                Spacer()
                EmptyListView(message: "No stationary avaliable. Please visit the 'Content' section " +
                                "of the Addressable.app portal to upload cover art and continue.")
                Spacer()
            }
        } else {
            VStack {
                TabView(selection: $viewModel.selectedCoverImageID) {
                    ForEach(Array(viewModel.mailingCoverImages.keys), id: \.self) { coverImageID in
                        if let imageData = viewModel.mailingCoverImages[coverImageID] {
                            MailingCoverArtView(coverImage: imageData).tag(coverImageID)
                        }
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 475)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always)
                )
                Spacer()
            }
        }
    }
}

#if DEBUG
struct ComposeRadiusCoverArtSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ComposeRadiusCoverImageSelectionView(
            viewModel: ComposeRadiusViewModel(provider: DependencyProvider(), selectedMailing: nil)
        )
    }
}
#endif
