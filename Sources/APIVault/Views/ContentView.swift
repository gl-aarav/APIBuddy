import SwiftUI

struct ContentView: View {
    @State private var viewModel = VaultViewModel()
    @Namespace private var glassNamespace

    var body: some View {
        GlassEffectContainer(spacing: 18) {
            NavigationSplitView {
                SidebarView(viewModel: viewModel)
                    .navigationSplitViewColumnWidth(min: 250, ideal: 280, max: 340)
            } detail: {
                PresetDetailView(viewModel: viewModel, namespace: glassNamespace)
            }
            .searchable(text: Bindable(viewModel).searchText, placement: .toolbar, prompt: "Search presets")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.refreshKeyPresence()
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(.glass)
                    .buttonBorderShape(.capsule)
                    .help("Refresh keychain status")
                }
            }
        }
    }
}
