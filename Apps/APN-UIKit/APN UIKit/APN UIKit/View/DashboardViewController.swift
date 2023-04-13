import UIKit

class DashboardViewController: UIViewController {

    static func newInstance() -> DashboardViewController {
        UIStoryboard.getViewController(identifier: "DashboardViewController")
    }
    
    var dashboardRouter: DashboardRouting?
    
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showPushPermissionPrompt()
        configureDashboardRouter()
    }
    
    func showPushPermissionPrompt() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in })
    }
    func configureDashboardRouter() {
        let router = DashboardRouter()
        dashboardRouter = router
        router.dashboardViewController = self
    }
    
    // MARK: - Actions
    
    @IBAction func logoutUser(_ sender: UIButton) {
        dashboardRouter?.routeToLogin()
    }
    
    @IBAction func sendRandomEvent(_ sender: UIButton) {
        self.showInfoAlert(withMessage: "Random event tracked successfully")
    }
    
    @IBAction func sendCustomEvent(_ sender: UIButton) {
        dashboardRouter?.routeToCustomDataScreen(forSource: .customEvents)
    }
    
    @IBAction func setDeviceAttributes(_ sender: UIButton) {
        dashboardRouter?.routeToCustomDataScreen(forSource: .deviceAttributes)
    }
    
    @IBAction func setProfileAttributes(_ sender: UIButton) {
        dashboardRouter?.routeToCustomDataScreen(forSource: .profileAttributes)
    }
}
