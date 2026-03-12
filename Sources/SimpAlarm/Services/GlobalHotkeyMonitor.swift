import Carbon
import Foundation

final class GlobalHotkeyMonitor {
    private var eventHandler: EventHandlerRef?
    private var hotKeyRef: EventHotKeyRef?
    private let hotKeyID = EventHotKeyID(signature: 0x53414C4D, id: 1)

    var onHotkeyPressed: (@MainActor @Sendable () -> Void)?

    func register() {
        guard hotKeyRef == nil else { return }

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let handlerStatus = InstallEventHandler(
            GetApplicationEventTarget(),
            { _, eventRef, userData in
                guard let userData, let eventRef else { return noErr }

                var resolvedHotKeyID = EventHotKeyID()
                let status = GetEventParameter(
                    eventRef,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &resolvedHotKeyID
                )

                guard status == noErr, resolvedHotKeyID.id == 1 else { return noErr }

                let monitor = Unmanaged<GlobalHotkeyMonitor>.fromOpaque(userData).takeUnretainedValue()
                let callback = monitor.onHotkeyPressed
                Task { @MainActor in
                    callback?()
                }

                return noErr
            },
            1,
            &eventType,
            UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
            &eventHandler
        )

        guard handlerStatus == noErr else { return }

        RegisterEventHotKey(
            UInt32(kVK_ANSI_B),
            UInt32(controlKey) | UInt32(shiftKey),
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
    }

    func unregister() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }

        if let eventHandler {
            RemoveEventHandler(eventHandler)
        }

        hotKeyRef = nil
        eventHandler = nil
    }

    deinit {
        unregister()
    }
}
