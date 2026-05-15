import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupAppearance()
    }
    
    
    private func setupTabs() {
        let homeNav = createNav(
            title: "Trang chủ",
            image: "house",
            selectedImage: "house.fill",
            root: HomeViewController()
        )
        let questionNav = createNav(
            title: "Kho câu hỏi",
            image: "folder.fill.badge.questionmark",
            selectedImage: "folder.fill.badge.questionmark",
            root: QuestionBankViewController()
        )
        let examNav = createNav(
            title: "Đề thi",
            image: "checkmark.rectangle.stack.fill",
            selectedImage: "checkmark.rectangle.stack.fill",
            root: ExamViewController()
        )
        let historyNav = createNav(
            title: "Lịch sử",
            image: "clock.arrow.trianglehead.counterclockwise.rotate.90",
            selectedImage: "clock.arrow.trianglehead.counterclockwise.rotate.90",
            root: ExamHistoryViewController()
        )
        let profileNav = createNav(
            title: "Tài khoản",
            image: "person",
            selectedImage: "person.fill",
            root: ProfileViewController()
        )

        viewControllers = [homeNav, questionNav, examNav, historyNav, profileNav]
        selectedIndex = 0
    }
    

    private func createNav(
        title: String,
        image: String,
        selectedImage: String,
        root: UIViewController
    ) -> UINavigationController {
        let nav = UINavigationController(rootViewController: root)
        nav.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: image),
            selectedImage: UIImage(systemName: selectedImage)
        )
        return nav
    }

    private func setupAppearance() {
        BeeTheme.applyNavigationAppearance()

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = BeeTheme.card

        appearance.stackedLayoutAppearance.selected.iconColor = BeeTheme.amber
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: BeeTheme.amber
        ]

        appearance.stackedLayoutAppearance.normal.iconColor = BeeTheme.muted
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: BeeTheme.muted
        ]

        tabBar.standardAppearance = appearance

        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}
