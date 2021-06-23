//
//  MailingsViewModel.swift
//  Addressable
//
//  Created by Ari on 12/29/20.
//

import SwiftUI
import Combine

class DashboardViewModel: ObservableObject {
    @Published var loading: Bool = false

    private let apiService: ApiService
    private var disposables = Set<AnyCancellable>()

    init(provider: DependencyProviding) {
        apiService = provider.register(provider: provider)
    }
}
