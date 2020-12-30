//
//  SignInViewModel.swift
//  Addressable
//
//  Created by Ari on 12/29/20.
//

import SwiftUI

struct MailingsListViewModel {
    func getMailings() {
        guard let url = URL(string: "\(getBaseUrl())/mailings.json") else {
            return
        }

        var request = URLRequest(url: url)

        if let authToken = KeyChainServiceUtil.shared[USER_BASIC_AUTH_TOKEN] {
            print(authToken)
            request.setValue("Basic \(authToken)", forHTTPHeaderField: "Authorization")
        } else {
            return
        }


        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                print("THIS IS THE ERROR ->", error!)
                return
            }
            // Verify data is not nil
            guard let data = data else {
                print("NO DATA")
                return
            }

            // Verify results as String
            guard let result = String(data: data, encoding: .utf8)  else {
                return
            }
            print("THIS IS THE RESULT ->", result)

            // Add JSON Decoding in URLSession closure
            let decoder = JSONDecoder()
            guard let response = try? decoder.decode(MailingsResponse.self, from: data) else {
                print("NO RESPONSE DATA")
                return
            }

            print("THIS IS THE RESPONSE ->", response)
            // Update mailing items on main thread

            DispatchQueue.main.async {
                let mailingItems = response.mailings.reduce(into: []) { mailings, mailingElement in
                    mailings.append(mailingElement.mailing)
                }
            }
        }.resume()
    }
}
