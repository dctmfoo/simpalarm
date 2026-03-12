import AppKit
import Darwin

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var store: AlarmStore?
    private var lockFileDescriptor: Int32 = -1

    func applicationWillFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard acquireSingleInstanceLock() else {
            NSApp.terminate(nil)
            return
        }

        NSApp.setActivationPolicy(.accessory)
        let store = AlarmStore()
        self.store = store
        WindowCoordinator.shared.install(store: store)
        StatusBarController.shared.install(store: store)
        WindowCoordinator.shared.applicationDidFinishLaunching()
    }

    func applicationWillTerminate(_ notification: Notification) {
        releaseSingleInstanceLock()
    }

    private func acquireSingleInstanceLock() -> Bool {
        let lockPath = "/tmp/simpalarm.lock"
        lockFileDescriptor = open(lockPath, O_CREAT | O_RDWR, S_IRUSR | S_IWUSR)

        guard lockFileDescriptor != -1 else {
            return true
        }

        if flock(lockFileDescriptor, LOCK_EX | LOCK_NB) == 0 {
            return true
        }

        close(lockFileDescriptor)
        lockFileDescriptor = -1
        return false
    }

    private func releaseSingleInstanceLock() {
        guard lockFileDescriptor != -1 else { return }
        flock(lockFileDescriptor, LOCK_UN)
        close(lockFileDescriptor)
        lockFileDescriptor = -1
    }
}
