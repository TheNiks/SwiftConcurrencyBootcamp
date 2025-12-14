//
//  DoCatchTryThrows.swift
//  SwiftConDoTryCatchThrows
//
//  Created by Nikunj Modi on 13/12/25.
//

import SwiftUI
import Combine


class DoCatchThrowsDataManager {
    let isActive = true
    func getTitle() -> Result<String, Error> {
        if isActive {
            return .success("Nikunj")
        } else {
            return .failure(URLError(.badURL))
        }
    }
    
    func getTitle1() throws -> String {
        /*if isActive {
            return "Nikunj"
        } else {
            throw URLError(.backgroundSessionInUseByAnotherProcess)
        }*/
        
        throw URLError(.backgroundSessionInUseByAnotherProcess)
    }
    
    func getTitle2() throws -> String {
        if isActive {
            return "getTitle2 Nikunj"
        } else {
            throw URLError(.backgroundSessionInUseByAnotherProcess)
        }
    }
}

class DoCatchThrowsViewModel:ObservableObject {
    @Published var text: String = "Somethings text"
    let manager = DoCatchThrowsDataManager()
    func fetchTitle() {
        /* let returnValue = manager.getTitle()
        switch returnValue {
        case .success(let newTitle):
             self.text = newTitle
        case .failure(let error):
             self.text = error.localizedDescription
        }*/
        
        do {
            let newTitle = try? manager.getTitle1()
            if let newTitle = newTitle {
                self.text = newTitle
            }
            let finalTitle = try manager.getTitle2()
            self.text = finalTitle
            
        } catch {
            self.text = error.localizedDescription
        }
    }
}
struct DoCatchTryThrows: View {
    @StateObject var viewModel = DoCatchThrowsViewModel()
    var body: some View {
        Text(viewModel.text)
            .frame(width: 300, height: 300)
            .background(.blue)
            .onTapGesture {
                viewModel.fetchTitle()
            }
    }
}

#Preview {
    DoCatchTryThrows()
}
