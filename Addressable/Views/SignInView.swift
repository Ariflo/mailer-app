//
//  SignInView.swift
//  Addressable
//
//  Created by Arian Flores on 12/1/20.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var app: Application
    @ObservedObject var viewModel: SignInViewModel

    init(viewModel: SignInViewModel) {
        self.viewModel = viewModel
    }

    @State var username: String = ""
    @State var password: String = ""
    @State var showingAlert = false
    @State var alertText: String = ""
    @State var authorizedUser: Int?
    @State var isNavigationBarHidden: Bool = true
    @State var secured: Bool = true

    var body: some View {
        VStack {
            Image("ZippyIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)

            TextField("Username", text: $username)
                .textContentType(.username)
                .keyboardType(.emailAddress)
                .modifier(TextFieldModifier())

            HStack {
                if secured {
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .modifier(TextFieldModifier())
                } else {
                    TextField("Password", text: $password)
                        .modifier(TextFieldModifier())
                }

                Button(action: {
                    secured.toggle()
                }) {
                    if secured {
                        EyeImage(name: "EyeClose")
                    } else {
                        EyeImage(name: "EyeOpen")
                    }
                }
            }

            NavigationLink(destination: AppView().environmentObject(app), tag: 1, selection: $authorizedUser) {
                Button(action: {
                    let account = username.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let pwd = password.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

                    guard !(account.isEmpty || pwd.isEmpty) else {
                        alertText = "Please enter a username and password."
                        showingAlert = true
                        return
                    }

                    let loginString = String(format: "%@:%@", account, pwd)
                    if let loginData = loginString.data(using: String.Encoding.utf8) {
                        viewModel.login(with: loginData.base64EncodedString()) { authenticatedUserInfo in
                            guard authenticatedUserInfo != nil else {
                                alertText = "Incorrect Username or Password. Try Again!"
                                showingAlert = true
                                return
                            }

                            KeyChainServiceUtil.shared[userBasicAuthToken] = loginData.base64EncodedString()

                            // For the case where a user signs into the application on a previously registered device
                            // register said user with the device on Addressable's DB
                            guard let callManager = app.callManager,
                                  let deviceToken = KeyChainServiceUtil.shared[latestDeviceID] else {
                                // In this case the device was not previously registered, safe to proceed
                                logInToApplication()
                                return
                            }
                            callManager.fetchToken(
                                deviceID: deviceToken
                            ) { tokenData in
                                guard tokenData?.jwtToken != nil else {
                                    alertText = "Sorry something went wrong, " +
                                        "try again or reach out to an Addressable " +
                                        "representative if the problem persists."
                                    showingAlert = true
                                    return
                                }
                                logInToApplication()
                            }
                        }
                    }
                }) {
                    Text("Log In")
                        .foregroundColor(Color.gray)
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text(alertText))
                }
            }
            if let versionNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String,
               let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                Text("v\(appVersion) (\(versionNumber))")
                    .foregroundColor(Color.black)
                    .padding()
            }
        }
        .padding()
    }
    private func logInToApplication() {
        if KeyChainServiceUtil.shared[userBasicAuthToken] != nil {
            app.currentView = .dashboard(false)
            authorizedUser = 1
        } else {
            alertText = "Sorry something went wrong, " +
                "try again or reach out to an Addressable " +
                "representative if the problem persists."
            showingAlert = true
        }
    }
}

struct EyeImage: View {
    private var imageName: String

    init(name: String) {
        self.imageName = name
    }

    var body: some View {
        Image(imageName)
            .resizable()
            .frame(width: 34, height: 34, alignment: .trailing)
    }
}

#if DEBUG
struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(viewModel: SignInViewModel(provider: DependencyProvider()))
    }
}
#endif
