//
//  FieldList.swift
//  Codename Starlight
//
//  Created by Alejandro Modroño Vara on 29/7/20.
//

import SwiftUI
import Atributika

struct FieldList: View {

    let fields: [Field]

    // MARK: USER NOTE TEXT STYLES
    private let rootStyle: Style = Style("p")
        .font(.systemFont(ofSize: 17, weight: .regular))
    private let linkStyle: Style = Style("a")
        .foregroundColor(#colorLiteral(red: 0.6050000191, green: 0.3829999864, blue: 1, alpha: 1))

    /// Configure the label to match the styling for the status.
    private func configureLabel(_ label: AttributedLabel, size: CGFloat = 17) {
        label.numberOfLines = 0
        label.textColor = .label
        label.lineBreakMode = .byWordWrapping
        label.onClick = { labelClosure, detection in
            switch detection.type {
            case .link(let url):
                openUrl(url)
            default:
                break
            }
        }
    }

    var bounds: CGFloat {
        #if os(macOS)
        // Note: Need to subtract sidebar size here.
        let bounds: CGFloat = NSApplication.shared.mainWindow?.frame.width ?? 0
        #else
        let bounds: CGFloat = UIScreen.main.bounds.width
        #endif

        return bounds
    }

    var padding: CGFloat = 140

    var body: some View {

        VStack(alignment: .leading) {

            Divider()

            ForEach(self.fields, id: \.self.id) { field in
                HStack {

                    HStack {
                        Text(verbatim: field.name)
                            .lineLimit(1)
                        Spacer()
                    }
                        .frame(width: 100)

                    Divider()

                    ZStack {
                        AttributedTextView(
                            attributedText: "\(field.value)"
                                .style(tags: [rootStyle, linkStyle]),
                            configured: { label in
                                self.configureLabel(label, size: 20)
                            },
                            maxWidth: bounds - padding)
                        .fixedSize()

                        if field.verifiedAt != nil {
                            Color.green.opacity(0.3)
                                .frame(width: bounds - padding)
                        }
                    }

                }

                Divider()

            }

        }
    }

}

struct FieldList_Previews: PreviewProvider {

    @StateObject static var accountInfo: ProfileViewModel = ProfileViewModel(accountID: "1")

    static var previews: some View {

        VStack {
            if let data = self.accountInfo.data {
                FieldList(fields: data.fields)
            } else {
                Text("Hello")
                    .onAppear {
                        self.accountInfo.fetchProfile()
                        self.accountInfo.fetchProfileStatuses()
                    }
            }
        }
    }
}