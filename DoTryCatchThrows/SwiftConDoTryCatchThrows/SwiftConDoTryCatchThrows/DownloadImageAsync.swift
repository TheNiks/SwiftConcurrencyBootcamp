//
//  DoanloadImageAsync.swift
//  SwiftConDoTryCatchThrows
//
//  Created by Nikunj Modi on 13/12/25.
//

import SwiftUI
import Combine

class DownloadImageLoader {
    let url = URL(string: "https://picsum.photos/200")!
    
    func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
        guard
            let data = data,
            let image = UIImage(data: data),
            let response = response as? HTTPURLResponse,
            response.statusCode >= 200 && response.statusCode < 300 else  {
            return nil
        }
        return image
    }
    
    func downloadImage(completionHandler: @escaping (_ image: UIImage?,_ error:Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            let image = self?.handleResponse(data: data, response: response)
            completionHandler(image, nil)
        }
        .resume()
    }
    
    func downloadImageWithCombine() -> AnyPublisher<UIImage?, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map(handleResponse)
            .mapError({ $0 })
            .eraseToAnyPublisher()
    }
    
    func downloadWithAsync() async throws -> UIImage? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
            return handleResponse(data: data, response: response)
        } catch {
            throw error
        }
    }
}

class DownloadImageAsyncViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    let loader = DownloadImageLoader()
    var cancellable = Set<AnyCancellable>()
    func fetchImage() async {
//        loader.downloadImage { image, error in
//            DispatchQueue.main.async { [weak self] in
//                self?.image = image
//            }
//        }
        
//        loader.downloadImageWithCombine()
//            .receive(on: DispatchQueue.main)
//            .sink { _ in
//                
//            } receiveValue: { [weak self] image in
//                self?.image = image
//            }
//            .store(in: &cancellable)
        
        let image = try? await loader.downloadWithAsync()
        self.image = image

    }
    
}
struct DownloadImageAsync: View {
    @StateObject var viewModel = DownloadImageAsyncViewModel()
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchImage()
            }
            
        }
    }
}

#Preview {
    DownloadImageAsync()
}
