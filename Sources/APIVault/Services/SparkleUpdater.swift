import Foundation
import Sparkle
import Observation

@MainActor
@Observable
final class SparkleUpdater {
    static let shared = SparkleUpdater()
    
    private let updaterController: SPUStandardUpdaterController
    
    private init() {
        // Initializes the updater controller and starts the automatic updater check in the background.
        self.updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
    }
    
    func checkForUpdates() {
        updaterController.updater.checkForUpdates()
    }
    
    var canCheckForUpdates: Bool {
        updaterController.updater.canCheckForUpdates
    }
}
