import Common
import Foundation
import Gist

public protocol InAppEventListener: AutoMockable {
    func messageShown(message: InAppMessage)
    func messageDismissed(message: InAppMessage)
    func errorWithMessage(message: InAppMessage)
    func messageActionTaken(message: InAppMessage, actionValue: String, actionName: String)
}
