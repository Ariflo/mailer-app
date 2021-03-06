//
//  ComposeRadiusView.swift
//  Addressable
//
//  Created by Ari on 2/11/21.
//
import SwiftUI

// MARK: - ListEntryStatus
enum ListEntryMembershipStatus: String {
    case member, rejected, reserved, removed
}
// MARK: - ComposeRadiusSteps
enum ComposeRadiusSteps: String, CaseIterable {
    case selectLocation = "Location of Sale"
    case selectCard = "Choose Card"
    case chooseTopic = "Choose Campaign Type"
    case audienceProcessing = "Audience Processing"
    case confirmAudience = "Confirm Audience"
    case confirmSend = "Confirm and Send"
    case radiusSent = "Radius Mailing Sent"
}
// MARK: - ComposeRadiusAlerts
enum ComposeRadiusAlerts {
    case somethingWentWrong, paymentRequired
}

// MARK: - ListStatus
enum ListStatus: String {
    case new
    case searching
    case searchFailed = "search_failed"
    case exporting
    case exportFailed = "export_failed"
    case ingesting
    case ingestFailed = "ingest_failed"
    case complete
}

// MARK: - ComposeRadiusView
// // swiftlint:disable type_body_length file_length
struct ComposeRadiusView: View {
    @EnvironmentObject var app: Application
    @ObservedObject var viewModel: ComposeRadiusViewModel
    @State var showingAlert: Bool = false
    @State private var alertType: ComposeRadiusAlerts = .somethingWentWrong

    init(viewModel: ComposeRadiusViewModel) {
        self.viewModel = viewModel

        switch self.viewModel.touchOneMailing?.listStatus {
        case ListStatus.searching.rawValue,
             ListStatus.exporting.rawValue,
             ListStatus.ingesting.rawValue:
            self.viewModel.step = .selectCard
        case ListStatus.complete.rawValue:
            if let mailing = self.viewModel.touchOneMailing {
                guard hasCompletedAllSteps(for: mailing) else {
                    if mailing.layoutTemplate == nil {
                        self.viewModel.step = .selectCard
                    } else if mailing.topicSelectionID == nil {
                        self.viewModel.step = .chooseTopic
                    }
                    return
                }
                self.viewModel.step = .confirmAudience
            }
        default:
            self.viewModel.step = .selectLocation
        }
    }

    var body: some View {
        ZStack {
            VStack {
                // MARK: - BreadCrumbHeader
                HStack(alignment: .top) {
                    if let selectedMailingCoverId = viewModel.selectedCoverImageID,
                       let selectedCoverImage = viewModel.mailingCoverImages[selectedMailingCoverId] {
                        CustomNote.CoverImage(imageData: selectedCoverImage.imageData)
                            .frame(maxWidth: 100, maxHeight: 75)
                    } else {
                        Image("BlankCard")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 100, maxHeight: 75)
                    }
                    VStack(alignment: .leading, spacing: 11) {
                        Text("Building Radius Mailing").font(Font.custom("Silka-Medium", size: 12))
                        HStack {
                            if let currentStepIndex = Array(ComposeRadiusSteps.allCases)
                                .firstIndex(of: viewModel.step) {
                                ForEach(Array(ComposeRadiusSteps.allCases).indices, id: \.self) { index in
                                    if index <= currentStepIndex {
                                        generateCompletedStepCircleIndicator(for: currentStepIndex)
                                    } else {
                                        Circle().fill(Color.addressableLighterGray).frame(width: 9, height: 9)
                                    }
                                }
                            }
                        }
                    }.padding(.top, 12)
                }.padding()
                // MARK: - Main Menu
                VStack {
                    if !isScrollableView() {
                        // MARK: - Main Menu Title Header
                        Text(viewModel.step.rawValue)
                            .font(Font.custom("Silka-Medium", size: 22))
                            .padding(.bottom)
                    }
                    // MARK: - Main Radius Menu
                    VStack {
                        switch viewModel.step {
                        case .selectLocation:
                            ComposeRadiusSelectLocationView(viewModel: viewModel)
                                .environmentObject(app)
                                .adaptsToKeyboard()
                        case .selectCard:
                            ComposeRadiusCoverImageSelectionView(viewModel: viewModel)
                        case .chooseTopic:
                            ComposeRadiusTopicSelectionView(viewModel: viewModel, showAlert: {
                                alertType = .somethingWentWrong
                                showingAlert = true
                            }).environmentObject(app)
                        case .audienceProcessing:
                            ComposeRadiusConfirmationView(
                                emptyMessage: "Our team is now building your mailing list." +
                                    " You will receive a notification when the list is " +
                                    "ready for your review."
                            )
                        case .confirmAudience:
                            ComposeRadiusAudienceConfirmationView(
                                viewModel: viewModel
                            ).environmentObject(app)
                        case .confirmSend:
                            ComposeRadiusConfirmSendView(viewModel: viewModel).environmentObject(app)
                        case .radiusSent:
                            ComposeRadiusConfirmationView(
                                emptyMessage: "Your Radius mailing is completed. " +
                                    "You will receive a notification when the mailing is sent in the next 1-2 days."
                            )
                        }
                    }
                    // MARK: - Button Footer
                    HStack(spacing: 20) {
                        if (viewModel.step != .confirmSend &&
                                viewModel.step != .radiusSent &&
                                viewModel.step != .audienceProcessing) || !viewModel.canAfford {
                            // MARK: - Back Button
                            Button(
                                action: {
                                    guard viewModel.step == .selectLocation ||
                                            viewModel.step == .audienceProcessing ||
                                            viewModel.step == .confirmAudience ||
                                            (isCurrentMailingListInProgress() && viewModel.step == .selectCard) ||
                                            !viewModel.canAfford
                                    else {
                                        viewModel.analyticsTracker.trackEvent(
                                            .mobileRadiusMailingWizardBack,
                                            context: app.persistentContainer.viewContext
                                        )
                                        viewModel.step.back()
                                        return
                                    }
                                    app.currentView = .dashboard(false, false)
                                }
                            ) {
                                Text(viewModel.step == .audienceProcessing ||
                                        viewModel.step == .confirmAudience ||
                                        (isCurrentMailingListInProgress() && viewModel.step == .selectCard) ||
                                        !viewModel.canAfford ?
                                        "Campaigns" :
                                        "Back")
                                    .font(Font.custom("Silka-Medium", size: 18))
                                    .frame(maxWidth: 140, maxHeight: 50)
                                    .foregroundColor(Color.addressableDarkGray)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.addressableDarkGray, lineWidth: 1)
                                    )
                            }
                        }
                        // MARK: - Next Button
                        Button(
                            action: {
                                guard viewModel.step != .audienceProcessing &&
                                        viewModel.step != .radiusSent else {
                                    viewModel.analyticsTracker.trackEvent(
                                        .mobileRadiusMailingWizardNextToDashboard,
                                        context: app.persistentContainer.viewContext
                                    )
                                    app.currentView = .dashboard(false, false)
                                    return
                                }

                                if viewModel.step == .selectLocation && viewModel.touchOneMailing == nil {
                                    viewModel.createRadiusMailing { newMailing in
                                        guard newMailing != nil else { return }

                                        viewModel.analyticsTracker.trackEvent(
                                            .mobileRadiusMailingCreated,
                                            context: app.persistentContainer.viewContext
                                        )
                                    }
                                } else if viewModel.step == .selectLocation && viewModel.touchOneMailing != nil {
                                    viewModel.updateRadiusMailingData(for: .location) { updatedMailing in
                                        guard updatedMailing != nil else { return }
                                        viewModel.analyticsTracker.trackEvent(
                                            .mobileRadiusMailingLocationUpdated,
                                            context: app.persistentContainer.viewContext
                                        )
                                    }
                                }

                                if viewModel.step == .selectCard {
                                    viewModel.updateRadiusMailingData(for: .cover) { updatedMailing in
                                        guard updatedMailing != nil else { return }
                                        viewModel.analyticsTracker.trackEvent(
                                            .mobileRadiusMailingCoverImageUpdated,
                                            context: app.persistentContainer.viewContext
                                        )
                                    }
                                }

                                if viewModel.step == .chooseTopic {
                                    viewModel.updateRadiusMailingData(for: .topic) { updatedMailing in
                                        guard updatedMailing != nil else { return }
                                        viewModel.analyticsTracker.trackEvent(
                                            .mobileRadiusMailingTopicUpdated,
                                            context: app.persistentContainer.viewContext
                                        )
                                        if let mailing = updatedMailing,
                                           let mailingStatus = mailing.listStatus {
                                            if mailingStatus == ListStatus.complete.rawValue {
                                                viewModel.step = ComposeRadiusSteps.confirmAudience
                                                return
                                            }
                                        }
                                    }
                                }

                                if viewModel.step == .confirmAudience {
                                    // Approve List + Create Touch 2 Mailing
                                    viewModel.updateRadiusMailingData(for: .list) { updatedMailing in
                                        guard updatedMailing != nil else { return }
                                        viewModel.analyticsTracker.trackEvent(
                                            .mobileRadiusMailingAudienceConfirmed,
                                            context: app.persistentContainer.viewContext
                                        )
                                    }
                                }

                                if viewModel.step == .confirmSend {
                                    viewModel.updateRadiusMailingData(for: .targetDate) { updatedMailing in
                                        guard updatedMailing != nil else { return }
                                    }
                                    viewModel.analyticsTracker.trackEvent(
                                        .mobileRadiusMailSent,
                                        context: app.persistentContainer.viewContext
                                    )
                                }
                                viewModel.analyticsTracker.trackEvent(
                                    .mobileRadiusMailingWizardNext,
                                    context: app.persistentContainer.viewContext
                                )
                                viewModel.step.next()
                            }
                        ) {
                            Text(getNextButtonText())
                                .font(Font.custom("Silka-Medium", size: 18))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: (viewModel.step == .confirmSend ||
                                                    viewModel.step == .radiusSent ||
                                                    viewModel.step == .audienceProcessing) &&
                                        viewModel.canAfford  ? 295 : 140, maxHeight: 50)
                                .foregroundColor(Color.white)
                                .background(Color.addressablePurple)
                                .cornerRadius(5)
                        }
                        .disabled(isNextButtonDisabled())
                        .opacity(isNextButtonDisabled() ? 0.4 : 1)
                    }
                }
                .padding(.vertical, 30)
                .background(Color.addressableLightGray)
                .border(width: 1, edges: [.top], color: Color.gray.opacity(0.2))
            }
            .onAppear {
                viewModel.getDataTreeDefaultSearchCriteria()
                if let currentStepIndex = ComposeRadiusSteps.allCases.firstIndex(of: viewModel.step),
                   let cardSelectionStepIndex = ComposeRadiusSteps.allCases.firstIndex(of: .selectCard) {
                    if currentStepIndex <= cardSelectionStepIndex || viewModel.step == .confirmAudience {
                        viewModel.getRadiusMailingCoverImageOptions()
                    }
                }
            }
            .onChange(of: viewModel.canAfford) { _ in
                if !viewModel.canAfford {
                    alertType = .paymentRequired
                    showingAlert = true
                }
            }
            .alert(isPresented: $showingAlert) {
                switch alertType {
                case .somethingWentWrong:
                    return Alert(title: Text("Sorry something went wrong," +
                                                " try again or reach out to an Addressable " +
                                                " representative if the problem persists."))
                case .paymentRequired:
                    return Alert(
                        title: Text("Low Token Balance")
                            .font(Font.custom("Silka-Bold", size: 14)),
                        message: Text("Please purchase more tokens to send this mailing.")
                            .font(Font.custom("Silka-Medium", size: 12)),
                        primaryButton: .default(Text("Buy More")) {
                            guard let keyStoreUser = KeyChainServiceUtil.shared[userData],
                                  let userData = keyStoreUser.data(using: .utf8),
                                  let user = try? JSONDecoder().decode(User.self, from: userData),
                                  let scheme = Bundle.main.object(forInfoDictionaryKey: "DOMAIN_SCHEME") as? String,
                                  let host = Bundle.main.object(forInfoDictionaryKey: "API_DOMAIN_NAME") as? String,
                                  let url = URL(string: "\(scheme)://\(host)/accounts/\(user.accountID)/token_orders")
                            else {
                                alertType = .somethingWentWrong
                                showingAlert = true
                                return
                            }
                            UIApplication.shared.open(url)
                        }, secondaryButton: .cancel())
                }
            }
        }.edgesIgnoringSafeArea([.bottom])
    }
    private func isScrollableView() -> Bool {
        return viewModel.step == .chooseTopic || viewModel.step == .confirmAudience || viewModel.step == .confirmSend
    }
    private func hasCompletedAllSteps(for mailing: Mailing) -> Bool {
        return mailing.layoutTemplate != nil && mailing.topicSelectionID != nil
    }

    private func getNextButtonText() -> String {
        switch viewModel.step {
        case .audienceProcessing:
            return "Finish"
        case .confirmSend:
            return " Confirm & Send "
        case .radiusSent:
            return "Complete"
        default:
            return "Next"
        }
    }

    private func isCurrentMailingListInProgress() -> Bool {
        switch self.viewModel.touchOneMailing?.listStatus {
        case ListStatus.searching.rawValue,
             ListStatus.exporting.rawValue,
             ListStatus.ingesting.rawValue:
            return true
        default:
            return false
        }
    }

    private func isNextButtonDisabled() -> Bool {
        switch viewModel.step {
        case .selectLocation:
            return viewModel.locationEntry.isEmpty
        case .selectCard:
            return viewModel.mailingCoverImages.isEmpty
        case .chooseTopic:
            return viewModel.topics.isEmpty || isMissingMergeVars()
        case .audienceProcessing:
            return false
        case.confirmAudience:
            return viewModel.numActiveRecipients < 1
        case .confirmSend:
            return viewModel.isEditingTargetDropDate || !viewModel.canAfford
        case .radiusSent:
            return false
        }
    }
    // swiftlint:disable force_unwrapping
    private func isMissingMergeVars() -> Bool {
        return (!Array(viewModel.touchOneTemplateMergeVariables.keys).filter {
            viewModel.touchOneTemplateMergeVariables[$0]!.isEmpty
        }.isEmpty ||
        !Array(viewModel.touchTwoTemplateMergeVariables.keys).filter {
            viewModel.touchTwoTemplateMergeVariables[$0]!.isEmpty
        }.isEmpty)
    }

    private func generateCompletedStepCircleIndicator(for index: Int?) -> some View {
        if let currentStepIndex = index {
            var count = currentStepIndex + 1
            // swiftlint:disable empty_count
            while count > 0 {
                count -= 1
                return Circle().fill(Color.addressablePurple).frame(width: 9, height: 9)
            }
        }
        return Circle().fill(Color.addressableLighterGray).frame(width: 9, height: 9)
    }
}
// MARK: - EmptyListView
struct EmptyListView: View {
    var message: String

    var body: some View {
        Text(message)
            .font(Font.custom("Silka-Regular", size: 16))
            .padding(25)
            .multilineTextAlignment(.center)
    }
}

#if DEBUG
struct ComposeRadiusView_Previews: PreviewProvider {
    static var previews: some View {
        ComposeRadiusView(
            viewModel: ComposeRadiusViewModel(provider: DependencyProvider(),
                                              selectedMailing: nil)
        )
    }
}
#endif
