//
//  AnalyticsTracker.swift
//  Addressable
//
//  Created by Ari on 8/18/21.
//

import Foundation
import CoreData

// swiftlint:disable line_length
enum AnalyticsEventName: String {
    case mobileLoginSuccess = "mobile_login_success"
    case mobileLoginFailed = "mobile_login_failed"
    case mobileLogoutSuccess = "mobile_logout_success"
    case mobileAppBackgrounded = "mobile_app_backgrounded"
    case mobileAppOpened = "mobile_app_opened"
    case mobileAppInstalled = "mobile_app_installed"
    case mobileAppUpdated = "mobile_app_updated"
    case pushNotificationPressedList = "mobile_app_push_notification_pressed_mailing_list_status"
    case pushNotificationPressedCall = "mobile_app_push_notification_pressed_incoming_lead_call"
    case pushNotificationPressedMessage = "mobile_app_push_notification_pressed_incoming_lead_sms_message"
    case pushNotificationRecievedList = "mobile_app_push_notification_recieved_mailing_list_status"
    case pushNotificationRecievedCall = "mobile_app_push_notification_recieved_incoming_lead_call"
    case pushNotificationRecievedMessage = "mobile_app_push_notification_recieved_incoming_lead_sms_message"
    case pushNotificationRecieved = "mobile_app_push_notification_recieved"
    case mobileAppCrashed = "mobile_app_crashed"
    case mobileRadiusMailSent = "mobile_app_radius_mailing_sent"
    case mobileLeadTagged = "mobile_app_tagged_lead"
    case mobileUserNoteSaved = "mobile_app_user_note_saved"
    case mobileLeadTaggedSpam = "mobile_app_tagged_lead_as_spam"
    case mobileLeadTaggedPerson = "mobile_app_tagged_lead_as_person"
    case mobileLeadTaggedLowInterest = "mobile_app_tagged_lead_as_low_interest"
    case mobileLeadTaggedFair = "mobile_app_tagged_lead_as_fair"
    case mobileLeadTaggedLead = "mobile_app_tagged_lead_as_lead"
    case mobileLeadTaggedRemoval = "mobile_app_tagged_lead_as_removal"
    case mobileLeadTaggedNotRemoval = "mobile_app_tagged_lead_as_not_removal"
    case mobileNavigationMenuSelected = "mobile_app_navigation_menu_selected"
    case mobileNavigationCampaignsMenuSelected = "mobile_app_navigation_campaigns_menu_selected"
    case mobileNavigationCallsMenuSelected = "mobile_app_navigation_calls_menu_selected"
    case mobileNavigationMessagesMenuSelected = "mobile_app_navigation_messages_menu_selected"
    case mobileNavigationProfileMenuSelected = "mobile_app_navigation_profile_menu_selected"
    case mobileNavigationMailingDetailSelected = "mobile_app_navigation_to_mailing_detail_view"
    case mobileNavigationFeedbackMenuSelected = "mobile_app_navigation_feedback_menu_selected"
    case mobileNavigationAddressableHeaderTap = "mobile_app_navigation_header_selected"
    case mobileReturnToCallBannerTapped = "mobile_app_return_to_call_banner_tapped"
    case mobileUntaggedLeadsBannerTapped = "mobile_app_untagged_leads_banner_tapped"
    case mobileAddPlusButtonTapped = "mobile_app_add_plus_button_tapped"
    case mobileAddRadiusMailingTapped = "mobile_app_add_radius_mailing_tapped"
    case mobileAddSphereMailingTapped = "mobile_app_add_sphere_mailing_tapped"
    case mobileAddAudienceMailingTapped = "mobile_app_add_audience_mailing_tapped"
    case mobileAddSingleMailingTapped = "mobile_app_add_single_mailing_tapped"
    case mobileFilterMenuTapped = "mobile_app_filter_menu_tapped"
    case mobileMailingSelectedComposeRadius = "mobile_app_mailing_selected_compose_radius"
    case mobileCallSectionHeaderTapped = "mobile_app_call_section_header_tapped"
    case mobileCallInboxSectionHeaderTapped = "mobile_app_call_list_inbox_section_header_tapped"
    case mobileCallRemovalSectionHeaderTapped = "mobile_app_call_list_removals_section_header_tapped"
    case mobileCallSpamSectionHeaderTapped = "mobile_app_call_list_spam_section_header_tapped"
    case mobileTagLeadMenuDisplayed = "mobile_app_tag_lead_menu_displayed"
    case mobileLeadCallHistoryMenuDisplayed = "mobile_app_lead_call_history_displayed"
    case mobileLeadOutgoingCallInitiated = "mobile_app_lead_outgoing_call_initiated"
    case mobileLeadReverseRemovalOrSpamTag = "mobile_app_lead_reverse_removal_or_spam_tag"
    case mobileLeadMessageThreadTapped = "mobile_app_lead_message_thread_tapped"
    case mobileLeadMessageSent = "mobile_app_sms_message_sent_to_lead"
    case mobileHandwritingStylesDisplayed = "mobile_app_handwriting_styles_displayed"
    case mobileTokenPurchaseBtnPressed = "mobile_app_token_purchase_button_pressed"
    case mobileTeamMemberInviteBtnPressed = "mobile_app_team_member_invite_button_pressed"
    case mobileAddressUpdatePressed = "mobile_app_edit_return_address_button_pressed"
    case mobileLearnMoreAPIPressed = "mobile_app_api_learn_more_pressed"
    case mobileSendMailingFromDetailsView = "mobile_app_send_mailing_settings_menu_pressed"
    case mobileCancelRevertMailingFromDetailsView = "mobile_app_cancel_or_revert_mailing_settings_menu_pressed"
    case mobileAddTokensFromDetailsView = "mobile_app_add_token_mailing_detail_settings_menu_pressed"
    case mobileCloneMailingFromDetailsView = "mobile_app_clone_mailing_settings_menu_pressed"
    case mobileOuterEnvelopeViewDisplayed = "mobile_app_mailing_detail_outer_envelope_view_displayed"
    case mobileFrontCardViewDisplayed = "mobile_app_mailing_detail_front_card_view_displayed"
    case mobileInsideCardViewDisplayed = "mobile_app_mailing_detail_inside_card_view_displayed"
    case mobileBackCardViewDisplayed = "mobile_app_mailing_detail_back_card_view_displayed"
    case mobileMailingDetailReturnAddressUpdated = "mobile_app_mailing_detail_return_address_updated"
    case mobileEditMessageTemplateFromDetailsView = "mobile_app_mailing_detail_message_template_edited"
    case mobileChangeMessageTemplateDetailsView = "mobile_app_mailing_detail_message_template_id_dropdown_selection_update"
    case mobileUpdatedCardImage = "mobile_app_mailing_detail_updated_card_image"
    case mobileTokensRefunded = "mobile_app_mailing_detail_tokens_refunded"
    case mobileUpdateDateReleaseMailingDetail = "mobile_app_mailing_detail_release_target_date_edited"
    case mobileMailingReleasedDetailView = "mobile_app_mailing_released_detail_view"
    case mobileMailingDetailViewReleaseCancelled = "mobile_app_mailing_detail_view_release_cancel_pressed"
    case mobileUpdateDateCloneMailingDetail = "mobile_app_mailing_detail_clone_target_date_edited"
    case mobileUpdateNameCloneMailingDetail = "mobile_app_mailing_detail_clone_name_edited"
    case mobileUpdateQuantityCloneMailingDetail = "mobile_app_mailing_detail_clone_quantity_edited"
    case mobileCloneMailingRemoveLayoutTemplate = "mobile_app_mailing_detail_clone_unchecked_layout_template_pressed"
    case mobileCloneMailingRemoveMessageTemplate = "mobile_app_mailing_detail_clone_unchecked_message_template_pressed"
    case mobileCloneMailingRemoveAudienceList = "mobile_app_mailing_detail_clone_unchecked_audience_list_pressed"
    case mobileMailingDetailViewCloneCancelled = "mobile_app_mailing_detail_view_clone_cancel_pressed"
    case mobileMailingDetailViewCloneSuccess = "mobile_app_mailing_cloned_success"
    case mobileChangeMessageTemplateCancelled = "mobile_app_mailing_detail_message_template_update_cancel_pressed"
    case mobileChangeMessageTemplateSuccess = "mobile_app_mailing_detail_message_template_id_update_success"
    case mobileAddAudienceSelection = "mobile_app_mailing_detail_audience_selection_pressed"
    case mobileAddAudienceSelectionSuccess = "mobile_app_mailing_detail_audience_added_success"
    case mobileMailingRecipientTabTapped = "mobile_app_mailing_detail_recipients_tab_pressed"
    case mobileMailingRecipientMailingListTapped = "mobile_app_mailing_detail_recipients_mailing_list_tab_pressed"
    case mobileMailingRecipientRemovedTabTapped = "mobile_app_mailing_detail_recipients_removed_tab_pressed"
    case mobileMailingRecipientUnavaliableTapped = "mobile_app_mailing_detail_recipients_unavaliable_tab_pressed"
    case mobileMailingRecipientAllTabTapped = "mobile_app_mailing_detail_recipients_all_tab_pressed"
    case mobileMailingRecipientRemoved = "mobile_app_mailing_detail_recipient_removed"
    case mobileMailingRecipientAdded = "mobile_app_mailing_detail_recipient_added"
    case mobileFeedbackSent = "mobile_app_feedback_sent"
    case mobileCallMuted = "mobile_app_active_call_muted"
    case mobileCallSpeakerEnabled = "mobile_app_active_call_speaker_enabled"
    case mobileCallHoldEnabled = "mobile_app_active_call_hold_enabled"
    case mobileCallParticipantAddMenuDisplayed = "mobile_app_active_call_add_participant_menu_displayed"
    case mobileCallReturnToCampaigns = "mobile_app_active_call_return_to_campaigns_pressed"
    case mobileCallEnded = "mobile_app_active_call_ended"
    case mobileSaleLocationSelected = "mobile_app_radius_mailing_sale_location_selected"
    case mobileTargetCriteriaMenuDisplayed = "mobile_app_radius_mailing_target_criteria_menu_displayed"
    case mobileTargetCriteriaMenuChangesApplied = "mobile_app_radius_mailing_target_criteria_menu_changes_applied"
    case mobileTargetCriteriaMenuChangesCancelled = "mobile_app_radius_mailing_target_criteria_menu_changes_cancelled"
    case mobileRadiusMailingWizardBack = "mobile_app_radius_mailing_back_btn_pressed"
    case mobileRadiusMailingWizardNextToDashboard = "mobile_app_radius_mailing_next_btn_pressed_sent_to_dashboard_view"
    case mobileRadiusMailingCreated = "mobile_app_radius_mailing_created"
    case mobileRadiusMailingLocationUpdated = "mobile_app_radius_mailing_location_updated"
    case mobileRadiusMailingCoverImageUpdated = "mobile_app_radius_mailing_cover_image_updated"
    case mobileRadiusMailingTopicUpdated = "mobile_app_radius_mailing_topic_updated"
    case mobileRadiusMailingAudienceConfirmed = "mobile_app_radius_mailing_audience_confirmed"
    case mobileRadiusMailingWizardNext = "mobile_app_radius_mailing_next_btn_pressed"
    case mobileRadiusMailingTopicSelection = "mobile_app_radius_mailing_topic_selection_pressed"
    case mobileRadiusMailingEditMessageTemplate = "mobile_app_radius_mailing_message_template_edited"
    case mobileRadiusMailingShowPreview = "mobile_app_radius_mailing_message_template_show_preview_pressed"
    case mobileUpdateDateRadiusMailing = "mobile_app_radius_mailing_touch_one_target_date_updated"
    case mobileNavigationHamburgerMenuTapped = "mobile_app_navigation_hamburger_menu_tapped"
    case mobilePlayVoiceMailTapped = "mobile_app_play_voicemail_pressed"
    case mobileIsPrimaryToggledOn = "mobile_app_is_primary_user_toggled_on"
    case mobileIsPrimaryToggledOff = "mobile_app_is_primary_user_toggled_off"
    case mobileProfileViewUnauthorizedLogout = "mobile_app_unauthorized_user_logged_out_profile_view"
    case mobileDashboardViewUnauthorizedLogout = "mobile_app_unauthorized_user_logged_out_dashboard_view"
    case mobileDashboardViewTapOnNumOfCampaign = "mobile_app_dashboard_view_tap_on_num_of_campaigns"
    case mobileDashboardViewTapOnNumOfCards = "mobile_app_dashboard_view_tap_on_num_of_cards"
    case mobileDashboardViewTapOnNumOfCalls = "mobile_app_dashboard_view_tap_on_num_of_calls"
    case mobileDashboardViewTapOnNumOfSms = "mobile_app_dashboard_view_tap_on_num_of_sms"
}

class AnalyticsTracker {
    init(provider: DependencyProviding) {}

    func trackEvent(_ eventName: AnalyticsEventName, context: NSManagedObjectContext) {
        AnalyticEvent.createWith(eventType: eventName.rawValue, using: context)
    }
}
