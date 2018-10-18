/// [MIT License](https://github.com/alexito4/Trap/blob/master/LICENSE).
/// Source: https://github.com/alexito4/Trap

import Foundation

/// Handle [OS Signals](http://www.gnu.org/software/libc/manual/html_node/Defining-Handlers.html#Defining-Handlers).
public enum Trap {
    /// OS Signal recognized by `Trap`.
    public enum Signal: Int32, CaseIterable {
        case hangup
        case interrupt
        case illegal
        case trap
        case abort
        case kill
        case alarm
        case termination
        
        /// Return the OS values
        internal var osValue: Int32 {
            switch self {
            case .hangup:      return SIGHUP
            case .interrupt:   return SIGINT
            case .illegal:     return SIGILL
            case .trap:        return SIGTRAP
            case .abort:       return SIGABRT
            case .kill:        return SIGKILL
            case .alarm:       return SIGALRM
            case .termination: return SIGTERM
            }
        }
    }
    
    /// Typealias for the C-style block.
    public typealias SignalHandler = @convention(c) (Int32) -> (Void)
    
    /// Establishes the signal handler.
    /// - parameter signal: The signal to handle.
    /// - parameter action: Code to execute when the signal is fired.
    /// - SeeAlso: [Advanced Signal Handling](http://www.gnu.org/software/libc/manual/html_node/Advanced-Signal-Handling.html#Advanced-Signal-Handling)
    public static func handle(signal: Signal, action: @escaping SignalHandler) {
        // Instead of using just `signal` we can use the more powerful `sigaction`
        var underlyingAction = sigaction(__sigaction_u: __sigaction_u(__sa_handler: action), sa_mask: 0, sa_flags: 0)
        sigaction(signal.osValue, &underlyingAction, nil)
    }
    
    /// Establishes multiple `signals` to be handled by the `action`
    /// - parameter signals: The multiple signal to handle.
    /// - parameter action:  Code to execute when any of the signals is fired.
    public static func handle(signals: [Signal], action: @escaping SignalHandler) {
        signals.forEach {
            handle(signal: $0, action: action)
        }
    }
}
