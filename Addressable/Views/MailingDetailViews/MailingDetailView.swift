//
//  MailingDetailView.swift
//  Addressable
//
//  Created by Ari on 6/7/21.
//

import SwiftUI

enum SettingsMenu: String, CaseIterable {
    case sendMailing = "Send Mailing"
    case addTokens = "Purchase Tokens"
    case revert = "Revert to Draft"
    case sendAgain = "Send Again"
    case clone = "Clone"
    case cancelMailing = "Cancel Mailing"
}

enum MailingDetailAlertTypes {
    case confirmCancelMailing, mailingError
}

enum MailingDetailSheetTypes: Identifiable {
    case confirmAndSendMailing, cloneMailing, addMessageTemplate, addAudience, mailingRecipientsList

    var id: Int {
        hashValue
    }
}

// swiftlint:disable type_body_length file_length
struct MailingDetailView: View, Equatable {
    static func == (lhs: MailingDetailView, rhs: MailingDetailView) -> Bool {
        lhs.viewModel.mailing == rhs.viewModel.mailing
    }

    @EnvironmentObject var app: Application
    @ObservedObject var viewModel: MailingDetailViewModel

    @State var isEditingMailing: Bool = false
    @State var selectedMailingImageIndex: Int = 0
    @State var selectedCoverImageIndex: Int = 0
    @State var isShowingAlert: Bool = false
    @State var alertType: MailingDetailAlertTypes = .confirmCancelMailing
    @State var activeSheetType: MailingDetailSheetTypes?
    @State var isShowingMessageAlert: Bool = false

    init(viewModel: MailingDetailViewModel) {
        self.viewModel = viewModel

        UINavigationBar.appearance().backgroundColor = UIColor(
            red: 240 / 255,
            green: 240 / 255,
            blue: 240 / 255,
            alpha: 1.0
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Mailing Name Header
            HStack {
                if let mailingName = viewModel.mailing.subjectListEntry?.siteAddressLine1 {
                    Text(mailingName)
                        .font(Font.custom("Silka-Medium", size: 14))
                        .foregroundColor(Color.addressablePurple)
                        .padding(.vertical)
                } else {
                    Text(viewModel.mailing.name)
                        .font(Font.custom("Silka-Medium", size: 14))
                        .foregroundColor(Color.addressablePurple)
                        .padding(.vertical)
                }
                viewModel.mailing.type == MailingType.radius.rawValue ?
                    Text("Touch \(isTouchTwoMailing() ? "2" : "1")")
                    .font(Font.custom("Silka-Regular", size: 12))
                    .foregroundColor(Color.addressableFadedBlack)
                    .padding(.vertical) : nil
                Spacer()
                Text(getMailingStatus().rawValue)
                    .font(Font.custom("Silka-Medium", size: 12))
                    .foregroundColor(Color.black)
                    .padding(.vertical)
            }
            .padding(.horizontal, 20)
            .border(width: 1, edges: [.bottom], color: Color.gray.opacity(0.2))
            .background(Color.white)
            HStack {
                // MARK: - Mailing Date and Size Header
                Text("Mailing on: \(getFormattedTargetDropDate())")
                    .font(Font.custom("Silka-Medium", size: 14))
                    .foregroundColor(Color.black.opacity(0.8))
                    .padding(.vertical)
                Spacer()
                Text("size: \(viewModel.mailing.targetQuantity)")
                    .font(Font.custom("Silka-Medium", size: 12))
                    .foregroundColor(Color.black.opacity(0.8))
                    .padding(.vertical)
                Spacer()
                // MARK: - Mailing Settings Menu
                let mailingProcessing = getMailingStatus() == .processing &&
                    viewModel.mailing.mailingStatus != MailingState.productionReady.rawValue
                Menu {
                    ForEach(SettingsMenu.allCases, id: \.self) { menuOption in
                        if shouldDisplay(menuOption) {
                            Button {
                                triggerAction(for: menuOption)
                            } label: {
                                Text(menuOption.rawValue).font(Font.custom("Silka-Medium", size: 14))
                            }
                        }
                    }
                } label: {
                    if mailingProcessing {
                        Text("Mailing Processing...")
                            .font(Font.custom("Silka-Medium", size: 14))
                    } else if getMailingStatus() != .archived {
                        Image(systemName: "ellipsis")
                            .imageScale(.medium)
                            .foregroundColor(Color.black.opacity(0.5))
                    }
                }
                .disabled(mailingProcessing)
                .opacity(mailingProcessing ? 0.6 : 1)
            }
            .padding(.horizontal, 20)
            .border(width: 1, edges: [.bottom], color: Color.gray.opacity(0.2))
            .background(Color.white)
            // MARK: - Mailing Details Main Menu
            VStack(spacing: 12) {
                let isEditingReturnAddress = isEditingMailing &&
                    MailingImages.allCases[selectedMailingImageIndex] == .envelopeOutside
                let isEditingFrontCardCover = isEditingMailing &&
                    MailingImages.allCases[selectedMailingImageIndex] == .cardFront
                let isEditingBackCardCover = isEditingMailing &&
                    MailingImages.allCases[selectedMailingImageIndex] == .cardBack
                // MARK: - MailingCoverImagePagerView
                isEditingReturnAddress ? nil :
                    MailingCoverImagePagerView(
                        viewModel: MailingCoverImagePagerViewModel(
                            provider: app.dependencyProvider,
                            selectedMailing: $viewModel.mailing,
                            selectedFrontImageData: $viewModel.selectedFrontImageData,
                            selectedBackImageData: $viewModel.selectedBackImageData,
                            selecteImageId: viewModel.selectedImageId
                        ),
                        isEditingMailing: $isEditingMailing,
                        selectedMailingImageIndex: $selectedMailingImageIndex,
                        isEditingMailingCoverImage: isEditingFrontCardCover || isEditingBackCardCover,
                        selectedCoverImageIndex: $selectedCoverImageIndex,
                        activeSheetType: $activeSheetType
                    )
                    .equatable()
                    .environmentObject(app)
                // MARK: - EditReturnAddressView
                isEditingReturnAddress ?
                    EditReturnAddressView(
                        viewModel: EditReturnAddressViewModel(
                            provider: app.dependencyProvider,
                            selectedMailing: $viewModel.mailing
                        ),
                        isEditingReturnAddress: $isEditingMailing,
                        toggleAlert: toggleMessageToastView
                    ) {
                        viewModel.analyticsTracker.trackEvent(
                            .mobileMailingDetailReturnAddressUpdated,
                            context: app.persistentContainer.viewContext
                        )
                    }
                    .padding(20)
                    .transition(.move(edge: .top)) : nil
                // MARK: - Display Mailing Recipients Button
                isEditingBackCardCover ||
                    isEditingFrontCardCover ||
                    isEditingReturnAddress ? nil :
                    Button(action: {
                        activeSheetType = .mailingRecipientsList
                    }) {
                        Text("Edit Mailing Recipients")
                            .font(Font.custom("Silka-Medium", size: 18))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 295, maxHeight: 50)
                            .foregroundColor(Color.white)
                            .background(Color.addressablePurple)
                            .cornerRadius(5)
                    }
                // MARK: - MailingCoverImageGalleryView
                isEditingFrontCardCover || isEditingBackCardCover ?
                    MailingCoverImageGalleryView(
                        viewModel: MailingCoverImageGalleryViewModel(
                            provider: app.dependencyProvider,
                            selectedMailing: $viewModel.mailing,
                            selectedFrontImageData: $viewModel.selectedFrontImageData,
                            selectedBackImageData: $viewModel.selectedBackImageData,
                            selectedImageId: $viewModel.selectedImageId
                        ),
                        isEditingMailing: $isEditingMailing,
                        isEditingBackCardCover: isEditingBackCardCover || selectedCoverImageIndex > 0
                    )
                    .equatable()
                    .environmentObject(app)
                    .padding(20)
                    .transition(.move(edge: .bottom)) : nil
                Spacer()
            }
        }
        .popup(isPresented: isShowingMessageAlert, alignment: .center, content: MessageAlert.init)
        .sheet(item: $activeSheetType) { item in
            switch item {
            case .confirmAndSendMailing:
                ConfirmAndSendMailingView(
                    viewModel: ConfirmAndSendMailingViewModel(
                        provider: app.dependencyProvider,
                        selectedMailing: $viewModel.mailing
                    ),
                    isMailingReady: viewModel.numActiveRecipients > 0 &&
                        viewModel.mailing.layoutTemplate != nil &&
                        (viewModel.mailing.customNoteTemplateID != nil &&
                            viewModel.mailing.customNoteBody != nil)
                ).environmentObject(app)
            case .cloneMailing:
                CloneMailingView(
                    viewModel: CloneMailingViewModel(
                        provider: app.dependencyProvider,
                        selectedMailing: $viewModel.mailing
                    )
                ).environmentObject(app)
            case .addMessageTemplate:
                MessageTemplateSelectionView(
                    viewModel: MessageTemplateSelectionViewModel(
                        provider: app.dependencyProvider,
                        selectedMailing: $viewModel.mailing
                    ),
                    toggleAlert: toggleMessageToastView
                )
                .equatable()
                .environmentObject(app)
            case .addAudience:
                SelectAudienceView(
                    viewModel: SelectAudienceViewModel(
                        provider: app.dependencyProvider,
                        selectedMailing: $viewModel.mailing)
                ).environmentObject(app)
            case .mailingRecipientsList:
                NavigationView {
                    MailingRecipientsListView(
                        viewModel: MailingRecipientsListViewModel(
                            provider: app.dependencyProvider,
                            selectedMailing: $viewModel.mailing,
                            numActiveRecipients: $viewModel.numActiveRecipients
                        ),
                        activeSheetType: $activeSheetType
                    )
                    .equatable()
                    .environmentObject(app)
                    .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20))
                    .navigationBarTitle("Edit Mailing Recipients", displayMode: .inline)
                    .navigationBarItems(trailing: Button(action: { activeSheetType = nil }) {
                        Text("Done")
                    })
                    .background(Color.addressableLightGray)
                    .border(width: 1, edges: [.top], color: Color.gray.opacity(0.2))
                    .ignoresSafeArea(.all, edges: [.bottom])
                }
            }
        }
        .alert(isPresented: $isShowingAlert) {
            switch alertType {
            case .confirmCancelMailing:
                return Alert(
                    title: Text("Cancel '\(viewModel.mailing.name) \(getTouchNumber())'?")
                        .font(Font.custom("Silka-Bold", size: 14)),
                    message: Text("Do you want to cancel and remove this mailing from the production queue?")
                        .font(Font.custom("Silka-Medium", size: 12)),
                    primaryButton: .default(Text("Yes, Refund Tokens")) {
                        viewModel.cancelMailing { updatedMailing in
                            if let refundedMailing = updatedMailing {
                                viewModel.analyticsTracker.trackEvent(
                                    .mobileTokensRefunded,
                                    context: app.persistentContainer.viewContext
                                )
                                viewModel.mailing = refundedMailing
                                isShowingAlert = false
                            } else {
                                alertType = .mailingError
                                isShowingAlert = true
                            }
                        }
                    }, secondaryButton: .cancel())
            case .mailingError:
                return Alert(title: Text("Sorry something went wrong, " +
                                            "try again or reach out to an Addressable " +
                                            "representative if the problem persists."))
            }
        }
        .background(Color.addressableLightGray)
    }
    private func toggleMessageToastView() {
        isShowingMessageAlert = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            withAnimation(.easeOut(duration: 0.5)) {
                isShowingMessageAlert = false
            }
        }
    }
    private func shouldDisplay(_ option: SettingsMenu) -> Bool {
        for state in MailingState.allCases where state.rawValue == viewModel.mailing.mailingStatus {
            switch option {
            case .sendMailing:
                return state == .draft || state == .listReady || state == .listAdded || state == .listApproved
            case .addTokens:
                return state == .pending
            case .revert:
                return state == .productionReady
            case .sendAgain:
                return state == .mailed
            case .clone:
                return state == .canceled
            case .cancelMailing:
                return state == .scheduled
            }
        }
        return false
    }
    private func triggerAction(for menuOption: SettingsMenu) {
        switch menuOption {
        case .sendMailing:
            activeSheetType = .confirmAndSendMailing
            viewModel.analyticsTracker.trackEvent(
                .mobileSendMailingFromDetailsView,
                context: app.persistentContainer.viewContext
            )
        case .revert,
             .cancelMailing:
            isShowingAlert = true
            viewModel.analyticsTracker.trackEvent(
                .mobileCancelRevertMailingFromDetailsView,
                context: app.persistentContainer.viewContext
            )
        case .addTokens:
            guard let keyStoreUser = KeyChainServiceUtil.shared[userData],
                  let userData = keyStoreUser.data(using: .utf8),
                  let user = try? JSONDecoder().decode(User.self, from: userData),
                  let scheme = Bundle.main.object(forInfoDictionaryKey: "DOMAIN_SCHEME") as? String,
                  let host = Bundle.main.object(forInfoDictionaryKey: "API_DOMAIN_NAME") as? String,
                  let url = URL(string: "\(scheme)://\(host)/accounts/\(user.accountID)/token_orders")
            else {
                alertType = .mailingError
                isShowingAlert = true
                return
            }
            UIApplication.shared.open(url)
            viewModel.analyticsTracker.trackEvent(
                .mobileAddTokensFromDetailsView,
                context: app.persistentContainer.viewContext
            )
        case .clone,
             .sendAgain:
            activeSheetType = .cloneMailing
            viewModel.analyticsTracker.trackEvent(
                .mobileCloneMailingFromDetailsView,
                context: app.persistentContainer.viewContext
            )
        }
    }
    private func getMailingStatus() -> MailingStatus {
        switch viewModel.mailing.mailingStatus {
        case MailingState.mailed.rawValue,
             MailingState.remailed.rawValue:
            return MailingStatus.mailed
        case MailingState.production.rawValue,
             MailingState.printReady.rawValue,
             MailingState.printing.rawValue,
             MailingState.writeReady.rawValue,
             MailingState.writing.rawValue,
             MailingState.mailReady.rawValue,
             MailingState.productionReady.rawValue:
            return MailingStatus.processing
        case MailingState.scheduled.rawValue:
            return MailingStatus.upcoming
        case MailingState.listReady.rawValue,
             MailingState.listAdded.rawValue,
             MailingState.listApproved.rawValue,
             MailingState.draft.rawValue:
            return MailingStatus.draft
        case MailingState.delivered.rawValue,
             MailingState.archived.rawValue:
            return MailingStatus.archived
        default:
            return MailingStatus.canceled
        }
    }
    private func getFormattedTargetDropDate() -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd"

        return dateFormatterPrint.string(from: getTargetDropDateObject())
    }
    private func getTargetDropDateObject() -> Date {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatterGet.date(from: viewModel.mailing.targetDropDate ?? "") {
            return date
        } else {
            return Date()
        }
    }
    private func isTouchTwoMailing() -> Bool {
        if let relatedTouchMailing = viewModel.mailing.relatedMailing {
            return relatedTouchMailing.parentMailingID == nil
        } else {
            return false
        }
    }
    private func getTouchNumber() -> String {
        return viewModel.mailing.type == MailingType.radius.rawValue ? "| Touch \(isTouchTwoMailing() ? "2" : "1")" : ""
    }
}
