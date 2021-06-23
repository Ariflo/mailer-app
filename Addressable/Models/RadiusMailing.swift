//
//  RadiusMailing.swift
//  Addressable
//
//  Created by Ari on 5/20/21.
//

// MARK: - RadiusMailing
struct RadiusMailing: Codable, Identifiable, Equatable {
    static func == (lhs: RadiusMailing, rhs: RadiusMailing) -> Bool {
        lhs.id == rhs.id
    }

    let id: Int
    let account: Account
    let user: User
    let fromAddress: ReturnAddress
    let name, mailingStatus: String
    let listCount: Int
    let targetQuantity, activeRecipientCount: Int
    let layoutTemplate: LayoutTemplate?
    let radiusTemplateID: Int?
    let customNoteTemplateID: Int?
    let relatedMailing: Mailing?
    let subjectListEntry: SubjectListEntry
    let topicDuration: Int?
    let topicSelectionID: Int?
    let listStatus: String?
    let targetDropDate: String?
    let envelopeOutsidePreviewUrl: String?
    let previewCardFrontUrl: String?
    let cardInsidePreviewUrl: String?
    let previewCardBackUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, account, user
        case fromAddress = "from_address"
        case name
        case mailingStatus = "mailing_status"
        case listCount = "list_count"
        case targetQuantity = "target_quantity"
        case activeRecipientCount = "active_recipient_count"
        case layoutTemplate = "layout_template"
        case radiusTemplateID = "radius_template_id"
        case customNoteTemplateID = "custom_note_template_id"
        case relatedMailing = "corresponding_mailing"
        case subjectListEntry = "subject_list_entry"
        case topicDuration = "topic_duration"
        case topicSelectionID = "selected_multi_touch_topic_id"
        case listStatus = "list_status"
        case targetDropDate = "target_drop_date"
        case envelopeOutsidePreviewUrl = "envelope_outside_preview_url"
        case previewCardFrontUrl = "preview_card_front_url"
        case cardInsidePreviewUrl = "card_inside_preview_url"
        case previewCardBackUrl = "preview_card_back_url"
    }
}

// MARK: - ReturnAddress
struct ReturnAddress: Codable {
    let fromFirstName, fromLastName, fromBusinessName, fromAddressLine1: String
    let fromAddressLine2, fromCity, fromState, fromZipcode: String

    enum CodingKeys: String, CodingKey {
        case fromFirstName = "from_first_name"
        case fromLastName = "from_last_name"
        case fromBusinessName = "from_business_name"
        case fromAddressLine1 = "from_address_line_1"
        case fromAddressLine2 = "from_address_line_2"
        case fromCity = "from_city"
        case fromState = "from_state"
        case fromZipcode = "from_zipcode"
    }
}
// MARK: - Account
struct Account: Codable {
    let id: Int

    enum CodingKeys: String, CodingKey {
        case id
    }
}

// MARK: - User
struct User: Codable {
    let id: Int
    let authenticationToken: String

    enum CodingKeys: String, CodingKey {
        case id
        case authenticationToken = "authentication_token"
    }
}

// MARK: - LayoutTemplate
struct LayoutTemplate: Codable {
    let id: Int

    enum CodingKeys: String, CodingKey {
        case id
    }
}

// MARK: - SubjectListEntry
struct SubjectListEntry: Codable, Identifiable {
    let id: Int
    let firstName: String?
    let lastName: String?
    let mailingAddressLine1, mailingAddressLine2: String?
    let mailingCity: String?
    let mailingState: String?
    let mailingZipcode: String?
    let siteAddressLine1: String
    let siteAddressLine2: String?
    let siteCity: String
    let siteState: String
    let siteZipcode: String
    let status: String?

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case mailingAddressLine1 = "mailing_address_line_1"
        case mailingAddressLine2 = "mailing_address_line_2"
        case mailingCity = "mailing_city"
        case mailingState = "mailing_state"
        case mailingZipcode = "mailing_zipcode"
        case siteAddressLine1 = "site_address_line_1"
        case siteAddressLine2 = "site_address_line_2"
        case siteCity = "site_city"
        case siteState = "site_state"
        case siteZipcode = "site_zipcode"
        case status
    }
}
// MARK: - RadiusMailingResponse
struct RadiusMailingResponse: Codable {
    let radiusMailing: RadiusMailing

    enum CodingKeys: String, CodingKey {
        case radiusMailing = "radius_mailing"
    }
}
// MARK: - OutgoingRadiusMailingFromAddress
struct OutgoingRadiusMailingFromAddress: Codable {
    let radiusMailing: ReturnAddress

    enum CodingKeys: String, CodingKey {
        case radiusMailing = "radius_mailing"
    }
}
// MARK: - OutgoingRadiusMailingSiteWrapper
struct OutgoingRadiusMailingSiteWrapper: Codable {
    let subjectListEntry: OutgoingSubjectListEntry
    let dataTreeSearch: DataTreeSearchCriteria

    enum CodingKeys: String, CodingKey {
        case subjectListEntry = "subject_list_entry"
        case dataTreeSearch = "data_tree_search"
    }
}

// MARK: - OutgoingSubjectListEntry
struct OutgoingSubjectListEntry: Codable {
    let siteAddressLine1, siteAddressLine2, siteCity, siteState: String
    let siteZipcode, latitude, longitude, status: String

    enum CodingKeys: String, CodingKey {
        case siteAddressLine1 = "site_address_line_1"
        case siteAddressLine2 = "site_address_line_2"
        case siteCity = "site_city"
        case siteState = "site_state"
        case siteZipcode = "site_zipcode"
        case latitude, longitude, status
    }
}

// MARK: - OutgoingRadiusMailingCoverArtWrapper
struct OutgoingRadiusMailingCoverArtWrapper: Codable {
    let cover: OutgoingRadiusMailingCoverArtData

    enum CodingKeys: String, CodingKey {
        case cover
    }
}

// MARK: - OutgoingRadiusMailingCoverArtData
struct OutgoingRadiusMailingCoverArtData: Codable {
    let layoutTemplateID: Int

    enum CodingKeys: String, CodingKey {
        case layoutTemplateID = "layout_template_id"
    }
}

// MARK: - OutgoingRadiusMailingCoverArtWrapper
struct OutgoingRadiusMailingTopicWrapper: Codable {
    let topic: OutgoingRadiusMailingTopicData
    let topicTemplate: OutgoingRadiusMailingTopicTemplateData
    let mergeVars: [String: String]

    enum CodingKeys: String, CodingKey {
        case topic
        case topicTemplate = "topic_template"
        case mergeVars = "merge_vars"
    }
}
// MARK: - OutgoingRadiusMailingTopicData
struct OutgoingRadiusMailingTopicData: Codable {
    let multiTouchTopicID: Int

    enum CodingKeys: String, CodingKey {
        case multiTouchTopicID = "multi_touch_topic_id"
    }
}
// MARK: - OutgoingRadiusMailingTopicTemplateData
struct OutgoingRadiusMailingTopicTemplateData: Codable {
    let shouldEditTouchOneTemplate: Bool?
    let templateOneBody: String
    let templateTwoBody: String

    enum CodingKeys: String, CodingKey {
        case shouldEditTouchOneTemplate = "update_template_one"
        case templateOneBody = "template_one_body"
        case templateTwoBody = "template_two_body"
    }
}
// MARK: - OutgoingRadiusMailingTargetDropDate
struct OutgoingRadiusMailingTargetDropDate: Codable {
    let radiusMailing: TargetDropDate

    enum CodingKeys: String, CodingKey {
        case radiusMailing = "radius_mailing"
    }
}
// MARK: - TargetDropDate
struct TargetDropDate: Codable {
    let tagetDropDate: String?

    enum CodingKeys: String, CodingKey {
        case tagetDropDate = "target_drop_date"
    }
}