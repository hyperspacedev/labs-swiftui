//
//  NetworkViewModel:.swift
//  Codename Starlight
//
//  Created by Alejandro Modroño Vara on 11/07/2020.
//

import Foundation

/// An ``ObservableObject`` that computes and retrieves statuses on demand from the fediverse,
/// using Mastodon's API endpoints.
public class NetworkViewModel: ObservableObject {

    // MARK: - STORED PROPERTIES

    /// An array composed of several ``Status``, that compose the timeline.
    @Published var statuses = [Status]()

    @Published var type: String = "public" {
        didSet {
            self.statuses = []

            if self.type == "public" {
                self.fetchPublicTimeline()
            } else {
                self.fetchLocalTimeline()
            }
        }
    }

    func fetchPublicTimeline() {

        guard let url = URL(string: "https://mastodon.social/api/v1/timelines/public") else { return }

        URLSession.shared.dataTask(with: url) { (data, resp, error) in

            print("resp: \(resp as Any)\n\nerror: \(String(describing: error))\n\ndata: \(String(describing: data))")

            DispatchQueue.main.async {
                do {
                        let result = try JSONDecoder().decode([Status].self, from: data!)
                        self.statuses = result
                        print("result: \(result)")
                } catch {
                    print(error)
                }
            }

        }
        .resume()

    }

    func fetchLocalTimeline() {

        guard let url = URL(string: "https://mastodon.social/api/v1/timelines/public?local=true") else { return }

        URLSession.shared.dataTask(with: url) { (data, resp, error) in

            print("resp: \(resp as Any)\n\nerror: \(String(describing: error))\n\ndata: \(String(describing: data))")

            DispatchQueue.main.async {
                do {
                    let result = try JSONDecoder().decode([Status].self, from: data!)
                    self.statuses = result
                    print("result: \(result)")
                } catch {
                    print(error)
                }
            }

        }
        .resume()

    }

}
