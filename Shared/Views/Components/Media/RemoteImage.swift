//
//  RemoteImage.swift
//  Codename Starlight
//
//  Created by Alejandro Modroño Vara on 14/07/2020.
//

import Foundation
import SwiftUI

/// A view that displays a non-environment-dependent image, on demand, from a remote
/// url.
///
/// A ``RemoteImage`` is a late-binding token, which means that its actual value is
/// only resolved when it's about to be used in a given environment.
///
/// ``RemoteImage`` also makes use of NSCache to cache the resulting image data, so
/// images dont need to be reloaded.
@available(swift, deprecated: 1.0, message: "Please use URLImage instead.")
public struct RemoteImage<Placeholder, Result>: View where Placeholder: View, Result: View {

    /// A function you can use to create a placeholder users will see before the image is actually loaded.
    public let placeholder: Placeholder

    /// A function you can use to display the remote image.
    public let result: (Image) -> Result

    /// Used for telling the SwiftUI view to redraw itself
    /// once the image data is fetched.
    @Binding var redraw: Bool

    /// An ObservableObject that is used to be notified when the image data is available.
    @ObservedObject private var remoteImageModel: RemoteImageModel

    public var body: some View {

        VStack {
            if let remoteImage = self.remoteImageModel.image {

                result(Image(uiImage: remoteImage))
                    .onAppear {
                        self.redraw.toggle()
                    }

            } else {

                self.placeholder
                    .onAppear {
                        self.redraw.toggle()
                    }

            }
        }
            // So that the transition between the placeholder content and the actual image is smooth.
            .animation(.spring())

    }

}

extension RemoteImage where Placeholder: View {

    /// Generates a View that retrieves image data from a remote URL
    /// (usually decoded from JSON), that automatically changes across updates;
    /// and caches it.
    ///
    /// It's important that `result` makes use of the escaping closure to display the image,
    /// or else anything will be displayed. If a problem occurs while retrieving the data, an
    /// error message will be provided. You should log that and maybe show a simple message to the user.
    ///
    /// - Parameters:
    ///     - from: The ``Account``'s static avatar url ``CachedRemoteImage`` uses to retrieve the data.
    ///     - placeholder: The view builder that generates the placeholder to be shown until the avatar
    ///       data is retrieved.
    ///     - error: An optional string of the error that occurred while fetching the image data.
    ///     - result: A function you can use to display the resulting image.
    public init(from urlString: String?, redraw: Binding<Bool>, @ViewBuilder placeholder: () -> Placeholder?,
                error: String? = nil, @ViewBuilder result: @escaping (Image) -> Result) {
        self.remoteImageModel = RemoteImageModel(urlString)

        // swiftlint:disable:next force_cast
        self.placeholder = placeholder() ?? EmptyView() as! Placeholder
        self.result = result
        _redraw = redraw
    }

}

struct RemoteImage_Previews: PreviewProvider {

    // swiftlint:disable:next line_length
    static let url = "https://files.mastodon.social/cache/media_attachments/files/104/496/498/501/770/612/original/b9c7a301dd755f73.jpeg"

    @State static var redraw: Bool = false

    static var previews: some View {

        RemoteImage(
            from: url,
            redraw: self.$redraw,
            placeholder: {
                Image("sotogrande")
                    .resizable()
                    .redacted(reason: .placeholder)
            },
            result: { image in
                image
                    .resizable()
            }
        )

    }

}