import UIKit
import CoreData // Add this for Core Data

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions
                     launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let settings = UserDefaults.standard

        if settings.string(forKey: Constants.kSortField) == nil {
            settings.set("city", forKey: Constants.kSortField)
        }
        if settings.string(forKey: Constants.kSortDirectionAscending) == nil {
            settings.set(true, forKey: Constants.kSortDirectionAscending)
        }

        settings.synchronize()
        NSLog("Sort field: %@", settings.string(forKey: Constants.kSortField)!)
        NSLog("Sort direction: \(settings.bool(forKey: Constants.kSortDirectionAscending))")

        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "MyContactListModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this with proper error handling in production
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("Core Data saveContext() succeeded")
            } catch {
                let nserror = error as NSError
                print("Core Data saveContext() failed: \(nserror), \(nserror.userInfo)")
            }
        } else {
            print("⚠️ Nothing to save: context has no changes")
        }
    }

    }

