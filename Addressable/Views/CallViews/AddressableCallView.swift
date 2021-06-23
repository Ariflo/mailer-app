//
//  AddressableCallView.swift
//  Addressable
//
//  Created by Ari on 2/2/21.
//

import SwiftUI

struct AddressableCallView: View {
    @EnvironmentObject var app: Application
    @ObservedObject var viewModel: CallsViewModel

    @State var displayKeyPad = false
    @State var callOnHold = false
    @State var callIsMuted = false
    @State var callIsOnSpeaker = false
    @State var scrollText = false

    init(viewModel: CallsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color(red: 78 / 255, green: 71 / 255, blue: 210 / 255)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 25) {
                Text(app.callState)
                    .font(Font.custom("Silka-Medium", size: 22))
                    .foregroundColor(.white)
                Image("ZippyIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                Text(app.callManager?.currentCallerID.caller ?? CallerID().caller)
                    .font(Font.custom("Silka-Medium", size: 22))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Text(app.callManager?.currentCallerID.relatedMailingName ?? CallerID().relatedMailingName)
                    .font(Font.custom("Silka-Medium", size: 22))
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Addressable name matching is beta, information may not be accurate." +
                        " Verify with caller to confirm accuracy")
                    .font(Font.custom("Silka-Medium", size: 16))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 20)
                Spacer()
                HStack(spacing: 25) {
                    // MARK: - Mute
                    VStack(spacing: 8) {
                        Button(action: {
                            guard let currentActiveCall = app.callManager?.currentActiveCall else {
                                print("No currentActiveCall avaliable to mute")
                                return
                            }
                            app.callManager?.setMuted(call: currentActiveCall, isMuted: !callIsMuted)
                            callIsMuted.toggle()
                        }) {
                            Image(systemName: callIsMuted ? "mic.slash.fill" : "mic.slash")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white, lineWidth: 4)
                                )
                        }
                        Text("Mute")
                            .font(Font.custom("Silka-Medium", size: 16))
                            .foregroundColor(.white)
                    }
                    // MARK: - Speaker
                    VStack(spacing: 8) {
                        Button(action: {
                            app.callManager?.toggleAudioToSpeaker(isSpeakerOn: !callIsOnSpeaker)
                            callIsOnSpeaker.toggle()
                        }) {
                            Image(systemName: callIsOnSpeaker ? "speaker.3.fill" : "speaker.3")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white, lineWidth: 4)
                                )
                        }
                        Text("Speaker")
                            .font(Font.custom("Silka-Medium", size: 16))
                            .foregroundColor(.white)
                    }
                }

                HStack(spacing: 25) {
                    // MARK: - Hold
                    VStack(spacing: 8) {
                        Button(action: {
                            guard let currentActiveCall = app.callManager?.currentActiveCall else {
                                print("No currentActiveCall avaliable to hold")
                                return
                            }
                            app.callManager?.setHeld(call: currentActiveCall, onHold: !callOnHold)
                            callOnHold.toggle()
                        }) {
                            Image(systemName: callOnHold ? "pause.circle.fill": "pause.circle")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white, lineWidth: 4)
                                )
                        }
                        Text("Hold")
                            .font(Font.custom("Silka-Medium", size: 16))
                            .foregroundColor(.white)
                    }
                    // MARK: - Add Participant
                    VStack(spacing: 8) {
                        Button(action: {
                            displayKeyPad = true
                        }) {
                            Image(systemName: app.callManager?.getIsCurrentCallIncoming() ??
                                    false ?
                                    "person.crop.circle.badge.xmark":"person.badge.plus")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white, lineWidth: 4)
                                )
                        }.disabled(app.callManager?.getIsCurrentCallIncoming() ?? false)
                        Text("Add Caller")
                            .font(Font.custom("Silka-Medium", size: 16))
                            .foregroundColor(.white)
                    }
                    // MARK: - Return to Campaigns
                    VStack(spacing: 8) {
                        Button(action: {
                            // Display Outgoing Call View
                            DispatchQueue.main.async {
                                app.currentView = .dashboard(false)
                            }
                        }) {
                            Image(systemName: "mail")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white, lineWidth: 4)
                                )
                        }
                        Text("Campaigns")
                            .font(Font.custom("Silka-Medium", size: 16))
                            .foregroundColor(.white)
                    }
                }
                Spacer()
                // MARK: - Hang Up Call
                Button( action: {
                    guard let callManager = app.callManager else {
                        print("No callManager avaliable to end call")
                        return
                    }
                    guard let uuid = callManager.currentActiveCall?.uuid else {
                        print("No currentActiveCall UUID avaliable to end")
                        return
                    }
                    callManager.endCall(with: uuid)
                }) {
                    Image(systemName: "phone.down.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.red)
                        .frame(width: 50, height: 50)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.red, lineWidth: 4)
                        )
                }
            }
        }.sheet(isPresented: $displayKeyPad) {
            KeyPadView(viewModel: CallsViewModel(provider: app.dependencyProvider))
                .environmentObject(app)
                .navigationBarHidden(true)
        }
    }
}

#if DEBUG
struct AddressableCallView_Previews: PreviewProvider {
    static var previews: some View {
        AddressableCallView(viewModel: CallsViewModel(provider: DependencyProvider()))
    }
}
#endif