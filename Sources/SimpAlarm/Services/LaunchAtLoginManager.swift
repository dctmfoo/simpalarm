import Foundation
import ServiceManagement

struct LaunchAtLoginManager {
    func currentEnabledState() -> Bool {
        switch SMAppService.mainApp.status {
        case .enabled, .requiresApproval:
            true
        case .notFound, .notRegistered:
            false
        @unknown default:
            false
        }
    }

    func setEnabled(_ isEnabled: Bool) throws {
        let service = SMAppService.mainApp
        let currentState = currentEnabledState()

        guard currentState != isEnabled else { return }

        if isEnabled {
            try service.register()
        } else {
            try service.unregister()
        }
    }
}
