import Foundation

public protocol SDKSetupChecklist: AutoMockable {
    func noStepsCompleteDeepLinks()
    func completedDeepLinkStep(_ step: SDKSetupDeepLinkStep, deepLink: URL)
}

// sourcery: InjectRegister = "SDKSetupChecklist"
public class SDKSetupChecklistImpl: SDKSetupChecklist {
    private let logger: Logger

    public init(logger: Logger) {
        self.logger = logger
    }

    public func completedDeepLinkStep(_ step: SDKSetupDeepLinkStep, deepLink: URL) {
        logger.force(step.getLogMessageAfterStepCompleted(deepLink: deepLink))
    }

    public func noStepsCompleteDeepLinks() {
        let message = """
        Interested in opening a specific screen of your mobile app after a push notification is opened?
        Or, performing a specific action such as adding an item to a shopping cart after a push notification is opened?

        If so, setup the Deep Link feature!

        --------- Customer.io Deep Link Setup progress ---------
        \(SDKSetupDeepLinkStep.pushPayloadContainsDeepLinkURL.logMessageStepNotCompleted)
        \(SDKSetupDeepLinkStep.pushOpened.logMessageStepNotCompleted)
        \(SDKSetupDeepLinkStep.osOpenDeepLinkURL.logMessageStepNotCompleted)

        - TIP: Send a test rich push notification to your device from Customer.io: https://customer.io/docs/send-push/#test
        -------------------------------------------------------

        """

        logger.force(message)
    }
}

public enum SDKSetupDeepLinkStep {
    case pushPayloadContainsDeepLinkURL
    case pushOpened
    case osOpenDeepLinkURL

    func getLogMessageAfterStepCompleted(deepLink: URL) -> String {
        switch self {
        case .pushPayloadContainsDeepLinkURL:
            return"""

            --------- Customer.io Deep Link Setup progress ---------
            \(Self.pushPayloadContainsDeepLinkURL.getLogMessageStepCompleted(deepLink: deepLink))
            \(Self.pushOpened.logMessageStepNotCompleted)
            \(Self.osOpenDeepLinkURL.logMessageStepNotCompleted)

            - TIP: Send a test rich push notification to your device from Customer.io: https://customer.io/docs/send-push/#test
            -------------------------------------------------------

            """
        case .pushOpened:
            return """

            --------- Customer.io Deep Link Setup progress ---------
            \(Self.pushPayloadContainsDeepLinkURL.getLogMessageStepCompleted(deepLink: deepLink))
            \(Self.pushOpened.getLogMessageStepCompleted(deepLink: deepLink))
            \(Self.osOpenDeepLinkURL.logMessageStepNotCompleted)

            - TIP: Send a test rich push notification to your device from Customer.io: https://customer.io/docs/send-push/#test
            -------------------------------------------------------

            """
        case .osOpenDeepLinkURL:
            return """

            --------- Customer.io Deep Link Setup progress ---------
            \(Self.pushPayloadContainsDeepLinkURL.getLogMessageStepCompleted(deepLink: deepLink))
            \(Self.pushOpened.getLogMessageStepCompleted(deepLink: deepLink))
            \(Self.osOpenDeepLinkURL.getLogMessageStepCompleted(deepLink: deepLink))

            - TIP: Send a test rich push notification to your device from Customer.io: https://customer.io/docs/send-push/#test
            -------------------------------------------------------

            """
        }
    }

    func getLogMessageStepCompleted(deepLink: URL) -> String {
        switch self {
        case .pushPayloadContainsDeepLinkURL:
            return "✅ Push received from Customer.io that contains a Deep Link. The SDK will attempt to open this Deep Link URL when the push is opened: \(deepLink.absoluteString)"
        case .pushOpened:
            return "✅ Push notification was opened and was received by Customer.io SDK. The SDK will attempt to open Deep Link URL: \(deepLink.absoluteString)"
        case .osOpenDeepLinkURL:
            return "✅ The Customer.io SDK sent a request to the operating system to open the Deep Link URL. The Customer.io SDK has done all that it can at this point to get Deep Links to work. Make sure your app is configured to receive the deep link request from the OS. Deep Link URL: \(deepLink.absoluteString)"
        }
    }

    var logMessageStepNotCompleted: String {
        switch self {
        case .pushPayloadContainsDeepLinkURL:
            return """
            🔲 Setup your mobile app to receive a rich push and send it to the Customer.io SDK: https://customer.io/docs/sdk/ios/rich-push/#rich-push
            """
        case .pushOpened:
            return """
            🔲 After a push notification is opened, send the notification to the Customer.io SDK: https://customer.io/docs/sdk/ios/rich-push/#app-scheme-deep-links
            """
        case .osOpenDeepLinkURL:
            return """
            🔲 Setup your mobile app to open after a Deep Link is opened by the operating system: https://customer.io/docs/sdk/ios/rich-push/#app-scheme-deep-links
            """
        }
    }
}
