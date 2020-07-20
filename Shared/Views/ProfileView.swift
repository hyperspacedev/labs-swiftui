//
//  ProfileView.swift
//  Codename Starlight
//
//  Created by Marquis Kurt on 7/13/20.
//

import SwiftUI
import Atributika

struct ProfileView: View {

    private let imageHeight: CGFloat = 200
    private let collapsedImageHeight: CGFloat = 95

    private let bioStyle = Style("p").font(.systemFont(ofSize: 17))

    public var isParent: Bool = true

    @ObservedObject private var contentFrame: ViewFrame = ViewFrame()
    @ObservedObject var accountInfo: ProfileViewModel = ProfileViewModel(accountID: "1")

    @State private var titleRect: CGRect = CGRect(x: 0, y: 0, width: 100, height: 100)
    @State private var headerImageRect: CGRect = CGRect(x: 0, y: 0, width: 100, height: 100)
    @State private var showMoreActions: Bool = false

    var bounds: CGFloat {
        #if os(macOS)
        // Note: Need to subtract sidebar size here.
        let bounds: CGFloat = NSApplication.shared.mainWindow?.frame.width
        #else
        let bounds: CGFloat = UIScreen.main.bounds.width
        #endif

        return bounds
    }

    let padding: CGFloat = 10

    // MARK: USER NOTE TEXT STYLES
    private let rootStyle: Style = Style("p")
        .font(.systemFont(ofSize: 17, weight: .regular))

    /// Configure the label to match the styling for the status.
    private func configureLabel(_ label: AttributedLabel, size: CGFloat = 17) {
        label.numberOfLines = 0
        label.textColor = .label
        label.lineBreakMode = .byWordWrapping
    }

    public var onResumeToParent: () -> Void = {}

    func getScrollOffset(_ geometry: GeometryProxy) -> CGFloat {

        geometry.frame(in: .global).minY

    }

    func getOffsetForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {

        let offset = getScrollOffset(geometry)
        let sizeOffScreen = imageHeight - collapsedImageHeight

        if offset < -sizeOffScreen {

            let imageOffset = abs(min(-sizeOffScreen, offset))

            return imageOffset - sizeOffScreen
        }

        if offset > 0 {

            return -offset

        }

        return 0

    }

    func getHeightForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {

        let offset = getScrollOffset(geometry)
        let imageHeight = geometry.size.height
        if offset > 0 {
            return imageHeight + offset
        }
        return imageHeight

    }

    func getBlurRadiusForImage(_ geometry: GeometryProxy) -> CGFloat {

        let offset = geometry.frame(in: .global).maxY
        let height = geometry.size.height
        let blur = (height - max(offset, 0)) / height

        return blur * 6

    }

    private func getHeaderTitleOffset() -> CGFloat {
        let currentYPos = titleRect.midY

        if currentYPos < headerImageRect.maxY {

            let minYValue: CGFloat = 50.0
            let maxYValue: CGFloat = collapsedImageHeight
            let currentYValue = currentYPos
            let percentage = max(-1, (currentYValue - maxYValue) / (maxYValue - minYValue))

            let finalOffset: CGFloat = -30.0

            return 20 - (percentage * finalOffset)

        }

        return .infinity

    }

    var body: some View {

        NavigationView {
            if self.accountInfo.statuses.isEmpty {
                HStack {

                    Spacer()

                    VStack {
                        Spacer()
                        ProgressView(value: 0.5)
                            .progressViewStyle(CircularProgressViewStyle())
                        Text("Loading posts...")
                        Spacer()
                    }

                    Spacer()

                }
                .onAppear {
                    // A bit hacky but it works for now
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        self.accountInfo.fetchProfile()
                        self.accountInfo.fetchProfileStatuses()
                    })
                }
            } else {
                ScrollView {

                    LazyVStack(alignment: .leading, spacing: 10) {

                        VStack(alignment: .leading) {

                            HStack {

                                Text(accountInfo.data?.displayName ?? "User")
                                    .font(.title)
                                    .bold()
                                    .background(GeometryGetter(rect: self.$titleRect))

//                                if accountInfo.isDev {
//
//                                    Text("STARLIGHT DEV")
//                                        .foregroundColor(.secondary)
//                                        .padding(.all, 5)
//                                        .font(.caption2)
//                                        .background(
//                                            Color(.systemGray5)
//                                                .cornerRadius(3)
//                                        )
//
//                                }

                                if let isBot = accountInfo.data?.bot {

                                    if isBot {
                                        Text("BOT")
                                            .bold()
                                            .foregroundColor(.white)
                                            .padding(.all, 5)
                                            .font(.caption2)
                                            .background(
                                                Color.blue
                                                    .cornerRadius(3)
                                            )
                                    }

                                }

                                Spacer()

                                Button(action: {
                                    self.showMoreActions.toggle()
                                }, label: {
                                    Image(systemName: "ellipsis")
                                        .imageScale(.large)
                                })

                            }

                            Text("@\(accountInfo.data?.acct ?? "user")")
                                .font(.callout)
                                .foregroundColor(.secondary)

//                            GeometryReader { geometry in
//                                AttributedTextView(attributedText:
//                                                    "\(accountInfo.data?.note ??  "No bio provided.")"
//                                                    .style(tags: bioStyle),
//                                                   configured: { label in
//                                                    label.numberOfLines = 0
//                                                    label.textColor = .label
//                                                    label.lineBreakMode = .byWordWrapping
//                                                   }, maxWidth: geometry.size.width)
//                            }

                            VStack(alignment: .leading) {
                                AttributedTextView(
                                    attributedText: "\(accountInfo.data?.note ??  "No bio provided.")"
                                        .style(tags: rootStyle),
                                    configured: { label in
                                        self.configureLabel(label, size: 20)
                                    },
                                    maxWidth: bounds - padding)
                                .fixedSize()
                            }
                                .padding(.top, 10)

                            Divider()

                            HStack {

                                VStack {

                                    Text("\((accountInfo.data?.followersCount ?? 0).roundedWithAbbreviations)")
                                        .font(.system(size: 20, weight: .semibold, design: .rounded))

                                    Text("Followers \(Image(systemName: "person.3"))")
                                        .fontWeight(.semibold)
                                }

                                Spacer()

                                VStack {

                                    Text("\((accountInfo.data?.followingCount ?? 0).roundedWithAbbreviations)")
                                        .font(.system(size: 20, weight: .semibold, design: .rounded))

                                    Text("Following  \(Image(systemName: "person.2"))")
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                        .fontWeight(.semibold)

                                }

                                Spacer()

                                VStack {

                                    Text("\((accountInfo.data?.statusesCount ?? 0).roundedWithAbbreviations)")
                                        .font(.system(size: 20, weight: .semibold, design: .rounded))

                                    Text("Toots \(Image(systemName: "doc.richtext"))")
                                        .fontWeight(.semibold)

                                }

                            }

                            Divider()

                        }

                        VStack {
                            ForEach(self.accountInfo.statuses, id: \.self.id) { status in

                                StatusView(status: status)
                                    .onAppear {
                                        self.accountInfo.updateProfileStatuses(currentItem: status)
                                    }

                                Divider()
                                    .padding(.leading, 20)

                            }
                        }

                    }
                        .padding(.horizontal)
                        .padding(.top, 16.0)
                        .offset(y: imageHeight)
                        .background(GeometryGetter(rect: $contentFrame.frame))

                    GeometryReader { geometry in

                        ZStack(alignment: .bottom) {
                            Image("sotogrande")
                                .resizable()
                                .scaledToFill()
                                .frame(width: geometry.size.width, height: self.getHeightForHeaderImage(geometry))
                                .blur(radius: self.getBlurRadiusForImage(geometry) - 3)
                                .clipped()
                                .background(GeometryGetter(rect: self.$headerImageRect))

                            HStack {

                                if !isParent {
                                    Button(action: {
                                        self.onResumeToParent()
                                    }, label: {
                                        Image(systemName: "chevron.left")
                                            .font(.system(size: 25, weight: .semibold))
                                            .foregroundColor(.white)
                                    })
                                } else {
                                    Button(action: {}, label: {
                                        Image(systemName: "pencil")
                                            .font(.system(size: 25, weight: .semibold))
                                            .foregroundColor(.white)
                                    })
                                }

                                Spacer()

                                VStack {

                                    Text(accountInfo.data?.displayName ?? "user")
                                        .font(.system(size: 15))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)

                                    Text("@\(accountInfo.data?.acct ?? "user@instance")")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(.systemGray3))

                                }

                                Spacer()

                                Button(action: {}, label: {
                                    Image(systemName: "ellipsis")
                                        .font(.system(size: 25, weight: .semibold))
                                        .foregroundColor(.white)
                                })

                            }
                                .padding(.horizontal)
                                .offset(x: 0, y: self.getHeaderTitleOffset())

                            VStack {

                                HStack {

                                    if !isParent {
                                        Button(action: {
                                            self.onResumeToParent()
                                        }) {
                                            Image(systemName: "chevron.left")
                                                .font(.system(size: 25, weight: .semibold))
                                                .foregroundColor(.white)
                                                .padding(10)
                                        }
                                    }

                                    Spacer()

                                    Button(action: {}, label: {
                                        Image(systemName: "pencil")
                                            .font(.system(size: 25, weight: .semibold))
                                            .foregroundColor(.white)
                                            .padding(10)
                                    })

                                }

                                Spacer()

                            }
                                .padding()
                                .padding(.top)

                        }
                        .clipped()
                        .offset(x: 0, y: self.getOffsetForHeaderImage(geometry))
                    }
                        .frame(height: imageHeight)
                        .offset(x: 0, y: -(contentFrame.startingRect?.maxY ?? UIScreen.main.bounds.height))
                }
                    .edgesIgnoringSafeArea(.all)
                    .navigationBarHidden(true)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("Profile")
            }

        }
            .actionSheet(isPresented: self.$showMoreActions) {
                ActionSheet(title: Text("More Actions"),
                            buttons: [
                                .default(Text("Share \(Image(systemName: "square.and.arrow.up"))"), action: {

                                }),
                                .default(Text("Show more info"), action: {

                                }),
                                .destructive(Text("Block @\(accountInfo.data?.acct ?? "user")"), action: {

                                }),
                                .destructive(Text("Report @\(accountInfo.data?.acct ?? "user")"), action: {

                                }),
                                .cancel(Text("Dismiss"), action: {})
                            ]
                )
            }
    }

}

struct AccountView_Previews: PreviewProvider {

    static var previews: some View {

        ProfileView()

    }

}

class ViewFrame: ObservableObject {

    var startingRect: CGRect?

    @Published var frame: CGRect {

        willSet {

            if startingRect == nil {

                startingRect = newValue

            }

        }

    }

    init() {

        self.frame = CGRect(x: 0, y: 0, width: 100, height: 100)

    }

}

struct GeometryGetter: View {

    @Binding var rect: CGRect

    var body: some View {

        GeometryReader { geometry in

            AnyView(Color.clear)
                .preference(key: RectanglePreferenceKey.self, value: geometry.frame(in: .global))

        }.onPreferenceChange(RectanglePreferenceKey.self) { (value) in

            self.rect = value

        }

    }

}

struct RectanglePreferenceKey: PreferenceKey {

    static var defaultValue: CGRect = CGRect(x: 0, y: 0, width: 100, height: 100)

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {

        value = nextValue()

    }

}
