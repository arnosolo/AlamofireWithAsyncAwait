//
//  ContentView.swift
//  AlamofireWithAsyncAwait
//
//  Created by Arno Solo on 1/27/23.
//

import SwiftUI

class ContentViewViewModel: ObservableObject {
    @MainActor @Published var errorMessage = ""
    @MainActor @Published var appliances: [Appliance] = []

    func fetchAppliances() async {
        await MainActor.run {
            self.errorMessage = ""
        }
        if let res = await NetworkAPI.getAppliances() {
            await MainActor.run {
                self.appliances = res
            }
        } else {
            await MainActor.run {
                self.errorMessage = "Fetch data failed"
            }
        }
    }
}

struct ContentView: View {
    @StateObject var viewModel = ContentViewViewModel()

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            if viewModel.errorMessage != "" {
                Text(viewModel.errorMessage)
            }
            Button("Fetch") {
                Task {
                    await viewModel.fetchAppliances()
                }
            }
            List {
                ForEach(viewModel.appliances, id: \.id) { item in
                    Text("\(item.brand) - \(item.equipment)")
                }
            }
            .listStyle(.inset)
        }
        .padding()
        .onAppear {
            Task {
                await viewModel.fetchAppliances()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
