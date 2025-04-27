// MARK: - 250425 UIViewController LifeCycle
/// https://medium.com/@vipandey54/uiviewcontroller-lifecycle-7ca2d36f4f07
/*
 . loadView()
 . loadViewIfNeeded()
 . viewDidLoad()
 . viewWillAppear(_ animated: Bool)
 . viewWillLayoutSubviews()
 . viewDidLayoutSubviews()
 . viewDidAppear(_ animated: Bool)
 . viewWillDisappear(_ animated: Bool)
 . viewDidDisappear(_ animated: Bool)
 */

// MARK: - Implementing a Container View Controller
/// https://developer.apple.com/library/archive/featuredarticles/ViewControllerPGforiPhoneOS/ImplementingaContainerViewController.html#//apple_ref/doc/uid/TP40007457-CH11-SW1

/// Listing 5-1Adding a child view controller to a container
- (void) displayContentController: (UIViewController*) content {
   [self addChildViewController:content];
   content.view.frame = [self frameForContentController];
   [self.view addSubview:self.currentClientView];
   [content didMoveToParentViewController:self];
}

/// Removing a child view controller from a container
- (void) hideContentController: (UIViewController*) content {
    [content willMoveToParentViewController:nil];
    [content.view removeFromSuperview];
    [content removeFromParentViewController];
}

// MARK: - 250422 UIKit integration
/// https://developer.apple.com/documentation/swiftui/uikit-integration
// Add UIKit views to your SwiftUI app, or use SwiftUI views in your UIKit app.

// SwiftUI Animation
struct ContentView: View {
    @State private var position = CGPoint(x: 200, y: 200)
    @State private var frame = CGSize(width: 100, height: 100)
    
    var body: some View {
        Rectangle()
            .fill(Color.blue)
            .frame(width: frame.width, height: frame.height)
            .position(position)
        Button("Animate") {
            // Use a spring animation to animate the view to a new location.
            let animation = Animation.spring(duration: 0.8)
            withAnimation(animation) {
                position = CGPoint(x: 100, y: 100)
            }
        }
    }
}

struct ContentView: View {
    @State private var color = Color.blue
    @State private var position = CGPoint(x: 200, y: 200)
    @State private var frame = CGSize(width: 100, height: 100)
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: frame.width, height: frame.height)
            .position(position)
        Button("Animate") {
            // Use a smooth spring animation to animate the view to a new location.
            withAnimation(.smooth) {
                position = CGPoint(x: 100, y: 100)
            } completion: {
                // When the animation completes, change the color of the view.
                color = Color.red
            }
        }
    }
}

struct ContentView: View {
    @State private var position = CGPoint(x: 200, y: 200)
    @State private var frame = CGSize(width: 100, height: 100)
    
    var body: some View {
        Rectangle()
            .fill(Color.blue)
            .frame(width: frame.width, height: frame.height)
            .position(position)
        Button("Animate") {
            Task {
                // Begin an animation to move the view to a new location.
                withAnimation(.spring(duration: 1.0)) {
                    position = .zero
                }
                
                try await Task.sleep(for: .seconds(0.5))


                // Retarget the running animation to move the view to a different location.
                withAnimation(.spring) {
                    position = CGPoint(x: 100, y: 400)
                }
            }
        }
    }
}

// MARK: - 250422 Accessibility fundamentals
/// https://developer.apple.com/documentation/swiftui/accessibility-fundamentals

@Namespace var accessibilityNamespace
// Use `accessibilityLabeledPair` to connect an element
// with its label, so VoiceOver knows about their relationship.
// This improves the experience on macOS. On iOS, it will combine
// the contents of the label.
HStack {
    Text("Custom Controls")
        .accessibilityLabeledPair(role: .label, id: "customControls", in: accessibilityNamespace)
    Button("Learn") {}
        .accessibilityLabeledPair(role: .content, id: "customControls", in: accessibilityNamespace)
}

// Use `accessibilityChildren` to create accessibility elements
// within the canvas, so that VoiceOver users can navigate inside
// it and read the information for every week.
// These accessibility elements aren't drawn on the
// screen. Instead, they're just a representation of the
// canvas for users of assistive technologies.
.accessibilityChildren {
    HStack {
        ForEach(lines.indices, id: \.self) { index in
            Rectangle()
                .accessibilityLabel("Week \(index + 1)")
                .accessibilityValue("\(lines[index]) lines")
        }
    }
}

// MARK: - 250422 System events
/// React to system events, like opening a URL.
/// https://developer.apple.com/documentation/swiftui/system-events

// WARNING: To support state preservation and restoration,
// --> this sample uses NSUserActivity objects. For each user activity, the app must supply an activity type defined in its Info.plist.

/*
 Specify view and scene modifiers to indicate how your app responds to certain system events.
 For example, you can use the onOpenURL(perform:) view modifier to define an action to take when your app receives a universal link,
 or use the backgroundTask(_:action:) scene modifier to specify an asynchronous task to carry out in response to a background task event,
 like the completion of a background URL session.
 */

// MARK: - Product _ ObservableObject
class Product: Hashable, Identifiable, Codable, ObservableObject {
    let id: UUID
    let imageName: String
    @Published var name: String
    @Published var year: Int
    @Published var price: Double
    
    init(identifier: UUID, name: String, imageName: String, year: Int, price: Double) {
        self.name = name
        self.imageName = imageName
        self.year = year
        self.price = price
        self.id = identifier
    }
    
    // Equatable
    static func == (lhs: Product, rhs: Product) -> Bool {
        lhs.id == rhs.id
    }

    // Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // Codable
    private enum CoderKeys: String, CodingKey {
        case name
        case imageName
        case year
        case price
        case identifier
    }

    // Used for persistent storing of products to disk.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CoderKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(imageName, forKey: .imageName)
        try container.encode(year, forKey: .year)
        try container.encode(price, forKey: .price)
        try container.encode(id, forKey: .identifier)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CoderKeys.self)
        name = try values.decode(String.self, forKey: .name)
        year = try values.decode(Int.self, forKey: .year)
        price = try values.decode(Double.self, forKey: .price)
        imageName = try values.decode(String.self, forKey: .imageName)
        id = try values.decode(UUID.self, forKey: .identifier)
    }
}

// MARK: - ProductsModel _ Restore App State
class ProductsModel: Codable, ObservableObject {
    @Published var products: [Product] = []
    
    private enum CodingKeys: String, CodingKey {
        case products
    }
    
    // The archived file name, name saved to Documents folder.
    private let dataFileName = "Products"
    
    init() {
        // Load the data model from the 'Products' data file found in the Documents directory.
        if let codedData = try? Data(contentsOf: dataModelURL()) {
            // Decode the json file into a DataModel object.
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([Product].self, from: codedData) {
                products = decoded
            }
        } else {
            // No data on disk, read the products from json file.
            products = Bundle.main.decode("products.json")
            save()
        }
    }
    
    // Codable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(products, forKey: .products)
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        products = try values.decode(Array.self, forKey: .products)
    }
    
    private func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    private func dataModelURL() -> URL {
        let docURL = documentsDirectory()
        return docURL.appendingPathComponent(dataFileName)
    }

    func save() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(products) {
            do {
                // Save the 'Products' data file to the Documents directory.
                try encoded.write(to: dataModelURL())
            } catch {
                print("Couldn't write to save file: " + error.localizedDescription)
            }
        }
    }
}

extension Bundle {
    func decode(_ file: String) -> [Product] {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }
        let decoder = JSONDecoder()
        guard let loaded = try? decoder.decode([Product].self, from: data) else {
            fatalError("Failed to decode \(file) from bundle.")
        }
        return loaded
    }
}

// MARK: - Content View _ onContinueUserActivity
struct ContentView: View {
    // The data model for storing all the products.
    @EnvironmentObject var productsModel: ProductsModel
    
    // Used for detecting when this scene is backgrounded and isn't currently visible.
    @Environment(\.scenePhase) private var scenePhase

    // The currently selected product, if any.
    @SceneStorage("ContentView.selectedProduct") private var selectedProduct: String?
    
    let columns = Array(repeating: GridItem(.adaptive(minimum: 94, maximum: 120)), count: 3)
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(productsModel.products) { product in
                        NavigationLink(destination: DetailView(product: product, selectedProductID: $selectedProduct),
                                       tag: product.id.uuidString,
                                       selection: $selectedProduct) {
                            StackItemView(itemName: product.name, imageName: product.imageName)
                        }
                        .padding(8)
                        .buttonStyle(PlainButtonStyle())
                        .onDrag {
                            /** Register the product user activity as part of the drag provider which
                                will  create a new scene when dropped to the left or right of the iPad screen.
                            */
                            let userActivity = NSUserActivity(activityType: DetailView.productUserActivityType)
                            
                            let localizedString = NSLocalizedString("DroppedProductTitle", comment: "Activity title with product name")
                            userActivity.title = String(format: localizedString, product.name)
                            
                            userActivity.targetContentIdentifier = product.id.uuidString
                            try? userActivity.setTypedPayload(product)
                            
                            return NSItemProvider(object: userActivity)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("ProductsTitle")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onContinueUserActivity(DetailView.productUserActivityType) { userActivity in
            if let product = try? userActivity.typedPayload(Product.self) {
                selectedProduct = product.id.uuidString
            }
        }
        .onChange(of: scenePhase) { newScenePhase in
            if newScenePhase == .background {
                // Make sure to save any unsaved changes to the products model.
                productsModel.save()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(ProductsModel())
    }
}

// The view used to describe each product in the LazyVGrid.
struct StackItemView: View {
    var itemName: String
    var imageName: String
    var body: some View {
        VStack {
            Image(imageName)
                .resizable()
                .font(.title)
                .scaledToFit()
                .cornerRadius(8.0)
            Text("\(itemName)")
                .font(.caption)
        }
    }
}

// MARK: - DetailView _ userActivity
struct DetailView: View {
    // The user activity type representing this view.
    static let productUserActivityType = "com.example.apple-samplecode.staterestore.product"
    
    @ObservedObject var product: Product
    @Binding var selectedProductID: String?
    
    enum Tabs: String {
        case detail
        case photo
    }
    // State restoration: the selected tab in TabView.
    @SceneStorage("DetailView.selectedTab") private var selectedTab = Tabs.detail
    // State restoration: the presentation state for the EditView.
    @SceneStorage("DetailView.showEditView") private var showEditView = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            InfoTabView(product: product)
            .tabItem {
                Label("DetailTitle", systemImage: "info.circle")
            }
            .tag(Tabs.detail)
            
            Image(product.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .border(Color("borderColor"), width: 1.0)
                .padding()
            .tabItem {
                Label("PhotoTitle", systemImage: "photo")
            }
            .tag(Tabs.photo)
        }
        .sheet(isPresented: $showEditView) {
            EditView(product: product)
        }
        .toolbar {
            ToolbarItem {
                Button("EditTitle", action: { showEditView.toggle() })
            }
        }
        // The described activity for this view.
        .userActivity(
            DetailView.productUserActivityType,
            isActive: product.id.uuidString == selectedProductID
        ) { userActivity in
            describeUserActivity(userActivity)
        }
        .navigationTitle(product.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func describeUserActivity(_ userActivity: NSUserActivity) {
        let returnProduct: Product! // Will be set to existing from activity, or new instance.
        if let activityProduct = try? userActivity.typedPayload(Product.self) {
            /** Use product in the activity.
                Make sure advertised Product contains name/id that we are advertising from the current Product.
            */
            returnProduct = Product(identifier: product.id,
                                    name: product.name,
                                    imageName: activityProduct.imageName,
                                    year: activityProduct.year,
                                    price: activityProduct.price
            )
        } else {
            returnProduct = product // No product in activity, so start with existing.
        }

        let localizedString =
            NSLocalizedString("ShowProductTitle", comment: "Activity title with product name")
        userActivity.title = String(format: localizedString, product.name)
        
        userActivity.isEligibleForHandoff = true
        userActivity.isEligibleForSearch = true
        userActivity.targetContentIdentifier = returnProduct.id.uuidString
        try? userActivity.setTypedPayload(returnProduct)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        let product = Product(
            identifier: UUID(uuidString: "fa542e3d-4895-44b6-942f-e112101d5160")!,
            name: "Cherries",
            imageName: "Cherries",
            year: 2015,
            price: 10.99)
        DetailView(product: product, selectedProductID: .constant(nil))
    }
}

// MARK: - EditView _ SceneStorage
struct EditView: View {
    // The data model for storing all the products.
    @EnvironmentObject var productsViewModel: ProductsModel
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var product: Product

    // Whether to use product or saved values.
    @SceneStorage("EditView.useSavedValues") var useSavedValues = true
    
    // Restoration values for the edit fields.
    @SceneStorage("EditView.editTitle") var editName: String = ""
    @SceneStorage("EditView.editYear") var editYear: String = ""
    @SceneStorage("EditView.editPrice") var editPrice: String = ""
    
    // Use different width and height for info view between compact and non-compact size classes.
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var imageWidth: CGFloat {
        horizontalSizeClass == .compact ? 100 : 280
    }
    var imageHeight: CGFloat {
        horizontalSizeClass == .compact ? 80 : 260
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("")) {
                    HStack {
                        Spacer()
                        Image(product.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: imageWidth, height: imageHeight)
                            .clipped()
                        Spacer()
                    }
                }

                Section(header: Text("NameTitle")) {
                    TextField("AccessibilityNameField", text: $editName)
                }
                Section(header: Text("YearTitle")) {
                    TextField("AccessibilityYearField", text: $editYear)
                        .keyboardType(.numberPad)
                }
                Section(header: Text("PriceTitle")) {
                    TextField("AccessibilityPriceField", text: $editPrice)
                        .keyboardType(.decimalPad)
                }
            }

            .navigationBarTitle(Text("EditProductTitle"), displayMode: .inline)
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("CancelTitle", action: cancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("DoneTitle", action: done)
                        .disabled(editName.isEmpty)
                }
            }
        }
        
        .onAppear {
            // Decide whether or not to use the scene storage for restoration.
            if useSavedValues {
                editName = product.name
                editYear = String(product.year)
                editPrice = String(product.price)
                useSavedValues = false // Until we're dismissed, use sceneStorage values
            }
        }
    }

    func cancel() {
        dismiss()
    }
    
    func done() {
        save()
        dismiss()
    }
    
    func dismiss() {
        useSavedValues = true
        self.presentationMode.wrappedValue.dismiss()
    }

    // User tapped the Done button to commit the product edit.
    func save() {
        product.name = editName
        product.year = Int(editYear)!
        product.price = Double(editPrice)!
        productsViewModel.save()
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        let product = Product(
            identifier: UUID(uuidString: "fa542e3d-4895-44b6-942f-e112101d5160")!,
            name: "Cherries",
            imageName: "Cherries",
            year: 2015,
            price: 10.99)
        EditView(product: product)
    }
}

// MARK: - onLoad
extension View {
    func onLoad(perform action: @escaping @Sendable () async -> Void) -> some View {
        modifier(ViewDidLoadModifier(action: action))
    }
}

struct ViewDidLoadModifier: ViewModifier {
    @State private var didLoad = false
    let action: @Sendable () async -> Void
    func body(content: Content) -> some View {
        content
            .task { @MainActor in
                guard didLoad == false else {
                    return
                }
                didLoad = true
                await action()
            }
    }
}




// MARK: - Preview Modifier
// Adopt `PreviewModifier`
struct CachedPreviewData: PreviewModifier {

    static func makeSharedContext() async throws -> DAO {
        let dao = DAO()
        await dao.makeSomeOtherNetworkCalls()
        await dao.noSeriouslyGoCrazyWithIt()

        // Because we're only doing this once...
        return dao
    }

    // And now it's reused
    func body(content: Content, context: DAO) -> some View {
        content
            .environment(context)
    }
}

// Add the modifier to the preview.
#Preview(traits: .modifier(CachedPreviewData())) {
    // Now this, or any other preview using the same setup
    // Has access to `DAO`, and it only ran `init()` once
    MyViewHierarchy()
}

// LX
private struct LXBackgroundPreview: PreviewModifier {
    func body(content: Content, context: Void) -> some View {
        content
            .background(.green)
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    static var lxBackground: Self {
        modifier(LXBackgroundPreview())
    }
}

#Preview(traits: .lxBackground) {
    A250419TapGestureSandBox()
}

// MARK: - openURL
/// https://developer.apple.com/documentation/swiftui/environmentvalues/openurl
/*
 Read this environment value to get an OpenURLAction instance for a given Environment. Call the instance to open a URL. You call the instance directly because it defines a callAsFunction(_:) method that Swift calls when you call the instance.

 For example, you can open a web site when the user taps a button:
 */
struct OpenURLExample: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        Button {
            if let url = URL(string: "https://www.example.com") {
                openURL(url)
            }
        } label: {
            Label("Get Help", systemImage: "person.fill.questionmark")
        }
    }
}

/*
 If you want to know whether the action succeeds, add a completion handler that takes a Boolean value. In this case, Swift implicitly calls the callAsFunction(_:completion:) method instead. That method calls your completion handler after it determines whether it can open the URL, but possibly before it finishes opening the URL. You can add a handler to the example above so that it prints the outcome to the console:
 */
openURL(url) { accepted in
    print(accepted ? "Success" : "Failure")
}

/*
 You can also set a custom action using the environment(_:_:) view modifier. Any views that read the action from the environment, including the built-in Link view and Text views with markdown links, or links in attributed strings, use your action. Initialize an action by calling the init(handler:) initializer with a handler that takes a URL and returns an OpenURLAction.Result:
 */
Text("Visit [Example Company](https://www.example.com) for details.")
    .environment(\.openURL, OpenURLAction { url in
        handleURL(url) // Define this method to take appropriate action.
        return .handled
    })

// MARK: - handlesExternalEvents(matching:)
/// Specifies the external events for which SwiftUI opens a new instance of the modified scene.
nonisolated
func handlesExternalEvents(matching conditions: Set<String>) -> some Scene

/*
 conditions
    --> A set of strings that SwiftUI compares against the incoming user activity or URL to see if SwiftUI can open a new scene instance to handle the external event.
 */

// Matching an event
/// --> For an NSUserActivity, like when your app handles Handoff, SwiftUI uses the activity’s targetContentIdentifier property, or if that’s nil, its webpageURL property rendered as an absoluteString.
/// --> For a URL, like when another process opens a URL that your app handles, SwiftUI uses the URL’s absoluteString.
@main
struct MyPhotos: App {
    var body: some Scene {
        WindowGroup {
            PhotosBrowser()
        }


        WindowGroup("Photo") {
            PhotoDetail()
        }
        .handlesExternalEvents(matching: ["photoIdentifier="])
    }
}


private struct ContactList: View {
    var store: ContactStore
    @State private var selectedContact: UUID?

    var body: some View {
        NavigationSplitView {
            List(store.contacts, selection: $selectedContact) { contact in
                NavigationLink(contact.name) {
                    Text(contact.name)
                }
            }
        } detail: {
            Text("Select a contact")
        }
        .handlesExternalEvents(
            preferring: selectedContact == nil
                ? []
                : [selectedContact!.uuidString],
            allowing: selectedContact == nil
                ? ["*"]
                : []
        )
        .onContinueUserActivity(Contact.userActivityType) { activity in
            if let identifier = activity.targetContentIdentifier {
                selectedContact = UUID(uuidString: identifier)
            }
        }
        .userActivity(
            Contact.userActivityType,
            isActive: selectedContact != nil
        ) { activity in
            activity.title = "Contact"
            activity.targetContentIdentifier = selectedContact?.uuidString
            activity.isEligibleForHandoff = true
        }
    }
}

// MARK: - BackgroundTask _ AppDelegate
//import UIKit
//import BackgroundTasks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private let server: Server = MockServer()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let feedVC = (window?.rootViewController as? UINavigationController)?.viewControllers.first as? FeedTableViewController
        feedVC?.server = server
        
        PersistentContainer.shared.loadInitialData()
        
        // Registering Launch Handlers for Tasks
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.example.apple-samplecode.ColorFeed.refresh", using: nil) { task in
            // Downcast the parameter to an app refresh task as this identifier is used for a refresh request.
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.example.apple-samplecode.ColorFeed.db_cleaning", using: nil) { task in
            // Downcast the parameter to a processing task as this identifier is used for a processing request.
            self.handleDatabaseCleaning(task: task as! BGProcessingTask)
        }

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleAppRefresh()
        scheduleDatabaseCleaningIfNeeded()
    }
    
    // Scheduling Tasks
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.example.apple-samplecode.ColorFeed.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // Fetch no earlier than 15 minutes from now
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    func scheduleDatabaseCleaningIfNeeded() {
        let lastCleanDate = PersistentContainer.shared.lastCleaned ?? .distantPast

        let now = Date()
        let oneWeek = TimeInterval(7 * 24 * 60 * 60)

        // Clean the database at most once per week.
        guard now > (lastCleanDate + oneWeek) else { return }
        
        let request = BGProcessingTaskRequest(identifier: "com.example.apple-samplecode.ColorFeed.db_cleaning")
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = true
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule database cleaning: \(error)")
        }
    }
    
    // Handling Launch for Tasks
    // Fetch the latest feed entries from server.
    func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        let context = PersistentContainer.shared.newBackgroundContext()
        let operations = Operations.getOperationsToFetchLatestEntries(using: context, server: server)
        let lastOperation = operations.last!
        
        task.expirationHandler = {
            // After all operations are cancelled, the completion block below is called to set the task to complete.
            queue.cancelAllOperations()
        }

        lastOperation.completionBlock = {
            task.setTaskCompleted(success: !lastOperation.isCancelled)
        }

        queue.addOperations(operations, waitUntilFinished: false)
    }
    
    // Delete feed entries older than one day.
    func handleDatabaseCleaning(task: BGProcessingTask) {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1

        let context = PersistentContainer.shared.newBackgroundContext()
        let predicate = NSPredicate(format: "timestamp < %@", NSDate(timeIntervalSinceNow: -24 * 60 * 60))
        let cleanDatabaseOperation = DeleteFeedEntriesOperation(context: context, predicate: predicate)
        
        task.expirationHandler = {
            // After all operations are cancelled, the completion block below is called to set the task to complete.
            queue.cancelAllOperations()
        }

        cleanDatabaseOperation.completionBlock = {
            let success = !cleanDatabaseOperation.isCancelled
            if success {
                // Update the last clean date to the current time.
                PersistentContainer.shared.lastCleaned = Date()
            }
            
            task.setTaskCompleted(success: success)
        }
        
        queue.addOperation(cleanDatabaseOperation)
    }
}


// MARK: - backgroundTask(_:action:)
nonisolated
func backgroundTask<D, R>(
    _ task: BackgroundTask<D, R>,
    action: @escaping (D) async -> R
) -> some Scene where D : Sendable, R : Sendable

/// An example of a Weather Application.
struct WeatherApp: App {
    var body: some Scene {
        WindowGroup {
            Text("Responds to App Refresh")
        }
        .backgroundTask(.appRefresh("WEATHER_DATA")) {
            await updateWeatherData()
        }
    }
    func updateWeatherData() async {
        // fetches new weather data and updates app state
    }
}

// https://developer.apple.com/documentation/backgroundtasks/bgtaskscheduler/submit(_:)
/*
 There can be a total of 1 refresh task and 10 processing tasks scheduled at any time. Trying to schedule more tasks returns BGTaskScheduler.Error.Code.tooManyPendingTaskRequests.
 */

/// https://holyswift.app/new-backgroundtask-in-swiftui-and-how-to-test-it/?utm_source=chatgpt.com
/*
 --> Set up your project to receive background tasks.
 --> Make your code schedule and respond to that tasks.
 */

//import SwiftUI
//import BackgroundTasks

class ImageStore: ObservableObject {
    @Published var randomImage: UIImage?
}

struct ContentView: View {
    @ObservedObject var imageStore: ImageStore
    
    var body: some View {
        VStack {
            Button("Local Message Autorization") {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        print("All set!")
                        
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }.buttonStyle(.borderedProminent)
                .padding()
            
            Button("Schedule Background Task") {
                let request = BGAppRefreshTaskRequest(identifier: "randomImage") // Mark 1
                request.earliestBeginDate = Calendar.current.date(byAdding: .second, value: 30, to: Date()) // Mark 2
                do {
                    try BGTaskScheduler.shared.submit(request) // Mark 3
                    print("Background Task Scheduled!")
                } catch(let error) {
                    print("Scheduling Error \(error.localizedDescription)")
                }
                
            }.buttonStyle(.bordered)
                .tint(.red)
                .padding()
            
        }
    }
}

//import SwiftUI
//import BackgroundTasks

@main
struct BackgroundTaskExampleApp: App {
    @StateObject var imageStore = ImageStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView(imageStore: imageStore)
        }
        .backgroundTask(.appRefresh("randomImage")) { // Mark 1 This is where you respond the scheduled background task
            // you can also reschedule the background task HERE if you want to keep calling from time to time, just send BGTaskScheduler.shared.submit(request) here again and again.
            await refreshAppData() // use an async function here
        }
    }
    
    func refreshAppData() async { // this is the functio that will respond your scheduled background task
        let content = UNMutableNotificationContent()
        content.title = "A Random Photo is awaiting for you!"
        content.subtitle = "Check it now!"
        
        if await fetchRandomImage() {
            try? await UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: "test", content: content, trigger: UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)))
        }
    }
    
    func fetchRandomImage() async -> Bool { // async random fetch image
        guard let url = URL(string: "https://picsum.photos/200/300"),
              let (data, response) = try? await URLSession.shared.data(from: url),
              let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            return false
        }
        
        imageStore.randomImage = UIImage(data: data)
        
        return true
    }
}

// MARK: - 250422 NavigationStack Animation
/// https://developer.apple.com/documentation/swiftui/view/matchedtransitionsource(id:in:configuration:)
/// The appearance of the source can be configured using the configuration trailing closure. Any modifiers applied will be smoothly interpolated when a zoom transition originates from this matched transition source.
MyView()
    .matchedTransitionSource(id: someID, in: someNamespace) { source in
        source
            .cornerRadius(8.0)
    }

/// https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-zoom-animations-between-views
struct Icon: Identifiable {
    var id: String
    var color: Color
}

struct ContentView: View {
    let icons = [
        Icon(id: "figure.badminton", color: .red),
        Icon(id: "figure.fencing", color: .orange),
        Icon(id: "figure.gymnastics", color: .green),
        Icon(id: "figure.indoor.cycle", color: .blue),
        Icon(id: "figure.outdoor.cycle", color: .purple),
        Icon(id: "figure.rower", color: .indigo),
    ]

    @Namespace var animation
    @State private var selected: Icon?

    var body: some View {
        LazyVGrid(columns: [.init(.adaptive(minimum: 100, maximum: 300))]) {
            ForEach(icons) { icon in
                Button {
                    selected = icon
                } label: {
                    Image(systemName: icon.id)
                }
                .foregroundStyle(icon.color.gradient)
                .font(.system(size: 100))
                .matchedTransitionSource(id: icon.id, in: animation)
            }
        }
        .sheet(item: $selected) { icon in
            Image(systemName: icon.id)
                .font(.system(size: 300))
                .foregroundStyle(icon.color.gradient)
                .navigationTransition(.zoom(sourceID: icon.id, in: animation))
        }
    }
}

// MARK: - 250419 Focus
/// Identify and control which visible object responds to user interaction.
/// https://developer.apple.com/documentation/swiftui/focus

// MARK: - Data Model _ Focus Sample Project
//import SwiftUI
//import Observation

@Observable final class DataModel {
    private var recipes: [Recipe] = []
    private var recipesByID: [Recipe.ID: Recipe]? = nil

    static let shared: DataModel = DataModel()

    private init() {
        recipes = builtInRecipes
    }

    func recipes(in category: Category?) -> [Recipe] {
        recipes
            .filter { $0.category == category }
            .sorted { $0.name < $1.name }
    }

    func recipes(relatedTo recipe: Recipe) -> [Recipe] {
        recipes
            .filter { recipe.related.contains($0.id) }
            .sorted { $0.name < $1.name }
    }

    subscript(recipeID: Recipe.ID?) -> Recipe? {
        guard let recipeID else { return nil }
        if recipesByID == nil {
            recipesByID = Dictionary(
                uniqueKeysWithValues: recipes.map { ($0.id, $0) })
        }
        return recipesByID![recipeID]
    }

    var recipeOfTheDay: Recipe {
        recipes[0]
    }
}

private let builtInRecipes: [Recipe] = {
    var recipes = [
        "Apple Pie": Recipe(
            name: "Apple Pie", category: .dessert,
            ingredients: applePie.ingredients
        ),
        // ...
        "Niçoise": Recipe(
            name: "Niçoise", category: .salad,
            ingredients: [])
    ]

    recipes["Apple Pie"]!.related = [
        recipes["Pie Crust"]!.id,
        recipes["Fruit Pie Filling"]!.id
    ]

    recipes["Pie Crust"]!.related = [recipes["Fruit Pie Filling"]!.id]
    recipes["Fruit Pie Filling"]!.related = [recipes["Pie Crust"]!.id]

    return Array(recipes.values)
}()

let applePie = """
    ¾ cup white sugar
    2 Tbsp. all-purpose flour
    ½ tsp. ground cinnamon
    ¼ tsp. ground nutmeg
    ½ tsp. lemon zest
    7 cups thinly sliced apples
    2 tsp. lemon juice
    1 Tbsp. butter
    1 recipe pastry for a 9-inch double-crust pie
    4 Tbsp. milk
    """

let pieCrust = """
    2 ½ cups all-purpose flour
    1 Tbsp. powdered sugar
    1 tsp. sea salt
    ½ cup shortening
    ½ cup butter (cold, cut into small pieces)
    ⅓ cup cold water (plus more as needed)
    """

extension String {
    var ingredients: [Ingredient] {
        split(separator: "\n", omittingEmptySubsequences: true)
            .map { Ingredient(description: String($0)) }
    }
}

// MARK: - NavigationSplitView _ RecipeNavigationView
struct RecipeNavigationView: View {
    @Bindable var navigationModel: NavigationModel
    @Binding var showGroceryList: Bool
    var categories = Category.allCases
    var dataModel = DataModel.shared

    @State private var selectedRecipe: Recipe.ID?

    var body: some View {
        NavigationSplitView {
            List(categories, selection: $navigationModel.selectedCategory) { category in
                NavigationLink(category.localizedName, value: category)
            }
            .navigationTitle("Categories")
            #if os(iOS)
            .toolbar {
                GroceryListButton(isActive: $showGroceryList)
            }
            #endif
        } detail: {
            NavigationStack(path: $navigationModel.recipePath) {
                RecipeGrid(category: navigationModel.selectedCategory, selection: $selectedRecipe)
            }
        }
    }
}

// MARK: - FocusState Change _ GroceryListView
struct GroceryListView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var list: GroceryList
    @FocusState private var currentItemID: GroceryList.Item.ID?

    var body: some View {
        List($list.items) { $item in
            HStack {
                Toggle("Obtained", isOn: $item.isObtained)
                TextField("Item Name", text: $item.name)
                    .onSubmit { addEmptyItem() }
                    .focused($currentItemID, equals: item.id)
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                doneButton
            }
            ToolbarItem(placement: .primaryAction) {
                newItemButton
            }
        }
        .defaultFocus($currentItemID, list.items.last?.id)
    }

    // MARK: New item
    private func addEmptyItem() {
        let newItem = list.addItem()
        currentItemID = newItem.id
    }

    private var newItemButton: some View {
        Button {
            addEmptyItem()
        } label: {
            Label("New Item", systemImage: "plus")
        }
    }

    private var doneButton: some View {
        Button {
            dismiss()
        } label: {
            Text("Done")
        }
    }
}

/// The main content view for the Grocery List sheet.
struct GroceryListContentView: View {
    @Binding var list: GroceryList

    var body: some View {
        NavigationStack {
            GroceryListView(list: $list)
                .toggleStyle(.checklist)
                .navigationTitle("Grocery List")
                #if os(macOS)
                .frame(minWidth: 500, minHeight: 400)
                #endif
        }
    }
}

// GroceryList
struct GroceryList: Codable {
    struct Item: Codable, Hashable, Identifiable {
        var id = UUID()
        var name: String
        var isObtained: Bool = false
    }

    var items: [Item] = []

    mutating func addItem() -> Item {
        let item = GroceryList.Item(name: "")
        items.append(item)
        return item
    }
}

extension GroceryList {
    static var sample = GroceryList(items: [
        GroceryList.Item(name: "Apples"),
        GroceryList.Item(name: "Lasagna"),
        GroceryList.Item(name: "")
    ])
}

// MARK: - Focusable _ RecipeGrid
// import SwiftUI

struct RecipeGrid: View {
    var dataModel = DataModel.shared

    /// The category of recipes to display.
    let category: Category?

    /// The recipes of the category.
    private var recipes: [Recipe] {
        dataModel.recipes(in: category)
    }

    /// A `Binding` to the identifier of the selected recipe.
    @Binding var selection: Recipe.ID?
    
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(NavigationModel.self) private var navigationModel

    /// The currently-selected recipe.
    private var selectedRecipe: Recipe? {
        dataModel[selection]
    }

    private func gridItem(for recipe: Recipe) -> some View {
        RecipeTile(recipe: recipe, isSelected: selection == recipe.id)
            .id(recipe.id)
            .padding(Self.spacing)
            #if os(macOS)
            .onTapGesture {
                selection = recipe.id
            }
            .simultaneousGesture(TapGesture(count: 2).onEnded {
                navigationModel.selectedRecipeID = recipe.id
            })
            #else
            .onTapGesture {
                navigationModel.selectedRecipeID = recipe.id
            }
            #endif
    }

    var body: some View {
        if let category = category {
            container { geometryProxy, scrollViewProxy in
                LazyVGrid(columns: columns) {
                    ForEach(recipes) { recipe in
                        gridItem(for: recipe)
                    }
                }
                .padding(Self.spacing)
                .focusable()
                .focusEffectDisabled()
                .focusedValue(\.selectedRecipe, selectedRecipe)
                #if os(macOS)
                .onMoveCommand { direction in
                    return selectRecipe(
                        in: direction,
                        layoutDirection: layoutDirection,
                        geometryProxy: geometryProxy,
                        scrollViewProxy: scrollViewProxy)
                }
                #endif
                .onKeyPress(.return, action: {
                    if let recipe = selectedRecipe {
                        navigate(to: recipe)
                        return .handled
                    } else {
                        return .ignored
                    }
                })
                .onKeyPress(.escape) {
                    selection = nil
                    return .handled
                }
                .onKeyPress(characters: .alphanumerics, phases: .down) { keyPress in
                    selectRecipe(
                        matching: keyPress.characters,
                        scrollViewProxy: scrollViewProxy)
                }
            }
            .navigationTitle(category.localizedName)
            .navigationDestination(for: Recipe.ID.self) { recipeID in
                if let recipe = dataModel[recipeID] {
                    RecipeDetail(recipe: recipe) { relatedRecipe in
                        RelatedRecipeLink(recipe: relatedRecipe)
                    }
                }
            }
        } else {
            ContentUnavailableView("Choose a category", systemImage: "fork.knife")
                .navigationTitle("")
        }
    }

    private func container<Content: View>(
        @ViewBuilder content: @escaping (
            _ geometryProxy: GeometryProxy, _ scrollViewProxy: ScrollViewProxy) -> Content
    ) -> some View {
        GeometryReader { geometryProxy in
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    content(geometryProxy, scrollViewProxy)
                }
            }
        }
    }

    // MARK: Keyboard selection

    private func navigate(to recipe: Recipe) {
        navigationModel.selectedRecipeID = recipe.id
    }

    #if os(macOS)
    private func selectRecipe(
        in direction: MoveCommandDirection,
        layoutDirection: LayoutDirection,
        geometryProxy: GeometryProxy,
        scrollViewProxy: ScrollViewProxy
    ) {
        let direction = direction.transform(from: layoutDirection)
        let rowWidth = geometryProxy.size.width - RecipeGrid.spacing * 2
        let recipesPerRow = Int(floor(rowWidth / RecipeTile.size))

        var newIndex: Int
        if let currentIndex = recipes.firstIndex(where: { $0.id == selection }) {
            switch direction {
            case .left:
                if currentIndex % recipesPerRow == 0 { return }
                newIndex = currentIndex - 1
            case .right:
                if currentIndex % recipesPerRow == recipesPerRow - 1 { return }
                newIndex = currentIndex + 1
            case .up:
                newIndex = currentIndex - recipesPerRow
            case .down:
                newIndex = currentIndex + recipesPerRow
            @unknown default:
                return
            }
        } else {
            newIndex = 0
        }

        if newIndex >= 0 && newIndex < recipes.count {
            selection = recipes[newIndex].id
            scrollViewProxy.scrollTo(selection)
        }
    }
    #endif

    private func selectRecipe(
        matching characters: String,
        scrollViewProxy: ScrollViewProxy
    ) -> KeyPress.Result {
        if let matchedRecipe = recipes.first(where: { recipe in
            recipe.name.lowercased().starts(with: characters)
        }) {
            selection = matchedRecipe.id
            scrollViewProxy.scrollTo(selection)
            return .handled
        }
        return .ignored
    }

    // MARK: Grid layout

    private static let spacing: CGFloat = 10

    private var columns: [GridItem] {
        [ GridItem(.adaptive(minimum: RecipeTile.size), spacing: 0) ]
    }
}

#if os(macOS)
extension MoveCommandDirection {
    /// Flip direction for right-to-left language environments.
    /// Learn more: https://developer.apple.com/design/human-interface-guidelines/right-to-left
    func transform(from layoutDirection: LayoutDirection) -> MoveCommandDirection {
        if layoutDirection == .rightToLeft {
            switch self {
            case .left:     return .right
            case .right:    return .left
            default:        break
            }
        }
        return self
    }
}
#endif


// MARK: - focused(_:equals:)
// Modifies this view by binding its focus state to the given state value.
/// https://developer.apple.com/documentation/swiftui/view/focused(_:equals:)

/*
 Use this modifier to cause the view to receive focus whenever the the binding equals the value. Typically, you create an enumeration of fields that may receive focus, bind an instance of this enumeration, and assign its cases to focusable views.

 The following example uses the cases of a LoginForm enumeration to bind the focus state of two TextField views. A sign-in button validates the fields and sets the bound focusedField value to any field that requires the user to correct a problem.
 */

struct LoginForm {
    enum Field: Hashable {
        case usernameField
        case passwordField
    }

    @State private var username = ""
    @State private var password = ""
    @FocusState private var focusedField: Field?

    var body: some View {
        Form {
            TextField("Username", text: $username)
                .focused($focusedField, equals: .usernameField)


            SecureField("Password", text: $password)
                .focused($focusedField, equals: .passwordField)


            Button("Sign In") {
                if username.isEmpty {
                    focusedField = .usernameField
                } else if password.isEmpty {
                    focusedField = .passwordField
                } else {
                    handleLogin(username, password)
                }
            }
        }
    }
}


/// binds to Bool
@State private var username: String = ""
@FocusState private var usernameFieldIsFocused: Bool
@State private var showUsernameTaken = false

var body: some View {
    VStack {
        TextField("Choose a username.", text: $username)
            .focused($usernameFieldIsFocused)
        if showUsernameTaken {
            Text("That username is taken. Please choose another.")
        }
        Button("Submit") {
            showUsernameTaken = false
            if !isUserNameAvailable(username: username) {
                usernameFieldIsFocused = true
                showUsernameTaken = true
            }
        }
    }
}

// MARK: - FocusState
struct LoginForm {
    enum Field: Hashable {
        case username
        case password
    }

    @State private var username = ""
    @State private var password = ""
    @FocusState private var focusedField: Field?

    var body: some View {
        Form {
            TextField("Username", text: $username)
                .focused($focusedField, equals: .username)

            SecureField("Password", text: $password)
                .focused($focusedField, equals: .password)

            Button("Sign In") {
                if username.isEmpty {
                    focusedField = .username
                } else if password.isEmpty {
                    focusedField = .password
                } else {
                    handleLogin(username, password)
                }
            }
        }
    }
}

// projectedValue
/// When focus is outside any view that is bound to this state, the wrapped value is nil for optional-typed state or false for Boolean state.
struct Sidebar: View {
    @State private var filterText = ""
    @FocusState private var isFiltering: Bool

    var body: some View {
        VStack {
            Button("Filter Sidebar Contents") {
                isFiltering = true
            }


            TextField("Filter", text: $filterText)
                .focused($isFiltering)
        }
    }
}

// MARK: - Entry()
// Environment Values
extension EnvironmentValues {
    @Entry var myCustomValue: String = "Default value"
    @Entry var anotherCustomValue = true
}

// Transaction Values
extension Transaction {
    @Entry var myCustomValue: String = "Default value"
}

// Container Values
extension ContainerValues {
    @Entry var myCustomValue: String = "Default value"
}

// Focused Values
/// Since the default value for FocusedValues is always nil,
/// FocusedValues entries cannot specify a different default value and must have an Optional type.
/// Create FocusedValues entries by extending the FocusedValues structure with new properties and attaching the @Entry macro to the variable declarations:
extension FocusedValues {
    @Entry var myCustomValue: String?
}

// MARK: - TransactionKey
/// https://developer.apple.com/documentation/swiftui/transactionkey

/// You can create custom transaction values by extending the Transaction structure with new properties. First declare a new transaction key type and specify a value for the required defaultValue property:
private struct MyTransactionKey: TransactionKey {
    static let defaultValue = false
}

extension Transaction {
    var myCustomValue: Bool {
        get { self[MyTransactionKey.self] }
        set { self[MyTransactionKey.self] = newValue }
    }
}

/// Clients of your transaction value never use the key directly. Instead, they use the key path of your custom transaction value property. To set the transaction value for a change, wrap that change in a call to withTransaction:
withTransaction(\.myCustomValue, true) {
    isActive.toggle()
}

/// To use the value from inside MyView or one of its descendants, use the transaction(_:) view modifier:
MyView()
    .transaction { transaction in
        if transaction.myCustomValue {
            transaction.animation = .default.repeatCount(3)
        }
    }

// MARK: - 250419 Drag And Drop
/// https://developer.apple.com/documentation/swiftui/adopting-drag-and-drop-using-swiftui

// Adopting drag and drop using SwiftUI

// MARK: - Transferable
/// A protocol that describes how a type interacts with transport APIs such as drag and drop or copy and paste.
/*
 To conform to the Transferable protocol, implement the transferRepresentation property. For example, an image editing app’s layer type might conform to Transferable to let people drag and drop image layers to reorder them within a document.
 */

struct ImageDocumentLayer {
    init(data: Data)
    func data() -> Data
    func pngData() -> Data
}

extension ImageDocumentLayer: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(contentType: .layer) { layer in
            layer.data()
        } importing: { data in
            ImageDocumentLayer(data: data)
        }
        DataRepresentation(exportedContentType: .png) { layer in
            layer.pngData()
        }
    }
}

/*
 When people drag and drop a layer within the app or onto another app that recognizes the custom layer content type, the app uses the first representation. When people drag and drop the layer onto a different image editor, it’s likely that the editor recognizes the PNG file type. The second transfer representation adds support for PNG files.

 The following declares the custom layer uniform type identifier:
 */
extension UTType {
    static var layer: UTType { UTType(exportedAs: "com.example.layer") }
}

///---> If your app declares custom uniform type identifiers,
///include corresponding entries in the app’s Info.plist.
///For more information, see Defining file and data types for your app.

// Defining file and data types for your app
/// https://developer.apple.com/documentation/UniformTypeIdentifiers/defining-file-and-data-types-for-your-app
/*
 Apps that save, load, or transfer documents with proprietary data formats can define the file or data type for each format by:

    --> Declaring your app’s custom type in the project’s Info.plist file.

    --> Creating a new identifier for exported types, or using existing identifiers for imported types.

    --> Defining each type’s conformance to system-declared types

    --> Listing any associated file extensions or MIME types.
 */

// MARK: - Warning
/// Don’t use public, dyn, or com.apple as the prefix in your app’s types.
/// The system reserves public for public domain or standard types.
/// The framework reserves the prefix dyn for types that it generates dynamically when no other type is available,
/// and the prefix com.apple for types that Apple declares.

/*
 The identifiers you create for your app need to be unique.
 To ensure uniqueness, start by using a reverse DNS format that begins with com.companyName.
 Although the system supports different type identifier strings with the same specification,
 the reverse isn’t true. The identifier must contain only alphanumeric characters (a–z, A–Z, and 0–9), hyphens (-),
 and periods (.). For example, you might use com.example.greatAppDocument or com.example.greatApp-document for the UTTypeIdentifier string in the Info.plist file.
 */

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>UTExportedTypeDeclarations</key>
    <array>
        <dict>
            <key>UTTypeConformsTo</key>
            <array>
                <string>public.contact</string>
            </array>
            <key>UTTypeDescription</key>
            <string>Contact</string>
            <key>UTTypeIcons</key>
            <dict/>
            <key>UTTypeIdentifier</key>
            <string>com.example.contact</string>
            <key>UTTypeTagSpecification</key>
            <dict>
                <key>public.filename-extension</key>
                <array>
                    <string>examplecontact</string>
                </array>
            </dict>
        </dict>
    </array>
</dict>
</plist>

extension Contact: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        // Allows Contact to be transferred with a custom content type.
        CodableRepresentation(contentType: .exampleContact)
        // Allows importing and exporting Contact data as a vCard.
        DataRepresentation(contentType: .vCard) { contact in
            try contact.toVCardData()
        } importing: { data in
            try await parseVCardData(data)
        }
        // Enables exporting the `phoneNumber` string as a proxy for the entire `Contact`.
        ProxyRepresentation { contact in
            contact.phoneNumber
        } importing: { value  in
            Contact(id: UUID().uuidString, givenName: value, familyName: "", phoneNumber: "")
        }
        .suggestedFileName { $0.fullName }
    }
}

extension UTType {
    static var exampleContact = UTType(exportedAs: "com.example.contact")
}

// MARK: - Codable
/// If one of your existing types conforms to Codable, Transferable automatically handles conversion to and from Data.
/// The following declares a simple Note structure that’s Codable and an extension to make it Transferable:
struct Note: Codable {
    let title: String
    let body: String
}

extension Note: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .note)
    }
}

/// To ensure compatibility with other apps that don’t know about the custom note type identifier,
/// the following adds an additional transfer representation that converts the note to text.
extension Note: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .note)
        ProxyRepresentation(\.title)
    }
}

// MARK: - TransferRepresentation
/// Combine multiple existing transfer representations to compose a single transfer representation that describes how to transfer an item in multiple scenarios.
import UniformTypeIdentifiers

struct Greeting: Codable, Transferable {
    let message: String
    var displayInAllCaps: Bool = false


    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .greeting)
        ProxyRepresentation(exporting: \.message)
    }
}


extension UTType {
    static var greeting: UTType { .init(exportedAs: "com.example.greeting") }
}

// MARK: - Choosing a transfer representation for a model type
/// https://developer.apple.com/documentation/coretransferable/choosing-a-transfer-representation-for-a-model-type

/*
 Core Transferable defines three main transfer representations: DataRepresentation, FileRepresentation, and CodableRepresentation.
 Use DataRepresentation for model types where the entire model is stored in memory, and use FileRepresentation for types stored on disk.
 */

// WARNING!!
/// If you use a CodableRepresentation, you’re often defining a new data type as well.
/// As a result, include corresponding entries in the app’s Info.plist. For more information, see Defining file and data types for your app.

struct Note: Transferable {
    var title: String
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .note)
        ProxyRepresentation(\.title)
    }
}

extension UTType {
     static var note: UTType { UTType(exportedAs: "com.example.note") }
}

// MARK: - Configure your model type for import or export
/// The following shows a data representation of tax information that can only import tax forms and can only output tax returns.
struct TaxInfo {
    var forms: [TaxForm]
    var year: Int

    init(_ formsData: Data) { ... }
    func generateReturnsData() -> Data { ... }
}

extension TaxInfo: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .taxForm) { formsData in
            TaxInfo(formsData)
        }
        DataRepresentation(exportedContentType: .taxReturn) { taxInfo in
            taxInfo.generateReturnsData()
        }
    }
}

extension UTType {
    static var taxForm = UTType(exportedAs: "com.example.taxForm")
    static var taxReturn = UTType(exportedAs: "com.example.taxReturn")
}

// MARK: - CodableRepresentation
/// If your app declares custom uniform type identifiers, include corresponding entries in the app’s Info.plist.
/// For more information, see Defining file and data types for your app.
struct Todo: Codable, Transferable {
    var text: String
    var isDone = false
    
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .todo)
    }
}

extension UTType {
    static var todo: UTType { UTType(exportedAs: "com.example.todo") }
}

/*
 func exportingCondition((Self.Item) -> Bool) -> _ConditionalTransferRepresentation<Self>
    --> Prevents the system from exporting an item if it does not meet the supplied condition.
 
 func suggestedFileName((Self.Item) -> String?) -> some TransferRepresentation<Self.Item>
    --> Provides a filename to use if the receiver chooses to write the item to disk.
 
 func suggestedFileName(String) -> some TransferRepresentation<Self.Item>
    --> Provides a filename to use if the receiver chooses to write the item to disk.
 
 func visibility(TransferRepresentationVisibility) -> some TransferRepresentation<Self.Item>
    --> Specifies the kinds of apps and processes that can see an item in transit.
 */
//
struct Archive {
    var supportsCSV: Bool
    func csvData() -> Data
    init(csvData: Data)
}

extension Archive: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(contentType: .commaSeparatedText) { archive in
            archive.csvData()
        } importing: {
            data in Archive(csvData: data)
        }
        .exportingCondition { archive in archive.supportsCSV }
    }
}

//
struct Note: Transferable {
    var title: String
    var body: String
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.body)
            .suggestedFileName { $0.title + ".txt" }
     }
 }

//
extension ImageDocumentLayer: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(contentType: .layer) { layer in
            layer.data()
            } importing: { data in
                try ImageDocumentLayer(data: data)
            }
            .suggestedFileName("Layer.exampleLayer")
        
        DataRepresentation(exportedContentType: .png) { layer in
            layer.pngData()
        }
        .suggestedFileName("Layer.png")
    }
}

// MARK: - DataRepresentation
struct ImageDocumentLayer {
    init(data: Data) throws
    func data() -> Data
    func pngData() -> Data
}

/*
 You can provide multiple transfer representations for a model type,
 even if the transfer representation types are the same.
 The following shows the ImageDocumentLayer structure conforming to Transferable with two DataRepresentation instances composed together:
 */

/// Tip: If a type conforms to Codable, CodableRepresentation might be a more convenient choice than DataRepresentation.
extension ImageDocumentLayer: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(contentType: .layer) { layer in
                layer.data()
            } importing: { data in
                try ImageDocumentLayer(data: data)
            }
        DataRepresentation(exportedContentType: .png) { layer in
            layer.pngData()
        }
    }
}

// MARK: - FileRepresentation
/// Use a FileRepresentation for transferring types that involve a large amount of data.
/// For example, if your app defines a Movie type that could represent a lengthy video,
/// use a FileRepresentation instance to transfer the video data to another app or process.
struct Movie: Transferable {
    let url: URL
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .mpeg4Movie) { movie in
            SentTransferredFile($0.url)
        } importing: { received in
            let copy: URL = URL(fileURLWithPath: "...")
            try FileManager.default.copyItem(at: received.file, to: copy)
            return Self.init(url: copy)
        }
    }
}

// MARK: - ProxyRepresentation
/// Use this representation to rely on an existing transfer representation that’s suitable for the type.
struct Note: Transferable {
    var body: String

    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(\.body)
    }
}

struct Todo: Transferable, Codable {
   var text: String
   var isDone = false

   static var transferRepresentation: some TransferRepresentation {
       CodableRepresentation(contentType: .todo)
       ProxyRepresentation(\.text)
   }
}

extension UTType {
    static var todo: UTType { UTType(exportedAs: "com.example.todo") }
}

// MARK: - Draggable
/// To enable drag interactions, add the draggable(_:) modifier to a view to send or receive Transferable items within an app,
/// among a collection of your own apps, or between your apps and others that support the import or export of a specified data format.
/// To handle dropped content, use the dropDestination(for:action:isTargeted:) modifier to receive the expected dropped item.

// Enable Drag Interactions
List {
    ForEach(dataModel.contacts) { contact in
        NavigationLink {
            ContactDetailView(contact: contact)
        } label: {
            CompactContactView(contact: contact)
                .draggable(contact) {
                    ThumbnailView(contact: contact)
                }
        }
    }
}


// MARK: - Apple Drag and Drop
// MARK: - Data Model
//import SwiftUI
//import UniformTypeIdentifiers
//import Contacts
//#if canImport(UIKit)
//import UIKit
//typealias PlatformImage = UIImage
//#elseif canImport(AppKit)
//import AppKit
//typealias PlatformImage = NSImage
//#endif

struct Contact: Identifiable, Codable, Hashable {
    var id: String
    var givenName: String
    var familyName: String
    var thumbNail: Data?
    var phoneNumber: String
    var email: String?
    var videoURL: URL?
    var fullName: String {
        givenName + " " + familyName
    }
}

extension UTType {
    static var exampleContact = UTType(exportedAs: "com.example.contact")
}

extension Contact: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        // Allows Contact to be transferred with a custom content type.
        CodableRepresentation(contentType: .exampleContact)
        // Allows importing and exporting Contact data as a vCard.
        DataRepresentation(contentType: .vCard) { contact in
            try contact.toVCardData()
        } importing: { data in
            try await parseVCardData(data)
        }
        // Enables exporting the `phoneNumber` string as a proxy for the entire `Contact`.
        ProxyRepresentation { contact in
            contact.phoneNumber
        } importing: { value  in
            Contact(id: UUID().uuidString, givenName: value, familyName: "", phoneNumber: "")
        }
        .suggestedFileName { $0.fullName }
    }
    
    static func parseVCardData(_ data: Data) async throws -> Contact {
        let contacts = try await CNContactVCardSerialization.contacts(
            with: data
        )
        
        guard let contact = contacts.first else {
            throw NSError(domain: "ContactImportError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid vCard data."])
        }
        
        let phoneNumber = contact.phoneNumbers.first?.value.stringValue ?? ""
        let email = contact.emailAddresses.first?.value as String?
        let thumbNail: Data? = contact.imageData
        return Contact(
            id: contact.id.uuidString,
            givenName: contact.givenName,
            familyName: contact.familyName,
            thumbNail: thumbNail,
            phoneNumber: phoneNumber,
            email: email,
            videoURL: nil
        )
    }
}

extension Contact {
    static var mock: [Contact] = [
         Contact(
             id: "123E4567-E89B-12D3-A456-426614174000",
             givenName: "Juan",
             familyName: "Chavez",
             thumbNail: nil,
             phoneNumber: "(510) 555-0101",
             email: "chavez4@icloud.com",
             videoURL: nil
         )
         //...
     ]
    
    static func convertImageToData(_ image: PlatformImage) -> Data? {
         #if canImport(AppKit)
         guard let tiffData = image.tiffRepresentation else { return nil }
         guard let bitmapImage = NSBitmapImageRep(data: tiffData) else { return nil }
         return bitmapImage.representation(using: .png, properties: [:])
         #elseif canImport(UIKit)
         return image.pngData()
         #endif
     }
}

extension Contact {
    func toVCardData() throws -> Data {
        let contact = CNMutableContact()
        contact.givenName = givenName
        contact.familyName = familyName
        contact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberMobile, value: CNPhoneNumber(stringValue: phoneNumber))]
        contact.imageData = thumbNail
        if let email = email {
            contact.emailAddresses = [CNLabeledValue(label: CNLabelEmailiCloud, value: NSString(string: email))]
        }
        let data = try CNContactVCardSerialization.data(with: [contact])
        return data
    }
    
    static func urlForResource(named name: String, withExtension ext: String) -> URL? {
        Bundle.main.url(forResource: name, withExtension: ext)
    }
}



// MARK: - Data Manager
//import SwiftUI
//import PhotosUI

@Observable
class DataModel {
    var contacts: [Contact] = Contact.mock
    var displayMode: ContactDetailView.DisplayMode = .list

    func handleDroppedContacts(droppedContacts: [Contact], index: Int? = nil) {
        guard let firstContact = droppedContacts.first else {
            return
        }
        // If the id of the first contact exists in the contacts list,
        // move the contact from its current position to the new index.
        // If an index isn't specified, insert the contact at the end of the list.
        if let existingIndex = contacts.firstIndex(where: { $0.id == firstContact.id }) {
            let indexSet = IndexSet(integer: existingIndex)
            contacts.move(fromOffsets: indexSet, toOffset: index ?? contacts.endIndex)
        } else {
            contacts.insert(firstContact, at: index ?? contacts.endIndex)
        }
    }

    /// Converts the binary data to an Image.
    static func loadImage(from data: Data?) -> Image? {
        guard let data else { return nil }
        #if canImport(UIKit)
        if let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        #elseif canImport(AppKit)
        if let nsImage = NSImage(data: data) {
            return Image(nsImage: nsImage)
        }
        #endif
        return nil
    }
    
    static func loadItem(selection: PhotosPickerItem?) async throws -> Video? {
        try await selection?.loadTransferable(type: Video.self)
    }
}

struct Video: Transferable {
    var url: URL
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { item in
            SentTransferredFile(item.url)
        } importing: { received in
            let url = try Video.copyLibraryFile(from: received.file)
            return Video(url: url)
        }
    }
    
    /// Copies a file from source URL to a user's library directory.
    static func copyLibraryFile(from source: URL) throws -> URL {
        let libraryDirectory = try FileManager.default.url(
            for: .libraryDirectory, in: .userDomainMask,
            appropriateFor: nil, create: true
        )
        var destination = libraryDirectory.appendingPathComponent(
            source.lastPathComponent, isDirectory: false)
        if FileManager.default.fileExists(atPath: destination.path) {
            let pathExtension = destination.pathExtension
            var fileName = destination.deletingPathExtension().lastPathComponent
            fileName += "_\(UUID().uuidString)"
            destination = destination
                .deletingLastPathComponent()
                .appendingPathComponent(fileName)
                .appendingPathExtension(pathExtension)
        }
        try FileManager.default.copyItem(at: source, to: destination)
        return destination
    }
}

// MARK: - ContentView
struct ContentView: View {
    @Environment(DataModel.self) private var dataModel

    var body: some View {
        NavigationStack {
            Group {
                switch dataModel.displayMode {
                case .table:
                    ContactTable()
                case .list:
                    ContactList()
                }
            }
            .environment(dataModel)
            .navigationTitle("Contacts")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    @Bindable var dataModel = dataModel
                    DisplayModePicker(mode: $dataModel.displayMode)
                }
            }
        }
    }
}

// MARK: - ListView
//import SwiftUI
//import Contacts
//import UniformTypeIdentifiers

struct ContactList: View {
    @Environment(DataModel.self) private var dataModel
    @State private var isTargeted = false
    
    var body: some View {
        List {
            ForEach(dataModel.contacts) { contact in
                NavigationLink {
                    ContactDetailView(contact: contact)
                } label: {
                    CompactContactView(contact: contact)
                        .draggable(contact) {
                            ThumbnailView(contact: contact)
                        }
                }
                .draggable(contact)
            }
            .dropDestination(for: Contact.self) { droppedContacts, index in
                dataModel.handleDroppedContacts(droppedContacts: droppedContacts, index: index)
            }
            .onMove { fromOffsets, toOffset in
                dataModel.contacts.move(fromOffsets: fromOffsets, toOffset: toOffset)
            }
            .onDelete { indexSet in
                dataModel.contacts.remove(atOffsets: indexSet)
            }
        }
        #if !os(macOS)
        .listStyle(.insetGrouped)
        .toolbar {
            EditButton()
        }
        #endif
    }
}

// MARK: - HeaderView
//import SwiftUI
//import AVKit
//import PhotosUI

struct HeaderView: View {
    @Environment(DataModel.self) private var dataModel
    @State private var photosPickerPresented = false
    @State private var selection: PhotosPickerItem?
    @State private var isTargeted = false
    var contact: Contact
    var height: CGFloat
    var width: CGFloat
    
    var body: some View {
        VStack {
            if let videoUrl = contact.videoURL {
                VideoView(videoUrl: videoUrl)
                    .frame(width: width, height: height * Constants.ratio)
            } else {
                ContentUnavailableView {
                    Button {
                        photosPickerPresented = true
                    } label: {
                        Image(systemName: "video.fill")
                    }
                } description: {
                    Text("Add a video to the contact or drag and drop a video file here.")
                }
                .frame(width: width, height: height * Constants.ratio)
                .background(LinearGradient(colors: [.blue.opacity(0.2), .clear], startPoint: .top, endPoint: .bottom))
            }
        }
        .background(isTargeted ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
        .dropDestination(for: Video.self) { droppedVideos, _ in
            // Find the contact's index and update the video URL.
            guard
                let video = droppedVideos.first,
                let index = dataModel.contacts.firstIndex(where: { $0.id == contact.id })
            else {
                return false
            }
            dataModel.contacts[index].videoURL = video.url
            return true
        } isTargeted: { isTargeted in
            self.isTargeted = isTargeted
        }
        .photosPicker(
            isPresented: $photosPickerPresented,
            selection: $selection,
            matching: .any(of: [.videos]),
            preferredItemEncoding: .automatic,
            photoLibrary: .shared()
        )
        .onChange(of: selection) {
            Task {
                let video = try await DataModel.loadItem(selection: selection)
                // Update the contact's video URL in the data model
                if let index = dataModel.contacts.firstIndex(where: { $0.id == contact.id }) {
                    dataModel.contacts[index].videoURL = video?.url
                }
            }
        }
    }
}

// Displays and controls video playback.
struct VideoView: View {
    var videoUrl: URL
    @State private var player: AVPlayer?
    
    var body: some View {
        VideoPlayer(player: player)
        .task {
            self.player = AVPlayer(url: videoUrl)
        }
    }
}

// MARK: - Making a view into a drag source
/// Use the draggable(_:) modifier to send or receive Transferable items within an app, among a collection of your own apps, or between your apps and other apps that support the import or export of a specified data format.
struct MyView: View {
    let name = "Mei Chen"
    
    var body: some View {
        Text(name)
            .draggable(name)
    }
}

/// Use the draggable(_:preview:) modifier to define a custom preview for the dragged item.
Text(name)
    .draggable(name) {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 300, height: 300)
                .foregroundStyle(.yellow.gradient)
            Text("Drop \(name)")
                .font(.title)
                .foregroundStyle(.red)
        }
    }

/*
 To customize the lift preview that the system shows as it transitions to displaying your custom preview, apply a contentShape(_:_:eoFill:) modifier with a dragPreview kind. For example, you can change the preview’s corner radius, as in the following code example:
 */
Text(name)
    .contentShape(.dragPreview, RoundedRectangle(cornerRadius: 7))
    .draggable(name) {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 300, height: 300)
                .foregroundStyle(.yellow.gradient)
            Text("Drop \(name)")
                .font(.title)
                .foregroundStyle(.red)
        }
    }

// MARK: - Create a transferable item for drag-and-drop operations
struct Profile: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var phoneNumber: String
}

extension Profile: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .profile)
        ProxyRepresentation(exporting: \.name)
    }
}

extension UTType {
    static var profile = UTType(exportedAs: "com.example.profile")
}

struct ContentView: View {
    @State private var profiles = [
        Profile(name: "Juan Chavez", phoneNumber: "(408) 555-4301"),
        Profile(name: "Mei Chen", phoneNumber: "(919) 555-2481")
    ]
    
    var body: some View {
        List {
            ForEach(profiles) { profile in
                Text(profile.name)
                    .draggable(profile)
            }
        }
    }
}

List {
    ForEach(profiles) { profile in
        Text(profile.name)
    }
    .onMove { indices, newOffset in
        // Update the items array based on source and destination indices.
        profiles.move(fromOffsets: indices, toOffset: newOffset)
    }
}

// MARK: - dropDestination(for:action:isTargeted:)
@State private var isDropTargeted = false

var body: some View {
    Color.pink
        .frame(width: 400, height: 400)
        .dropDestination(for: String.self) { receivedTitles, location in
            animateDrop(at: location)
            process(titles: receivedTitles)
        } isTargeted: {
            isDropTargeted = $0
        }
}

func process(titles: [String]) { ... }
func animateDrop(at: CGPoint) { ... }

// MARK: - springLoadingBehavior
/// Unlike disabled(_:), this modifier overrides the value set by an ancestor view rather than being unioned with it. For example, the below button would allow spring loading:
HStack {
    Button {
        showFolders = true
    } label: {
        Label("Show Folders", systemImage: "folder")
    }
    .springLoadingBehavior(.enabled)
    
    // ...
}
.springLoadingBehavior(.disabled)

// MARK: - Clipboard (Mac Only)
/*
 When people issue standard Copy and Cut commands, they expect to move items to the system’s Clipboard, from which they can paste the items into another place in the same app or into another app. Your app can participate in this activity if you add view modifiers that indicate how to respond to the standard commands.
 
 In your copy and paste modifiers, provide or accept types that conform to the Transferable protocol, or that inherit from the NSItemProvider class. When possible, prefer using transferable items.
 */

// MARK: - 250419 Events
// onSubmit(of:_:)
/// Adds an action to perform when the user submits a value to this view.
nonisolated
func onSubmit(
    of triggers: SubmitTriggers = .text,
    _ action: @escaping () -> Void
) -> some View

/*
 Different views may have different triggers for the provided action.
 A TextField, or SecureField will trigger this action when the user hits the hardware or software return key.
 This modifier may also bind this action to a default action keyboard shortcut.
 You may set this action on an individual view or an entire view hierarchy.
 */

/// You can use the submitScope(_:) modifier to stop a submit trigger from a control from propagating higher up in the view hierarchy to higher View.onSubmit(of:_:) modifiers.
Form {
    TextField("Username", text: $viewModel.userName)
    SecureField("Password", text: $viewModel.password)


    TextField("Tags", text: $viewModel.tags)
        .submitScope()
}
.onSubmit {
    guard viewModel.validate() else { return }
    viewModel.login()
}

/// you may provide a value of search to only hear submission triggers that originate from search fields vended by searchable modifiers.
@StateObject private var viewModel = ViewModel()

NavigationView {
    SidebarView()
    DetailView()
}
.searchable(
    text: $viewModel.searchText,
    placement: .sidebar
) {
    SuggestionsView()
}
.onSubmit(of: .search) {
    viewModel.submitCurrentSearchQuery()
}

// MARK: - 250419 Gestures
/// https://developer.apple.com/documentation/swiftui/gestures
/*
 Gesture modifiers handle all of the logic needed to process user-input events such as touches, and recognize when those events match a known gesture pattern, such as a long press or rotation. When recognizing a pattern, SwiftUI runs a callback you use to update the state of a view or perform an action.
 */
struct ShapeTapView: View {
    var body: some View {
        let tap = TapGesture()
            ///Depending on the callbacks you add to a gesture modifier, SwiftUI reports back to your code whenever the state of the gesture changes. Gesture modifiers offer three ways to receive updates:
            ///updating(_:body:),
            ///onChanged(_:),
            ///and onEnded(_:).
            .onEnded { _ in
                print("View tapped!")
            }
        
        return Circle()
            .fill(Color.blue)
            .frame(width: 100, height: 100, alignment: .center)
            .gesture(tap)
    }
}

// Update transient UI state
@MainActor @preconcurrency
func updating<State>(
    _ state: GestureState<State>,
    body: @escaping (Self.Value, inout State, inout Transaction) -> Void
) -> GestureStateGesture<Self, State>

struct CounterView: View {
    @GestureState private var isDetectingLongPress = false
    
    var body: some View {
        let press = LongPressGesture(minimumDuration: 1)
            .updating($isDetectingLongPress) { currentState, gestureState, transaction in
                gestureState = currentState
            }
        
        return Circle()
            .fill(isDetectingLongPress ? Color.yellow : Color.green)
            .frame(width: 100, height: 100, alignment: .center)
            .gesture(press)
    }
}

struct CounterView: View {
    @GestureState private var isDetectingLongPress = false
    @State private var totalNumberOfTaps = 0
    @State private var doneCounting = false
    
    var body: some View {
        let press = LongPressGesture(minimumDuration: 1)
            .updating($isDetectingLongPress) { currentState, gestureState, transaction in
                gestureState = currentState
            }.onChanged { _ in
                self.totalNumberOfTaps += 1
            }
            .onEnded { _ in
                self.doneCounting = true
            }
        
        return VStack {
            Text("\(totalNumberOfTaps)")
                .font(.largeTitle)
            
            Circle()
                .fill(doneCounting ? Color.red : isDetectingLongPress ? Color.yellow : Color.green)
                .frame(width: 100, height: 100, alignment: .center)
                .gesture(doneCounting ? nil : press)
        }
    }
}

// MARK: - onTapGesture(count:perform:)
nonisolated
func onTapGesture(
    count: Int = 1,
    perform action: @escaping () -> Void
) -> some View

struct TapGestureExample: View {
    let colors: [Color] = [.gray, .red, .orange, .yellow,
                           .green, .blue, .purple, .pink]
    @State private var fgColor: Color = .gray

    var body: some View {
        Image(systemName: "heart.fill")
            .resizable()
            .frame(width: 200, height: 200)
            .foregroundColor(fgColor)
            .onTapGesture(count: 2) {
                fgColor = colors.randomElement()!
            }
    }
}

// MARK: - onUpdate(SC)
/// In the following example, the drag gesture will update the offset variable, which is in turned used to move the view and follow the gesture. As soon as you let go, the offset resets back to zero.
 struct ExampleView: View {
     @GestureState private var offset: CGSize = .zero
     
     var body: some View {
         let drag = DragGesture()
             .updating($offset) { value, state, transaction in
                 state = value.translation
         }
         
         return Image("balloons-small")
             .shadow(radius: 8)
             .offset(self.offset)
             .gesture(drag)
             .animation(.spring())
     }
 }

// MARK: - onChanges(SC)
/// In the following example, try dragging the arrow image. It will use the onChanged closure to make sure the arrow is always pointing to the origin point.

struct ExampleView: View {
    @State private var angle: Angle = .zero
    @State private var offset: CGSize = .zero
    
    var body: some View {
        let drag = DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                let t = value.translation
                let a = Double(t.width == 0 ? 0.0001 : t.width)
                let b = Double(t.height)
                
                let ang = a < 0 ? atan(Double(b / a)) : atan(Double(b / a)) - Double.pi
                self.angle = Angle(radians: ang)
                self.offset = value.translation
            }.onEnded { value in
                self.angle = .zero
                self.offset = .zero
            }
            
        return ZStack {
            Circle().fill(Color.green).frame(width: 30.0, height: 30.0)
                
            Image(systemName: "arrow.right.circle.fill")
                .resizable()
                .foregroundColor(Color.red)
                .frame(width: 40, height: 40)
                .rotationEffect(angle)
                .offset(offset)
                .gesture(drag)
                .animation(.spring())
        }
    }
}

// MARK: - onEnded (SC)
/// Use the example below to swipe the text from left to right or right to left.
struct ExampleView: View {
    @State private var text = "Swipe Horizontally Over Me"
    
    var body: some View {
        let swipe = DragGesture()
            .onEnded { value in
                if value.translation.width > 0 {
                    self.text = "Swiped Right"
                } else {
                    self.text = "Swiped Left"
                }
        }
        
        return Text(text)
            .font(.title)
            .foregroundColor(.white)
            .padding(15)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.red))
            .gesture(swipe)
    }
}

// MARK: - onTapGesture(count:coordinateSpace:perform:)
/// Adds an action to perform when this view recognizes a tap gesture, and provides the action with the location of the interaction.
nonisolated
func onTapGesture(
    count: Int = 1,
    coordinateSpace: some CoordinateSpaceProtocol = .local,
    perform action: @escaping (CGPoint) -> Void
) -> some View

/// The following code adds a tap gesture to a Circle that toggles the color of the circle based on the tap location.
struct TapGestureExample: View {
    @State private var location: CGPoint = .zero

    var body: some View {
        Circle()
            .fill(self.location.y > 50 ? Color.blue : Color.red)
            .frame(width: 100, height: 100, alignment: .center)
            .onTapGesture { location in
                self.location = location
            }
    }
}

// MARK: - SpatialTapGesture
/// Creates a tap gesture with the number of required taps and the coordinate space of the gesture’s location.
init(
    count: Int = 1,
    coordinateSpace: some CoordinateSpaceProtocol = .local
)

struct TapGestureView: View {
    @State private var location: CGPoint = .zero

    var tap: some Gesture {
        SpatialTapGesture()
            .onEnded { event in
                self.location = event.location
             }
    }
    
    var body: some View {
        Circle()
            .fill(self.location.y > 50 ? Color.blue : Color.red)
            .frame(width: 100, height: 100, alignment: .center)
            .gesture(tap)
    }
}

// MARK: - onLongPressGesture
nonisolated
func onLongPressGesture(
    minimumDuration: Double = 0.5,
    maximumDistance: CGFloat = 10,
    perform action: @escaping () -> Void,
    onPressingChanged: ((Bool) -> Void)? = nil
) -> some View

struct LongPressGestureView: View {
    @GestureState private var isDetectingLongPress = false
    @State private var completedLongPress = false


    var longPress: some Gesture {
        LongPressGesture(minimumDuration: 3)
            .updating($isDetectingLongPress) { currentState, gestureState,
                    transaction in
                gestureState = currentState
                transaction.animation = Animation.easeIn(duration: 2.0)
            }
            .onEnded { finished in
                self.completedLongPress = finished
            }
    }


    var body: some View {
        Circle()
            .fill(self.isDetectingLongPress ?
                Color.red :
                (self.completedLongPress ? Color.green : Color.blue))
            .frame(width: 100, height: 100, alignment: .center)
            .gesture(longPress)
    }
}

// MARK: - SpatialEventGesture
/// A gesture that provides information about ongoing spatial events like clicks and touches.
struct ParticlePlayground: View {
    @State var model = ParticlesModel()
    
    var body: some View {
        Canvas { context, size in
            for particle in model.particles {
                context.fill(Path(ellipseIn: particle.frame),
                             with: .color(particle.color))
            }
        }
        .gesture(
            SpatialEventGesture()
                .onChanged { events in
                    for event in events {
                        if event.phase == .active {
                            // Update particle emitters.
                            model.emitters[event.id] = ParticlesModel.Emitter(
                                location: event.location
                            )
                        } else {
                            // Remove emitters when no longer active.
                            model.emitters[event.id] = nil
                        }
                    }
                }
                .onEnded { events in
                    for event in events {
                        // Remove emitters when no longer active.
                        model.emitters[event.id] = nil
                    }
                }
        )
    }
}

// MARK: - DragGesture
/// To recognize a drag gesture on a view, create and configure the gesture, and then add it to the view using the gesture(_:including:) modifier.

struct DragGestureView: View {
    @State private var isDragging = false

    var drag: some Gesture {
        DragGesture()
            .onChanged { _ in self.isDragging = true }
            .onEnded { _ in self.isDragging = false }
    }

    var body: some View {
        Circle()
            .fill(self.isDragging ? Color.red : Color.blue)
            .frame(width: 100, height: 100, alignment: .center)
            .gesture(drag)
    }
}

// MARK: - MagnifyGesture
struct MagnifyGestureView: View {
    @GestureState private var magnifyBy = 1.0


    var magnification: some Gesture {
        MagnifyGesture()
            .updating($magnifyBy) { value, gestureState, transaction in
                gestureState = value.magnification
            }
    }


    var body: some View {
        Circle()
            .frame(width: 100, height: 100)
            .scaleEffect(magnifyBy)
            .gesture(magnification)
    }
}

// MARK: - RotateGesture
struct RotateGestureView: View {
    @State private var angle = Angle(degrees: 0.0)


    var rotation: some Gesture {
        RotateGesture()
            .onChanged { value in
                angle = value.rotation
            }
    }


    var body: some View {
        Rectangle()
            .frame(width: 200, height: 200, alignment: .center)
            .rotationEffect(angle)
            .gesture(rotation)
    }
}

// MARK: - onPencilDoubleTap(perform:)
enum MyDrawingTool: Equatable {
    case brush
    case lasso
    case eraser
    ...
}

enum MyPencilAction: String {
    case switchLasso
    ...
}

@State private var currentTool = MyDrawingTool.brush
@State private var lastTool: MyDrawingTool?

@Environment(\.preferredPencilDoubleTapAction) private var globalAction
@AppStorage("customPencilDoubleTapAction") private var customAction: MyPencilAction?

var body: some View {
    MyDrawingCanvas()
        .onPencilDoubleTap { _ in
            guard globalAction != .ignore else {
                // Respect the user’s preference to ignore the double-tap gesture.
                return
            }
            if let customAction {
                // If a custom action is configured, respect it.
                if customAction == .switchLasso, currentTool != .lasso {
                     (currentTool, lastTool) = (.lasso, currentTool)
                }
            } else if globalAction == .switchEraser, currentTool != .eraser {
                // Switch to eraser if the user prefers it otherwise.
                (currentTool, lastTool) = (.eraser, currentTool)
            } else if let lastTool {
                // Switch to the last used tool by default.
                (currentTool, lastTool) = (lastTool, currentTool)
            }
        }
}

// MARK: - Composing SwiftUI gestures
/// https://developer.apple.com/documentation/swiftui/composing-swiftui-gestures
/*
 When you add multiple gestures to your app’s view hierarchy, you need to decide how the gestures interact with each other.
 You use gesture composition to define the order SwiftUI recognizes gestures. There are three gesture composition types:
    --> Simultaneous
    --> Sequenced
    --> Exclusive
 */

/// When you combine gesture modifiers simultaneously,
/// SwiftUI must recognize all subgesture patterns at the same time for it to recognize the combining gesture.
/// When you sequence gesture modifiers one after the other, SwiftUI must recognize each subgesture in order.
/// Finally, when you combine gestures exclusively,
/// SwiftUI recognizes the entire gesture pattern when SwiftUI only recognizes one subgesture but not the others.

// MARK: - Model sequenced gesture states
struct DraggableCircle: View {
    enum DragState {
        case inactive
        case pressing
        case dragging(translation: CGSize)
        
        var translation: CGSize {
            switch self {
            case .inactive, .pressing:
                return .zero
            case .dragging(let translation):
                return translation
            }
        }
        
        var isActive: Bool {
            switch self {
            case .inactive:
                return false
            case .pressing, .dragging:
                return true
            }
        }
        
        var isDragging: Bool {
            switch self {
            case .inactive, .pressing:
                return false
            case .dragging:
                return true
            }
        }
    }
    
    @GestureState private var dragState = DragState.inactive
    @State private var viewState = CGSize.zero
    
    var body: some View {
        let minimumLongPressDuration = 0.5
        let longPressDrag = LongPressGesture(minimumDuration: minimumLongPressDuration)
            .sequenced(before: DragGesture())
            .updating($dragState) { value, state, transaction in
                switch value {
                    // Long press begins.
                case .first(true):
                    state = .pressing
                    // Long press confirmed, dragging may begin.
                case .second(true, let drag):
                    state = .dragging(translation: drag?.translation ?? .zero)
                    // Dragging ended or the long press cancelled.
                default:
                    state = .inactive
                }
            }
            .onEnded { value in
                guard case .second(true, let drag?) = value else { return }
                self.viewState.width += drag.translation.width
                self.viewState.height += drag.translation.height
            }
        
        return Circle()
            .fill(Color.blue)
            .overlay(dragState.isDragging ? Circle().stroke(Color.white, lineWidth: 2) : nil)
            .frame(width: 100, height: 100, alignment: .center)
            .offset(
                x: viewState.width + dragState.translation.width,
                y: viewState.height + dragState.translation.height
            )
            .animation(nil)
            .shadow(radius: dragState.isActive ? 8 : 0)
            .animation(.linear(duration: minimumLongPressDuration))
            .gesture(longPressDrag)
    }
}

//SC
/// In the following example, you will not be able to drag, until the long press is detected.
struct DragState {
    var offset: CGSize = .zero
    var dragging: Bool = false
}

struct ExampleView : View {
    @GestureState var dragState = DragState()
    
    var body: some View {
        let longDrag = LongPressGesture().sequenced(before: DragGesture())
            .updating($dragState) { value, state, transaction in
                switch value {
                case .first(true):
                    state.dragging = true
                case .second(true, let dragValue):
                    state.offset = dragValue?.translation ?? .zero
                default:
                    state.dragging = false
                }
            }
        
        return Image("balloons-small")
            .shadow(radius: 8)
            .scaleEffect(self.dragState.dragging ? 1.3 : 1)
            .offset(x: dragState.offset.width, y: dragState.offset.height)
            .gesture(longDrag)
            .animation(.spring())
    }
}

// MARK: - simultaneousGesture(_:including:)
/// Tapping or clicking the “heart” image sends two messages to the console: one for the image’s tap gesture handler, and the other from a custom gesture handler attached to the enclosing vertical stack. Tapping or clicking on the blue rectangle results only in the single message to the console from the tap recognizer attached to the VStack:
struct SimultaneousGestureExample: View {
    @State private var message = "Message"
    let newGesture = TapGesture().onEnded {
        print("Gesture on VStack.")
    }

    var body: some View {
        VStack(spacing:25) {
            Image(systemName: "heart.fill")
                .resizable()
                .frame(width: 75, height: 75)
                .padding()
                .foregroundColor(.red)
                .onTapGesture {
                    print("Gesture on image.")
                }
            Rectangle()
                .fill(Color.blue)
        }
        // LX: if no simultaneous, the inner child tap gesture has higher priority
        .simultaneousGesture(newGesture)
        .frame(width: 200, height: 200)
        .border(Color.purple)
    }
}

//SC
/// In the following example, you can magnify and rotate at the same time.
struct ExampleView : View {
    @GestureState var gestureValue = RotateAndMagnify()

    var body: some View {
        let rotateAndMagnifyGesture = MagnificationGesture()
            .simultaneously(with: RotationGesture())
            .updating($gestureValue) { value, state, transacation in
                state.angle = value.second ?? .zero
                state.scale = value.first ?? 0
        }
        
        return Image("balloons-small")
            .shadow(radius: 8)
            .rotationEffect(gestureValue.angle)
            .scaleEffect(gestureValue.scale)
            .gesture(rotateAndMagnifyGesture)
            .animation(.spring())
    }
    
    struct RotateAndMagnify {
        var scale: CGFloat = 1.0
        var angle: Angle = .zero
    }
}



// MARK: - exclusively
// SC
/// the view can either be dragged or magnified, but not both simultaneously.
struct ExampleView : View {
    @GestureState var gestureValue = DragAndMagnify()

    var body: some View {
        
        let rotateAndMagnifyGesture = DragGesture()
            .exclusively(before: MagnificationGesture())
            .updating($gestureValue) { value, state, transacation in
                switch value {
                case .first(let drag):
                    state.scale = 1
                    state.offset = drag.translation
                case .second(let magnification):
                    state.scale = magnification
                    state.offset = .zero
                }
        }
        
        return Image("balloons-small")
            .shadow(radius: 8)
            .offset(gestureValue.offset)
            .scaleEffect(gestureValue.scale)
            .gesture(rotateAndMagnifyGesture)
            .animation(.spring())
    }
    
    struct DragAndMagnify {
        var scale: CGFloat = 1.0
        var offset: CGSize = .zero
    }
}

// MARK: - Map (SC)
/// Returns a new gesture, mapping the values of the gesture it is based on.
struct ExampleView: View {
    @State private var rightSide: Bool = false
    @State private var logtext: String = ""
    @State private var loc: CGPoint = .zero
    
    var body: some View {
        
        let gesture = DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                self.loc = value.location
            }
            .map { value in
                return value.location.x > 150
            }
            .onChanged { value in
                self.rightSide = value
                self.logtext += "\(self.rightSide ? "RIGHT" : "LEFT")\n"
            }
        
        return
            HStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray)
                    .frame(width: 300, height: 200)
                    .gesture(gesture)
                    .overlay(
                        Text("\(Int(loc.x)), \(Int(loc.y))")
                            .foregroundColor(rightSide ? Color.white : Color.black)
                            .font(.title)
                )
                
                ScrollView {
                    Text("Log Text:")
                    Divider()
                    Text("\(logtext)")
                }.frame(width: 180).border(Color.gray)
            }.frame(width: 500, height: 200)
    }
}

// MARK: - Gesture State
/*
 Declare a property as @GestureState, pass as a binding to it as a parameter to a gesture’s updating(_:body:) callback, and receive updates to it. A property that’s declared as @GestureState implicitly resets when the gesture becomes inactive, making it suitable for tracking transient state.

 Add a long-press gesture to a Circle, and update the interface during the gesture by declaring a property as @GestureState:
 */

struct SimpleLongPressGestureView: View {
    @GestureState private var isDetectingLongPress = false

    var longPress: some Gesture {
        LongPressGesture(minimumDuration: 3)
            .updating($isDetectingLongPress) { currentState, gestureState, transaction in
                gestureState = currentState
            }
    }

    var body: some View {
        Circle()
            .fill(self.isDetectingLongPress ? Color.red : Color.green)
            .frame(width: 100, height: 100, alignment: .center)
            .gesture(longPress)
    }
}

// MARK: - UIGestureRecognizerRepresentable (SC)
/// A protocol that wraps a UIGestureRecognizer that you use to integrate that gesture recognizer into your SwiftUI hierarchy.

// Example #1: Basic recognizer
struct PinchGesture: UIGestureRecognizerRepresentable {
    @Binding var scale: Double
    @Binding var velocity: Double
    @Binding var state: UIGestureRecognizer.State
    
    func makeUIGestureRecognizer(context: Context) -> UIPinchGestureRecognizer {
        UIPinchGestureRecognizer()
    }
    
    func handleUIGestureRecognizerAction(_ recognizer: UIPinchGestureRecognizer, context: Context) {
        scale = recognizer.scale
        velocity = recognizer.velocity
        state = recognizer.state
    }
}

struct ExampleView: View {
    @State var scale: Double = 0.0
    @State var velocity: Double = 0.0
    @State var state: UIGestureRecognizer.State = .ended
    
    var body: some View {
        
        let pinch = PinchGesture(scale: $scale,
                                 velocity: $velocity,
                                 state: $state.animation(.spring(.smooth(extraBounce: 0.5))))
        
        Image(systemName: "globe")
            .resizable()
            .scaledToFit()
            .scaleEffect(state != .ended ? scale : 1.0, anchor: .center)
            .gesture(pinch)
    }
}

// MARK: - Example #2: Responding to the Environment
/*
 In this example you can swipe right over the yellow rectangle.
 Each swipe will increment a counter. You may customize the gesture to recognize one or two fingers.
 A Picker will update the environment with the number of required touches.
 The updateUIGestureRecognizer(:context:) modifier is in charge of updating the recognizer with the new configuration obtained from the Environment.

 Note that the environment() modifier is placed after the gesture() modifier. Otherwise, the gesture's environment would not change.
 */

extension EnvironmentValues {
    @Entry var swipeRequiredTouches: Int = 1
}

struct SwipeGesture: UIGestureRecognizerRepresentable {
    @Environment(\.swipeRequiredTouches) var requiredTouches
    let action: () -> ()
    
    func makeUIGestureRecognizer(context: Context) -> UISwipeGestureRecognizer {
        let recognizer = UISwipeGestureRecognizer()
        
        recognizer.direction = .right
        recognizer.numberOfTouchesRequired = requiredTouches
        
        return recognizer
    }
    
    func handleUIGestureRecognizerAction(_ recognizer: UISwipeGestureRecognizer, context: Context) {
        action()
    }
    
    func updateUIGestureRecognizer(_ recognizer: UISwipeGestureRecognizer, context: Context) {
        recognizer.numberOfTouchesRequired = requiredTouches
    }
}

struct ExampleView: View {
    @State var swipeTouches: Int = 1
    @State var counter = 0
    
    var body: some View {
        let swipe = SwipeGesture {
            counter += 1
        }
        
        VStack(spacing: 20) {
            RoundedRectangle(cornerRadius: 8.0)
                .fill(.yellow.gradient)
                .frame(width: 300, height: 300)
                .overlay { Text("Swipes: \(counter)") }
                .gesture(swipe)
                .environment(\.swipeRequiredTouches, swipeTouches)


            VStack {
                Text("Number of Touches Required")
                Picker("", selection: $swipeTouches) {
                    ForEach(1..<3) { idx in
                        Text("\(idx)").tag(idx)
                    }
                }.pickerStyle(.segmented)
            }
            
        }
        .frame(width: 300)
    }
}

// MARK: - Example #3: With recognizer delegate
/// This example uses a coordinator, as a gesture delegate. This is used to configure the simultaneous recognition of gestures.
/// In this case, if the toggle is ON, both gestures will get recognize, but only one if the toggle is OFF.
extension EnvironmentValues {
    @Entry var multiSwipe: Bool = true
}

class SwipeCoordinator: NSObject, UIGestureRecognizerDelegate {
    var multipleRecognizersAllowed = true

    @objc func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
      return multipleRecognizersAllowed
    }
}

struct SwipeGesture: UIGestureRecognizerRepresentable {
    @Environment(\.multiSwipe) var multiSwipe
    let action: () -> ()
    
    func makeUIGestureRecognizer(context: Context) -> UISwipeGestureRecognizer {
        let recognizer = UISwipeGestureRecognizer()
        
        recognizer.delegate = context.coordinator
        recognizer.direction = .right
        
        return recognizer
    }
    
    func handleUIGestureRecognizerAction(_ recognizer: UISwipeGestureRecognizer, context: Context) {
        action()
    }
    
    func updateUIGestureRecognizer(_ recognizer: UISwipeGestureRecognizer, context: Context) {
        context.coordinator.multipleRecognizersAllowed = multiSwipe
    }
    
    func makeCoordinator(converter: CoordinateSpaceConverter) -> SwipeCoordinator {
        let coordinator = SwipeCoordinator()
        
        coordinator.multipleRecognizersAllowed = multiSwipe
        
        return coordinator
    }
}

struct ExampleView: View {
    @State var multiEnabled: Bool = true
    @State var counter1 = 0
    @State var counter2 = 0
    
    var body: some View {
        let swipe1 = SwipeGesture { counter1 += 1 }
        let swipe2 = SwipeGesture { counter2 += 1 }

        VStack(spacing: 20) {
            RoundedRectangle(cornerRadius: 8.0)
                .fill(.yellow.gradient)
                .frame(width: 300, height: 300)
                .overlay { Text("Swipes: \(counter1) / \(counter2)") }
                .gesture(swipe1)
                .gesture(swipe2)
                .environment(\.multiSwipe, multiEnabled)
            
            VStack {
                Toggle("Multiple Recognizers", isOn: $multiEnabled)
            }
            
        }
        .frame(width: 300)
    }
}

// MARK: - Example #4: Coordinates Conversion
///The context conveniently provides a converter of type UIGestureRecognizerRepresentableCoordinateSpaceConverter. It has several conversion functions. In this example we convert touch locations to local coordinates of the parent of the view with the gesture modifier. Please refer to UIGestureRecognizerRepresentableCoordinateSpaceConverter for more information.
struct PinchGesture: UIGestureRecognizerRepresentable {
    @Binding var locations: (CGPoint, CGPoint)
    @Binding var scale: Double
    @Binding var state: UIGestureRecognizer.State

    func makeUIGestureRecognizer(context: Context) -> UIPinchGestureRecognizer {
        UIPinchGestureRecognizer()
    }
    
    func handleUIGestureRecognizerAction(_ recognizer: UIPinchGestureRecognizer, context: Context) {
        scale = recognizer.scale
        state = recognizer.state

        if recognizer.numberOfTouches > 1 {
            let finger1 = context.converter.convert(globalPoint: recognizer.location(ofTouch: 0, in: nil), to: .local)
            let finger2 = context.converter.convert(globalPoint: recognizer.location(ofTouch: 1, in: nil), to: .local)
            
            locations = (finger1, finger2)
        }
    }
}

struct ExampleView: View {
    @State var fingers: (CGPoint, CGPoint) = (.zero, .zero)
    @State var scale: Double = 0.0
    @State var state: UIGestureRecognizer.State = .ended
    
    var body: some View {
        
        let pinch = PinchGesture(locations: $fingers,
                                 scale: $scale,
                                 state: $state.animation(.spring(.smooth(extraBounce: 0.5))))
        
        VStack {
            Image(systemName: "globe")
                .resizable()
                .scaledToFit()
                .scaleEffect(state != .ended ? scale : 1.0, anchor: .center)
                .gesture(pinch)
                .padding()
        }
        .frame(width: 300, height: 300)
        .border(.gray)
        .overlay {
            if state != .ended {
                let dotSize: CGFloat = 60
                GeometryReader { proxy in
                    ZStack {
                        Circle()
                            .fill(.yellow)
                            .frame(width: dotSize, height: dotSize)
                            .offset(x: fingers.0.x-dotSize/2, y: fingers.0.y-dotSize/2)
                        
                        Circle()
                            .fill(.yellow)
                            .frame(width: dotSize, height: dotSize)
                            .offset(x: fingers.1.x-dotSize/2, y: fingers.1.y-dotSize/2)

                    }
                }
            }
        }
    }
}

// MARK: - highPriorityGesture
func highPriorityGesture<T>(_ gesture: T, including mask: GestureMask = .all) -> some View where T : Gesture

struct ExampleView: View {
    var body: some View {
        let g = TapGesture().onEnded {
            print("outer gesture")
        }
        
        return VStack {
            Rectangle()
                .fill(Color.yellow)
                .onTapGesture {
                    print("inner gesture")
                }

            Rectangle()
                .fill(Color.green)

        }.highPriorityGesture(g)
    }
}

// MARK: - 250418 Scroll Views
/// https://developer.apple.com/documentation/swiftui/scroll-views
// Enable people to scroll to content that doesn’t fit in the current display.

/*
 Lists and Tables implicitly include a scroll view, so you don’t need to add scrolling to those container types. However, you can configure their implicit scroll views with the same view modifiers that apply to explicit scroll views.
 */

var body: some View {
    ScrollView {
        VStack(alignment: .leading) {
            ForEach(0..<100) {
                Text("Row \($0)")
            }
        }
    }
}

// Controlling Scroll Position
/// Provide a value of `UnitPoint/center`` to have the scroll view start in the center of its content when a scroll view is scrollable in both axes.
ScrollView([.horizontal, .vertical]) {
    // initially centered content
}
.defaultScrollAnchor(.center)

ScrollView {
    // initially bottom aligned content
}
.defaultScrollAnchor(.bottom)

// MARK: - ScrollViewReader
/*
 You may not use the ScrollViewProxy during execution of the content view builder; doing so results in a runtime error. Instead,
 -> only actions created within content can call the proxy, such as gesture handlers or a view’s onChange(of:perform:) method.
 */
@Namespace var topID
@Namespace var bottomID

var body: some View {
    ScrollViewReader { proxy in
        ScrollView {
            Button("Scroll to Bottom") {
                withAnimation {
                    proxy.scrollTo(bottomID)
                }
            }
            .id(topID)

            VStack(spacing: 0) {
                ForEach(0..<100) { i in
                    color(fraction: Double(i) / 100)
                        .frame(height: 32)
                }
            }

            Button("Top") {
                withAnimation {
                    proxy.scrollTo(topID)
                }
            }
            .id(bottomID)
        }
    }
}

func color(fraction: Double) -> Color {
    Color(red: fraction, green: 1 - fraction, blue: 0.5)
}

// SC
/// A ScrollViewProxy contains a single function (scrollTo) that scans all contained scroll views, looking for the first view with the specified id and then scrolls to that view. The function signature is below:
func scrollTo<ID>(_ id: ID, anchor: UnitPoint? = nil) where ID : Hashable

struct ExampleView: View {
    var body: some View {
        ScrollViewReader { scrollProxy in
            VStack(spacing: 20) {
                HStack(spacing: 30) {
                    Grid(scrollView: 1, color: Color.green.opacity(0.5))

                    Grid(scrollView: 2, color: Color.blue.opacity(0.5))
                }

                Button("Scroll") {
                    withAnimation {
                        scrollProxy.scrollTo("ScrollView1_3_1", anchor: .topLeading)
                    }
                }
            }
        }
    }

    struct Grid: View {
        let scrollView: Int
        let color: Color
        let selected = Color.red.opacity(0.5)

        var body: some View {
            ScrollView([.vertical, .horizontal]) {
                VStack {
                    ForEach(0..<30) { row in
                        HStack {
                            ForEach(0..<30) { col in
                                Rectangle()
                                    .fill(scrollView == 1 && row == 3 && col == 1 ? selected : color)
                                    .overlay(Text("(\(row), \(col))")).frame(width: 70, height: 50)
                                    .id("ScrollView\(scrollView)_\(row)_\(col)")
                            }
                        }
                    }
                }
            }.frame(width: 200, height: 200).border(Color.primary)
        }
    }
}

// MARK: - scrollPosition(_:anchor:)
nonisolated
func scrollPosition(
    _ position: Binding<ScrollPosition>,
    anchor: UnitPoint? = nil
) -> some View

@State private var position = ScrollPosition(idType: MyItem.ID.self)

@Binding var items: [MyItem]
@State private var position: ScrollPosition = .init(idType: MyItem.ID.self)

ScrollView {
    LazyVStack {
        ForEach(items) { item in
            ItemView(item)
        }
    }
    .scrollTargetLayout()
}
.scrollPosition($scrolledID)

/// You can then query the currently scrolled id by using the viewID(type:).
let viewID: MyItem.ID = position.viewID(type: MyItem.ID.self)

/// While most use cases will use view identity based scrolling, you can also use the scroll position type to scroll to offsets or edges. For example, you can create a button that scrolls to the bottom of the scroll view by specifying an edge.
Button("Scroll to bottom") {
    position.scrollTo(edge: .bottom)
}

// In the example below, the bottom most view will be chosen to update the position binding with.
/// For example, providing a value of bottom will prefer to have the bottom-most view chosen and prefer to scroll to views aligned to the bottom.
ScrollView {
    LazyVStack {
        ForEach(items) { item in
            ItemView(item)
        }
    }
    .scrollTargetLayout()
}
.scrollPosition($scrolledID, anchor: .bottom)

//SC
struct Symbol: Identifiable {
    let id: Int
    let name: String
    let color: Color
}

struct ExampleView: View {
    @State var position: ScrollPosition = ScrollPosition(id: 1)
    @State var anchor: Int = 1
    
    let symbols: [Symbol] = [
        Symbol(id: 1, name: "figure.walk", color: .red),
        Symbol(id: 2, name: "figure.walk.diamond", color: .orange),
        Symbol(id: 3, name: "figure.wave", color: .yellow),
        Symbol(id: 4, name: "bolt.car", color: .green),
        Symbol(id: 5, name: "airplane", color: .blue),
        Symbol(id: 6, name: "airplane.arrival", color: .indigo),
        Symbol(id: 7, name: "airplane.departure", color: .purple),
        Symbol(id: 8, name: "car", color: .red),
        Symbol(id: 9, name: "car.2", color: .orange),
        Symbol(id: 10, name: "bus", color: .yellow),
        Symbol(id: 11, name: "bus.doubledecker", color: .green),
        Symbol(id: 12, name: "tram", color: .blue),
        Symbol(id: 13, name: "cablecar", color: .indigo),
        Symbol(id: 14, name: "ferry", color: .purple),
        Symbol(id: 15, name: "car.ferry", color: .red),
        Symbol(id: 16, name: "box.truck", color: .orange),
        Symbol(id: 17, name: "box.truck.badge.clock", color: .yellow),
        Symbol(id: 18, name: "bicycle", color: .green),
        Symbol(id: 19, name: "scooter", color: .blue),
        Symbol(id: 20, name: "sailboat", color: .indigo),
        Symbol(id: 21, name: "fuelpump", color: .purple)
    ]

    var scrolledSymbol: Symbol? {
        guard let scrolledId: Int = position.viewID as? Int else { return nil }
        
        return symbols.first {
            $0.id == scrolledId
        }
    }
    
    
    var body: some View {
        VStack(spacing: 20) {
            showPosition()
            
            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    ForEach(symbols) { symbol in
                        SymbolThumbnail(symbol: symbol)
                    }
                }
                .scrollTargetLayout()
            }
            .frame(height: 100)
            .scrollPosition($position, anchor: anchor == 1 ? .leading : .trailing)
            .frame(width: 400)
            
            HStack(spacing: 10) {
                Button("Car") {
                    withAnimation(.spring) { position.scrollTo(id: 8) }
                }

                Button("Bicycle") {
                    withAnimation(.spring) { position.scrollTo(id: 18) }
                }
                
                Button("x = 250.0") {
                    withAnimation(.spring) { position.scrollTo(x: 250) }
                }
                
                Button("Leading Edge") {
                    withAnimation(.spring) { position.scrollTo(edge: .leading) }
                }

                Button("Trailing Edge") {
                    withAnimation(.spring) { position.scrollTo(edge: .trailing) }
                }
            }
            
            Picker("anchor", selection: $anchor) {
                Text(".leading").tag(1)
                Text(".trailing").tag(2)
            }.frame(width: 250)
        }
    }
    
    @ViewBuilder func showPosition() -> some View {
        VStack {
            if let scrolledSymbol {
                SymbolThumbnail(symbol: scrolledSymbol)
            } else if let edge = position.edge {
                Text("On Edge: \(edge)")
            } else if let point = position.point {
                Text("Scroll Point = \(point)")
            }
        }
        .frame(height: 100)
    }
}

struct SymbolThumbnail: View {
    let symbol: Symbol
    
    var body: some View {
        Image(systemName: symbol.name)
            .resizable()
            .scaledToFit()
            .foregroundColor(.white)
            .shadow(radius: 12)
            .padding(30)
            .frame(width: 100, height: 100)
            .background {
                Circle()
                    .fill(symbol.color)
            }
    }
}

// MARK: - scrollPosition(id:anchor:)
nonisolated
func scrollPosition(
    id: Binding<(some Hashable)?>,
    anchor: UnitPoint? = nil
) -> some View

/// Use the View/scrollTargetLayout() modifier to configure which the layout that contains your scroll targets. In the following example, the top-most ItemView will update with the scrolledID binding as the scroll view scrolls.
@Binding var items: [Item]
@Binding var scrolledID: Item.ID?

ScrollView {
    LazyVStack {
        ForEach(items) { item in
            ItemView(item)
        }
    }
    .scrollTargetLayout()
}
.scrollPosition(id: $scrolledID)

@Binding var items: [Item]
@Binding var scrolledID: Item.ID?

ScrollView {
    // ...
}
.scrollPosition(id: $scrolledID)
.toolbar {
    Button("Scroll to Top") {
        scrolledID = items.first
    }
}

/// If no anchor has been provided, SwiftUI will scroll the minimal amount when using the scroll position to programmatically scroll to a view.

//SC
struct ExampleView: View {
    static let fruits = [ "🍎", "🍌", "🍇", "🍊", "🍉", "🍓", "🍑", "🥝", "🍒"]

    @State var fruitIds: [String?] = ["🍊", "🍊", "🍊"]
    
    var body: some View {
        VStack {
            Button("Randomize") {
                withAnimation {
                    fruitIds[0] = ExampleView.fruits[Int.random(in: 0..<ExampleView.fruits.count)]
                    fruitIds[1] = ExampleView.fruits[Int.random(in: 0..<ExampleView.fruits.count)]
                    fruitIds[2] = ExampleView.fruits[Int.random(in: 0..<ExampleView.fruits.count)]
                }
            }

            HStack {
                FruitView(fruitId: $fruitIds[0])
                FruitView(fruitId: $fruitIds[1])
                FruitView(fruitId: $fruitIds[2])
            }
            
            Text("Current Ids = \(fruitIds[0]!)\(fruitIds[1]!)\(fruitIds[2]!)")
        }
    }
    
    struct FruitView: View {
        @Binding var fruitId: String?

        var body: some View {
            ScrollView(.vertical) {
                LazyVStack {
                    ForEach(ExampleView.fruits, id: \.self) {
                        Text($0).font(.system(size: 46))
                    }
                }
                .scrollTargetLayout()
                
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $fruitId)
            .border(.blue)
            .frame(width: 60, height: 60)
        }
    }
}


// MARK: - defaultScrollAnchor(_:)
nonisolated
func defaultScrollAnchor(_ anchor: UnitPoint?) -> some View\

/// Provide a value of `UnitPoint/center`` to have the scroll view start in the center of its content when a scroll view is scrollable in both axes.
ScrollView([.horizontal, .vertical]) {
    // initially centered content
}
.defaultScrollAnchor(.center)

@Binding var items: [Item]
@Binding var scrolledID: Item.ID?

ScrollView {
    LazyVStack {
        ForEach(items) { item in
            ItemView(item)
        }
    }
}
.defaultScrollAnchor(.bottom)

//SC
struct ExampleView: View {
    var body: some View {
        ScrollView {
            ForEach(0..<20) { idx in
                Text("Row #\(idx)")
            }
        }
        .defaultScrollAnchor(.bottom)
        .frame(height: 100)
    }
}

// MARK: - defaultScrollAnchor(_:for:)
nonisolated
func defaultScrollAnchor(
    _ anchor: UnitPoint?,
    for role: ScrollAnchorRole
) -> some View

/*
 You can associate a UnitPoint to a ScrollView using the defaultScrollAnchor(_:) modifier. By default, the system uses this point for different kinds of behaviors including:

    --> Where the scroll view should initially be scrolled

    --> How the scroll view should handle content size or container size changes

    --> How the scroll view should align content smaller than its container size
 */

@Binding var items: [Item]
@Binding var scrolledID: Item.ID?

ScrollView {
    LazyVStack {
        ForEach(items) { item in
            ItemView(item)
        }
    }
}
.defaultScrollAnchor(.bottom)
.defaultScrollAnchor(.topLeading, for: .alignment)

//SC
struct ExampleView: View {
    var body: some View {
        ScrollView {
            ForEach(0..<20) { idx in
                Text("Row #\(idx)")
            }
        }
        .defaultScrollAnchor(.bottom, for: .initialOffset)
        .frame(height: 100)
    }
}

// MARK: - scrollTargetBehavior(_:)
/*
 A scrollable view calculates where scroll gestures should end using its deceleration rate and the state of its scroll gesture by default. A scroll behavior allows for customizing this logic. You can provide your own ScrollTargetBehavior or use one of the built in behaviors provided by SwiftUI.
 */
ScrollView {
    LazyVStack(spacing: 0.0) {
        ForEach(items) { item in
            FullScreenItem(item)
        }
    }
}
.scrollTargetBehavior(.paging)

//SC
struct ExampleView: View {
    let fruits = ["🍎", "🍌", "🍇", "🍉", "🍊", "🍓", "🍑", "🥭", "🍍", "🥝", "🫐", "🍈", "🍒", "🥥", "🥑"]
    let vegetables = ["🥦", "🥕", "🍆", "🌽", "🥒", "🍅", "🫑", "🧄", "🧅", "🥔", "🥬", "🥗"]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                ForEach(fruits + vegetables, id: \.self) { item in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.gray.gradient)
                        .frame(width: 100, height: 100)
                        .overlay {
                            Text(item)
                                .font(.system(size: 66))
                        }
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .frame(width: 430, height: 100)
    }
}

// MARK: - View Aligned Behavior
/*
 You configure which views should be used for settling using the scrollTargetLayout(isEnabled:) modifier. Apply this modifier to a layout container like LazyVStack or HStack and each individual view in that layout will be considered for alignment.
 */

ScrollView(.horizontal) {
    LazyHStack(spacing: 10.0) {
        ForEach(items) { item in
            ItemView(item)
        }
    }
    .scrollTargetLayout()
}
.scrollTargetBehavior(.viewAligned)
.safeAreaPadding(.horizontal, 20.0)

// MARK: - scrollTargetLayout(isEnabled:)
/*
 Scroll target layouts act as a convenience for applying a View/scrollTarget(isEnabled:) modifier to each views in the layout.

 A scroll target layout will ensure that any target layout nested within the primary one will not also become a scroll target layout.
 */

LazyHStack { // a scroll target layout
    VStack { ... } // not a scroll target layout
    LazyHStack { ... } // also not a scroll target layout
}
.scrollTargetLayout()

// MARK: - ScrollTargetBehavior
struct BasicScrollTargetBehavior: ScrollTargetBehavior {
    func updateTarget(_ target: inout Target, context: TargetContext) {
        // Align to every 1/10 the size of the scroll view.
        target.rect.x.round(
            toMultipleOf: round(context.containerSize.width / 10.0))
    }
}

ScrollView {
    LazyVStack(spacing: 0.0) {
        ForEach(items) { item in
            FullScreenItem(item)
        }
    }
}
.scrollTargetBehavior(.paging)

ScrollView(.horizontal) {
    LazyHStack(spacing: 10.0) {
        ForEach(items) { item in
            ItemView(item)
        }
    }
    .scrollTargetLayout()
}
.scrollTargetBehavior(.viewAligned)
.safeAreaPadding(.horizontal, 20.0)

// MARK: - AnyScrollTargetBehavior
/// A type-erased scroll target behavior.
@Environment(\.horizontalSizeClass) var sizeClass

var body: some View {
    ScrollView { ... }
        .scrollTargetBehavior(scrollTargetBehavior)
}

var scrollTargetBehavior: some ScrollTargetBehavior {
    sizeClass == .compact
        ? AnyScrollTargetBehavior(.paging)
        : AnyScrollTargetBehavior(.viewAligned)
}

// MARK: - scrollTransition(_:axis:transition:)
/// https://developer.apple.com/documentation/swiftui/view/scrolltransition(_:axis:transition:)
/// Applies the given transition, animating between the phases of the transition as this view appears and disappears within the visible region of the containing scroll view, or other container specified using the coordinateSpace parameter.
nonisolated
func scrollTransition(
    _ configuration: ScrollTransitionConfiguration = .interactive,
    axis: Axis? = nil,
    transition: @escaping (EmptyVisualEffect, ScrollTransitionPhase) -> some VisualEffect
) -> some View

//SC
struct ExampleView: View {
    @State var disableClipping = true
    
    var body: some View {
        VStack {
            Toggle("Disable ScrollView Clipping", isOn: $disableClipping)
                    
            TransitionExampleView()
                .scrollClipDisabled(disableClipping)
                .padding(100)
                .border(.gray.opacity(0.5), width: 100)
        }
    }
    
    struct TransitionExampleView: View {
        let fruits = ["🍎", "🍌", "🍇", "🍉", "🍊", "🍓", "🍑", "🥭", "🍍", "🥝", "🫐", "🍈", "🍒", "🥥", "🥑"]
        let vegetables = ["🥦", "🥕", "🍆", "🌽", "🥒", "🍅", "🫑", "🧄", "🧅", "🥔", "🥬", "🥗"]
        
        var body: some View {
            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    ForEach(fruits + vegetables, id: \.self) { item in
                        EmojiView(emoji: item)
                            .scrollTransition(axis: .horizontal) { content, phase in
                                return content
                                    .scaleEffect(phase.isIdentity ? 1.0 : 0.2)
                                    .opacity(phase.isIdentity ? 1.0 : 0.2)
                                    .rotationEffect(rotation(for: phase))
                            }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .frame(width: 430, height: 100)
        }
        
        func rotation(for phase: ScrollTransitionPhase) -> Angle {
            switch phase {
                case .identity:
                    return .degrees(0)
                case .topLeading:
                    return .degrees(360)
                case .bottomTrailing:
                    return .degrees(-360)
            }
        }
        
        struct EmojiView: View {
            let emoji: String
            
            var body: some View {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.gray.gradient)
                    .frame(width: 100, height: 100)
                    .overlay {
                        Text(emoji)
                            .font(.system(size: 66))
                    }

            }
        }
    }
}

struct ExampleView: View {
    let emojis = ["🍎", "🍌", "🍇", "🍉", "🍊", "🍓", "🍑", "🥭", "🍍", "🥝", "🫐", "🍈", "🍒", "🥥", "🥑",
                  "🥦", "🥕", "🍆", "🌽", "🥒", "🍅", "🫑", "🧄", "🧅", "🥔", "🥬", "🥗"]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                ForEach(emojis, id: \.self) { item in
                    EmojiView(emoji: item)
                        .scrollTransition(topLeading: .animated(.bouncy),
                                          bottomTrailing: .interactive,
                                          axis: .horizontal) { content, phase in
                            content
                                .scaleEffect(scale(for: phase, emoji: item))
                                .opacity(phase.isIdentity ? 1.0 : 0.0)
                        }
                }
            }
            .scrollTargetLayout()
        }
        .scrollClipDisabled()
        .scrollTargetBehavior(.viewAligned)
        .frame(width: 430, height: 100)
    }
    
    func scale(for phase: ScrollTransitionPhase, emoji: String) -> CGFloat {
        if phase.isIdentity {
            return 1.0
        } else {
            return (emojis.firstIndex(where: { $0 == emoji })! % 2 == 0) ? 0.0 : 2.0
        }
    }
    
    struct EmojiView: View {
        let emoji: String
        
        var body: some View {
            RoundedRectangle(cornerRadius: 12)
                .fill(.gray.gradient)
                .frame(width: 100, height: 100)
                .overlay {
                    Text(emoji)
                        .font(.system(size: 66))
                }
            
        }
    }
}

// MARK: - onScrollGeometryChange(for:of:action:)
/// Adds an action to be performed when a value, created from a scroll geometry, changes.
nonisolated
func onScrollGeometryChange<T>(
    for type: T.Type,
    of transform: @escaping (ScrollGeometry) -> T,
    action: @escaping (T, T) -> Void
) -> some View where T : Equatable

@Binding var isBeyondZero: Bool

ScrollView {
    // ...
}
.onScrollGeometryChange(for: Bool.self) { geometry in
    geometry.contentOffset.y < geometry.contentInsets.top
} action: { wasBeyondZero, isBeyondZero in
    self.isBeyondZero = isBeyondZero
}

/*
 If multiple scroll views are found within the view hierarchy, only the first one will invoke the closure you provide and a runtime issue will be logged. For example, in the following view, only the vertical scroll view will have its geometry changes invoke the provided closure.
 */
VStack {
    ScrollView(.vertical) { ... }
    ScrollView(.horizontal) { ... }
}
// ---> NOT CORRECT
.onScrollGeometryChange(for: Bool.self) { geometry in
     ...
} action: { oldValue, newValue in
    ...
}

//SC
struct RubberBand: Equatable {
    enum State {
        case start
        case end
        case none
    }
    
    let state: State
    let overscroll: CGFloat
}

struct ExampleView: View {
    @State var backgroundImage: String = "landscape-1"
    @State var blur: Double = 0.0
    @State var saturation: Double = 1.0
    
    let images = ["landscape-1", "landscape-2", "landscape-3", "landscape-4"]
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(images, id: \.self) { image in
                        Image(image)
                            .resizable()
                            .frame(width: 300, height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 12.0))
                            .blur(radius: blur)
                            .saturation(saturation)
                    }
                }
            }
            .onScrollGeometryChange(for: RubberBand.self) { geometry in
                let start_rubber_band = -1 * geometry.contentOffset.x
                
                if start_rubber_band > 0 {
                    return RubberBand(state: .start, overscroll: start_rubber_band)
                }
                
                let end_rubber_band = -1 * (geometry.contentSize.width - (geometry.containerSize.width + geometry.contentOffset.x))
                
                if end_rubber_band > 0 {
                    return RubberBand(state: .end, overscroll: end_rubber_band)
                } else {
                    return RubberBand(state: .none, overscroll: 0)
                }
            } action: { _, new in
                
                blur = new.overscroll * 0.5
                saturation = 1.0 - (new.overscroll / 15.0)

            }
            .frame(width: 600, height: 300)
            .padding(30)
        }
    }
}

// MARK: - onScrollTargetVisibilityChange(idType:threshold:_:)
ScrollView {
    LazyVStack {
        ForEach(models) { model in
            CardView(model: model)
        }
    }
    .scrollTargetLayout()
}
.onScrollTargetVisibilityChange(for: Model.ID.self, threshold: 0.2) { onScreenCards in
    // Disable video playback for cards that are offscreen...
}

//SC
struct ExampleView: View {
    @State var backgroundImage: String = "landscape-1"
    
    let images = ["landscape-1", "landscape-2", "landscape-3", "landscape-4"]
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(images, id: \.self) { image in
                        Image(image)
                            .resizable()
                            .frame(width: 300, height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 12.0))
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .onScrollTargetVisibilityChange(idType: String.self) { imgs in
                if let image = imgs.first {
                    withAnimation(.spring) {
                        backgroundImage = image
                    }
                }
            }
            .frame(width: 300, height: 300)
            .padding(30)
        }
        .background {
            ZStack(alignment: .bottom) {
                Image(backgroundImage)
                    .resizable()
                    .scaledToFit()
                    .blur(radius: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 12.0))

                RoundedRectangle(cornerRadius: 12.0)
                    .stroke(.gray)
                
                Text("Scroll horizontally for more images")
                    .padding(.bottom, 10)
                    .font(.caption)
            }
        }
    }
}


// MARK: - onScrollVisibilityChange(threshold:_:)
/// When the view appears on-screen, the action will be called if the threshold has already been reached.
struct VideoPlayer: View {
    @State var playing: Bool


    var body: some View {
        Group {
            // ...
        }
        .onScrollVisibilityChange(threshold: 0.2) { isVisible in
            playing = isVisible
        }
    }
}

//SC
struct ExampleView: View {
    @State var backgroundImage: String = "landscape-1"
    
    let images = ["landscape-1", "landscape-2", "landscape-3", "landscape-4"]
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(images, id: \.self) { image in
                        Image(image)
                            .resizable()
                            .frame(width: 300, height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 12.0))
                            .onScrollVisibilityChange(threshold: 0.8) { visible in
                                if visible {
                                    withAnimation(.spring) {
                                        backgroundImage = image
                                    }
                                }
                            }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .frame(width: 300, height: 300)
            .padding(30)
        }
        .background {
            ZStack(alignment: .bottom) {
                Image(backgroundImage)
                    .resizable()
                    .scaledToFit()
                    .blur(radius: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 12.0))

                RoundedRectangle(cornerRadius: 12.0)
                    .stroke(.gray)
                
                Text("Scroll horizontally for more images")
                    .padding(.bottom, 10)
                    .font(.caption)
            }
        }
    }
}

// MARK: - onScrollPhaseChange(_:)
/// Adds an action to perform when the scroll phase of the first scroll view in the hierarchy changes.
/*
 A scroll gesture can be in one of four phases:
 - idle: No active scroll is occurring.
 - panning: An active scroll being driven by the user is occurring.
 - decelerating: The user has stopped driving a scroll and the scroll view is decelerating to its final target.
 - animating: The system is animating to a final target as a result of a programmatic animated scroll from using a ScrollViewReader or scrollPosition(id:anchor:) modifier.
 */
@Binding var selection: SelectionValue?

ScrollView {
    // ...
}
.onScrollPhaseChange { _, newPhase in
    if newPhase == .decelerating || newPhase == .idle {
        selection = updateSelection()
    }
}

/// whether toolbar content is hidden is determined based on the direction of the last user initiated scroll.
@Binding var hidesToolbarContent: Bool
@State private var lastOffset: CGFloat = 0.0

ScrollView {
    // ...
}
.onScrollPhaseChange { oldPhase, newPhase, context in
    if newPhase == .interacting {
        lastOffset = context.geometry.contentOffset.y
    }
    if oldPhase == .interacting, newPhase != .animating,
        context.geometry.contentOffset.y - lastOffset < 0.0
    {
        hidesToolbarContent = true
    } else {
        hidesToolbarContent = false
    }
}

///If multiple scroll views are found within the view hierarchy,
///only the first one will invoke the closure you provide and a runtime issue will be logged.
///For example, in the following view, only the vertical scroll view will have its phase changes invoke the provided closure.
VStack {
    ScrollView(.vertical) { ... }
    ScrollView(.horizontal) { ... }
}
// Runtime ERROR
.onScrollPhaseChange { ... }

//SC
struct ExampleView: View {
    @State var position: ScrollPosition = ScrollPosition(edge: .leading)
    @State var oPhase: ScrollPhase = .idle
    @State var nPhase: ScrollPhase = .idle
    @State var offset: CGFloat = 0.0
    
    let fruits = Array("🍏🍎🍐🍊🍋🍌🍉🍇🍓🫐🍈🍒🍑🥭🍍🥥🥝🍅🍆🥑")

    var body: some View {
        VStack(spacing: 16) {
            VStack {
                Text("\(oPhase) → \(nPhase)")
                Text("\(String(format: "offset: %.1f", offset))")
            }

            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    ForEach(fruits, id: \.self) { fruit in
                        FruitView(fruit: fruit)
                    }
                }
            }
            .frame(width: 500)
            .scrollPosition($position)
            .onScrollPhaseChange { oldPhase, newPhase, context in
                oPhase = oldPhase
                nPhase = newPhase
                offset = context.geometry.contentOffset.x
            }

            HStack(spacing: 20) {
                Button("Scroll to Start") {
                    withAnimation { position.scrollTo(edge: .leading) }
                }

                Button("Scroll to End") {
                    withAnimation { position.scrollTo(edge: .trailing) }
                }
            }
        }
    }
    
    struct FruitView: View {
        let fruit: Character
        
        var body: some View {
            Text(String(fruit))
                .font(.system(size: 100.0))
                .shadow(color: .black, radius: 4.0)
                .padding(10)
                .background {
                    RoundedRectangle(cornerRadius: 12.0)
                        .fill(.yellow.gradient.opacity(0.7))
                        .stroke(.gray)
                        .padding(1)
                }
        }
    }
}

// MARK: - scrollContentBackground(_:)
/// The following example hides the standard system background of the List.
List {
    Text("One")
    Text("Two")
    Text("Three")
}
.scrollContentBackground(.hidden)

//SC
///Use this modifier to show or hide the background of scrollable views
struct ExampleView: View {
    var body: some View {
        List {
            Text("Row #1")
            Text("Row #2")
            Text("Row #3")
            Text("Row #4")
        }
        .scrollContentBackground(.hidden)
        .background(.yellow.gradient)
    }
}

// MARK: - scrollClipDisabled(_:)
struct ContentView: View {
    var disabled: Bool
    let colors: [Color] = [.red, .green, .blue, .mint, .teal]


    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 20) {
                ForEach(colors, id: \.self) { color in
                    Rectangle()
                        .frame(width: 100, height: 100)
                        .foregroundStyle(color)
                        .shadow(color: .primary, radius: 20)
                }
            }
        }
        .scrollClipDisabled(disabled)
    }
}

//SC
///In this example, the ScrollView has its default clipping disabled, and a new clipping area added that extends 40 points in each side.
struct ExampleView: View {
    @State var disableClipping = false
    
    var body: some View {
        VStack {
            Toggle("Clipping Disabled", isOn: $disableClipping)

            HStack(spacing: 0) {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(0..<5) { idx in
                            Circle()
                                .fill(.green.gradient)
                                .frame(width: 100, height: 100)
                        }
                    }
                }
                .frame(width: 150)
                .border(.blue)
                .scrollClipDisabled(disableClipping)
                .padding(.horizontal, 40)
                .clipShape(Rectangle())
            }
            .frame(height: 100)
        }
    }
}

// MARK: - scrollBounceBehavior(_:axes:)
/*
 static var automatic: ScrollBounceBehavior
    The automatic behavior.
 
 static var always: ScrollBounceBehavior
    The scrollable view always bounces.
 
 static var basedOnSize: ScrollBounceBehavior
    The scrollable view bounces when its content is large enough to require scrolling.
 */

//SC
struct ExampleView: View {
    @State var always: Bool = false
    
    var body: some View {
        VStack {
            Text("Current Behavior = \(always ? ".always" : ".basedOnSize")")
            
            HStack {
                List(0..<20) { idx in
                    Text("Row of sameple data \(idx)")
                }
                .border(Color.blue)
                
                List(0..<4) { idx in
                    Text("Row of sameple data \(idx)")
                }
                .border(Color.green)
            }
            
            HStack {
                Button("Always") { always = true }
                Button("Based On Size") { always = false }
            }
        }
        .scrollBounceBehavior(always ? .always : .basedOnSize)
        .frame(width: 400, height: 200)
    }
}

// MARK: - ScrollDismissesKeyboardMode
/*
 static var automatic: ScrollDismissesKeyboardMode
    Determine the mode automatically based on the surrounding context.
 
 static var immediately: ScrollDismissesKeyboardMode
    Dismiss the keyboard as soon as scrolling starts.
 
 static var interactively: ScrollDismissesKeyboardMode
    Enable people to interactively dismiss the keyboard as part of the scroll operation.
 
 static var never: ScrollDismissesKeyboardMode
    Never dismiss the keyboard automatically as a result of scrolling.
 */

//SC
struct ExampleView: View {
    @State var text: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                TextField("Enter text", text: $text)
                    .textFieldStyle(.roundedBorder)
                
                ForEach(0..<100) { _ in
                    Text("  Sample Text")
                }
            }
            .scrollDismissesKeyboard(.immediately)
        }
    }
}

// MARK: - onGeometryChange(for:of:action:)
/// https://developer.apple.com/documentation/swiftui/view/ongeometrychange(for:of:action:)
ScrollView(.horizontal) {
    LazyHStack {
         ForEach(videos) { video in
             VideoView(video)
         }
     }
 }

struct VideoView: View {
    var video: VideoModel

    var body: some View {
        VideoPlayer(video)
            .onGeometryChange(for: Bool.self) { proxy in
                let frame = proxy.frame(in: .scrollView)
                let bounds = proxy.bounds(of: .scrollView) ?? .zero
                let intersection = frame.intersection(
                    CGRect(origin: .zero, size: bounds.size))
                let visibleHeight = intersection.size.height
                return (visibleHeight / frame.size.height) > 0.75
            } action: { isVisible in
                video.updateAutoplayingState(
                    isVisible: isVisible)
            }
    }
}

//SC
///In the following example, we use the modifier to force a view to have a size in multiples of 100 pt.
///That way, as its available spaces changes, in increases or reduces the number of drawn cells,
///but they always remain at 100x100 in size. Use the sliders to alter its container size and see how the view reacts.

struct ExampleView: View {
    @State var grid_size: CGSize = .zero
    let lineSeparation: CGFloat = 100.0
    
    var body: some View {
        ZStack(alignment: .center) {
            GridLines(separation: lineSeparation)
                .stroke(.black, style: .init(lineWidth: 2.0))
                .frame(maxWidth: grid_size.width, maxHeight: grid_size.height)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.gray.gradient)
        .onGeometryChange(for: CGSize.self) { geometry in
            
            return CGSize(width: floor(geometry.size.width / lineSeparation),
                          height: floor(geometry.size.height / lineSeparation))
            
        } action: { newSize in
            grid_size = CGSize(width: newSize.width * lineSeparation,
                               height: newSize.height * lineSeparation)
        }
    }
}

struct GridLines: Shape {
    let separation: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let vLines = Int(floor(rect.size.width / separation) - 1)
        let hLines = Int(floor(rect.size.height / separation) - 1)
        
        return Path { path in
            path.addRoundedRect(in: rect, cornerSize: CGSize(width: 12.0, height: 12.0))
            
            if vLines > 0 {
                for i in 0..<vLines {
                    let x = separation * CGFloat(i+1)
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: rect.maxY))
                }
            }
            
            if hLines > 0 {
                for i in 0..<hLines {
                    let y = separation * CGFloat(i+1)
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: rect.maxX, y: y))
                }
            }
            
        }
    }
}

// MARK: - 250418 View Groupings
/// Present views in different kinds of purpose-driven containers, like forms or control groups.

// MARK: - Group
// A type that collects multiple instances of a content type — like views, scenes, or commands — into a single unit.

/*
 Use a group to collect multiple views into a single instance, without affecting the layout of those views, like an HStack, VStack, or Section would. After creating a group, any modifier you apply to the group affects all of that group’s members. For example, the following code applies the headline font to three views in a group.
 */

Group {
    Text("SwiftUI")
    Text("Combine")
    Text("Swift System")
}
.font(.headline)

/// -> The modifier applies to all members of the group —
///  and NOT to the group itself. For example, if you apply onAppear(perform:) to the above group,
///  it applies to all of the views produced by the if isLoggedIn conditional, and it executes every time isLoggedIn changes.
Group {
    if isLoggedIn {
        WelcomeView()
    } else {
        LoginView()
    }
}
.navigationBarTitle("Start")

// MARK: - SectionConfiguration
/// https://developer.apple.com/documentation/swiftui/sectionconfiguration
PinboardSectionsLayout {
    ForEach(sections: content) { section in
        VStack {
            HStack { section.header }
            section.content
            HStack { section.footer }
        }
    }
}

// MARK: - ForEach
private struct NamedFont: Identifiable {
    let name: String
    let font: Font
    var id: String { name }
}

private let namedFonts: [NamedFont] = [
    NamedFont(name: "Large Title", font: .largeTitle),
    NamedFont(name: "Title", font: .title),
    NamedFont(name: "Headline", font: .headline),
    NamedFont(name: "Body", font: .body),
    NamedFont(name: "Caption", font: .caption)
]

var body: some View {
    ForEach(namedFonts) { namedFont in
        Text(namedFont.name)
            .font(namedFont.font)
    }
}

/// Some containers like List or LazyVStack will query the elements within a for each lazily. To obtain maximal performance, ensure that the view created from each element in the collection represents a constant number of views.
ForEach(namedFonts) { namedFont in
    if namedFont.name.count != 2 {
        Text(namedFont.name)
    }
}

ForEach(namedFonts) { namedFont in
    VStack {
        if namedFont.name.count != 2 {
            Text(namedFont.name)
        }
    }
}

// MARK: - ContainerValueKey
private struct MyContainerValueKey: ContainerValueKey {
    static let defaultValue: String = "Default value"
}

extension ContainerValues {
    var myCustomValue: String {
        get { self[MyContainerValueKey.self] }
        set { self[MyContainerValueKey.self] = newValue }
    }
}

MyView()
    .containerValue(\.myCustomValue, "Another string")

// Helper
extension View {
    func myCustomValue(_ myCustomValue: String) -> some View {
        containerValue(\.myCustomValue, myCustomValue)
    }
}

MyView()
    .myCustomValue("Another string")

/// To read the container value, use Group(subviews:) on a containing view,
/// and then access the container value on members of that collection.
@ViewBuilder var content: some View {
    Text("A").myCustomValue("Hello")
    Text("B").myCustomValue("World")
}

Group(subviews: content) { subviews in
    ForEach(subviews) { subview in
        Text(subview.containerValues.myCustomValue)
    }
}

/// In practice, this will mostly be used by views that contain multiple other views to extract information from their subviews.
/// You could turn the example above into such a container view as follows:
struct MyContainer<Content: View>: View {
    var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        Group(subviews: content) { subviews in
            ForEach(subviews) { subview in
                // Display each view side-by-side with its custom value.
                HStack {
                    subview
                    Text(subview.containerValues.myCustomValue)
                }
            }
        }
    }
}

// Using Entry
extension ContainerValues {
    @Entry var isDisplayBoardCardRejected: Bool = false
    @Entry var displayBoardCardPinColor: Color?
    @Entry var displayBoardCardPosition: UnitPoint?
    @Entry var displayBoardCardRotation: Angle?
}

extension View {
    func displayBoardCardRejected(_ isRejected: Bool) -> some View {
        containerValue(\.isDisplayBoardCardRejected, isRejected)
    }

    func displayBoardCardPinColor(_ pinColor: Color?) -> some View {
        containerValue(\.displayBoardCardPinColor, pinColor)
    }

    func displayBoardCardPosition(_ position: UnitPoint?) -> some View {
        containerValue(\.displayBoardCardPosition, position)
    }

    func displayBoardCardRotation(_ rotation: Angle?) -> some View {
        containerValue(\.displayBoardCardRotation, rotation)
    }
}

// MARK: - GroupBox
/*
 Use a group box when you want to visually distinguish a portion of your user interface with an optional title for the boxed content.

 The following example sets up a GroupBox with the label “End-User Agreement”, and a long agreementText string in a Text view wrapped by a ScrollView. The box also contains a Toggle for the user to interact with after reading the text.
 */

var body: some View {
    GroupBox(label:
        Label("End-User Agreement", systemImage: "building.columns")
    ) {
        ScrollView(.vertical, showsIndicators: true) {
            Text(agreementText)
                .font(.footnote)
        }
        .frame(height: 100)
        Toggle(isOn: $userAgreed) {
            Text("I agree to the above terms")
        }
    }
}

// MARK: - Form
/// A container for grouping controls used for data entry, such as in settings or inspectors.
var body: some View {
    NavigationView {
        Form {
            Section(header: Text("Notifications")) {
                Picker("Notify Me About", selection: $notifyMeAbout) {
                    Text("Direct Messages").tag(NotifyMeAboutType.directMessages)
                    Text("Mentions").tag(NotifyMeAboutType.mentions)
                    Text("Anything").tag(NotifyMeAboutType.anything)
                }
                Toggle("Play notification sounds", isOn: $playNotificationSounds)
                Toggle("Send read receipts", isOn: $sendReadReceipts)
            }
            Section(header: Text("User Profiles")) {
                Picker("Profile Image Size", selection: $profileImageSize) {
                    Text("Large").tag(ProfileImageSize.large)
                    Text("Medium").tag(ProfileImageSize.medium)
                    Text("Small").tag(ProfileImageSize.small)
                }
                Button("Clear Image Cache") {}
            }
        }
    }
}

// MARK: - ControlGroup
/// A container view that displays semantically-related controls in a visually-appropriate manner for the context
/// https://swiftwithmajid.com/2021/10/21/mastering-controlgroup-in-swiftui/

extension ControlGroupStyle where Self == ControlGroupWithTitle {
    static func with(title: LocalizedStringKey) -> ControlGroupWithTitle {
        ControlGroupWithTitle(title: title)
    }
}

struct ContentView: View {
    var body: some View {
        ControlGroup {
            Button("Action 1") {}
            Button("Action 2") {}
        }.controlGroupStyle(.with(title: "Actions"))
    }
}

/// You can provide an optional label to this view that describes its children. This view may be used in different ways depending on the surrounding context. For example, when you place the control group in a toolbar item, SwiftUI uses the label when the group is moved to the toolbar’s overflow menu.
ContentView()
    .toolbar(id: "items") {
        ToolbarItem(id: "media") {
            ControlGroup {
                MediaButton()
                ChartButton()
                GraphButton()
            } label: {
                Label("Plus", systemImage: "plus")
            }
        }
    }

// MARK: - 250417 PoissonDiskLayout With LayoutCache
struct DisplayBoardCardLayout<Content: View>: View {
    @ViewBuilder var content: Content
    
    var body: some View {
        PoissonDiskLayout(
            sampleAnchor: UnitPoint(x: 0.4, y: 0.3),
            sampleRadius: 150
        ) {
            content
        }
        .padding(EdgeInsets(top: 88, leading: 66, bottom: 22, trailing: 66))
    }
}

struct DisplayBoardSectionCardLayout<Content: View>: View {
    @ViewBuilder var content: Content
    
    @State private var sectionSeed: UInt64 = 0
    
    var body: some View {
        PoissonDiskLayout(
            sampleAnchor: UnitPoint(x: 0.2, y: 0.1),
            sampleRadius: 88,
            randomSeed: sectionSeed
        ) {
            content
        }
        .padding(EdgeInsets(top: 66, leading: 66, bottom: 22, trailing: 66))
        .task {
            let offset = sectionRandomSeedOffset
            sectionRandomSeedOffset += 1
            sectionSeed = DisplayBoardRandomGenerator.defaultSeed(offsetBy: offset)
        }
    }
}

@MainActor
private var sectionRandomSeedOffset: UInt64 = 0

// MARK: - Poisson Disk Layout
/// A layout that positions its contents randomly, maintaining a minimum
/// distance between any two positions.
///
/// If there is no more space to fit new subviews and still maintain the minimum
/// distance, then the minimum distance gradually shrinks until new positions
/// become available, filling in the gaps between existing positions.
private struct PoissonDiskLayout: Layout {
    struct Cache {
        var sampler: PoissonDiskSampler
        var randomNumberGenerator: DisplayBoardRandomGenerator
    }
    
    var sampleAnchor: UnitPoint = .center
    var sampleRadius: CGFloat
    var sampleSpacing: ClosedRange<CGFloat> = 0...20
    var randomSeed: UInt64 = 0

    func makeCache(samplerSize: CGSize) -> Cache {
        let sampler = PoissonDiskSampler(
            bounds: CGRect(
                origin: CGPoint(
                    x: -0.5 * samplerSize.width,
                    y: -0.5 * samplerSize.height),
                size: samplerSize),
            minDistance: 2 * sampleRadius)
        
        let randomNumberGenerator = DisplayBoardRandomGenerator(seed: randomSeed)
        return Cache(sampler: sampler, randomNumberGenerator: randomNumberGenerator)
    }
    
    func makeCache(subviews: Subviews) -> Cache {
        makeCache(samplerSize: .zero)
    }
    
    func updateCache(_ cache: inout Cache, subviews: Subviews) {
        // Pick a starting location.
        if cache.sampler.samples.isEmpty {
            cache.sampler.sample(at: CGPoint(
                x: sampleAnchor.x * cache.sampler.bounds.width,
                y: sampleAnchor.y * cache.sampler.bounds.height))
        }
        
        // Try to find enough positions for all subviews.
        cache.sampler.fill(
            upToCount: subviews.count,
            spacing: sampleSpacing,
            using: &cache.randomNumberGenerator)
    }
    
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }
    
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) {
        if cache.sampler.bounds.size != bounds.size {
            cache = makeCache(samplerSize: bounds.size)
            updateCache(&cache, subviews: subviews)
        }
        
        for (index, subview) in subviews.enumerated() {
            var position: CGPoint = .zero
            
            // Prefer the position configured via container values, if it
            // exists. Otherwise, use the default calculated position.
            if let currentPosition = subview.containerValues.displayBoardCardPosition {
                position = CGPoint(
                    x: currentPosition.x * bounds.width,
                    y: currentPosition.y * bounds.height)
            } else if !cache.sampler.samples.isEmpty {
                position = cache.sampler.samples[index % cache.sampler.samples.count]
            }
            
            position.x += bounds.midX
            position.y += bounds.midY
            
            // Propose a default card size that would avoid collisions with
            // other cards at the same default size. Note that this is just a
            // default proposal: cards may size themselves differently based on
            // their content, and so collisions are always possible, but that's
            // acceptable for intended aesthetic of the display board.
            let proposedCardSize = ProposedViewSize(
                width: cache.sampler.minDistance,
                height: cache.sampler.minDistance)
            
            subview.place(at: position, anchor: .center, proposal: proposedCardSize)
        }
    }
}

// MARK: - Poisson Disk Sampling
private struct PoissonDiskSampler {
    let bounds: CGRect
    private(set) var minDistance: CGFloat
    private(set) var samples: [CGPoint] = []
    
    /// Indices for elements in `samples` that are assumed to no longer have any
    /// valid candidate positions in range, based on previous searches.
    private var inactiveIndices = RangeSet<Int>()
    
    init(bounds: CGRect, minDistance: CGFloat) {
        self.bounds = bounds
        self.minDistance = minDistance
    }
    
    /// Returns whether the given point is within `bounds` and not too close to
    /// any existing sample.
    func isValidPoint(_ point: CGPoint) -> Bool {
        guard bounds.contains(point) else { return false }
        guard !samples.isEmpty else { return true }
        
        let minDistanceSquared = (minDistance * minDistance)
        
        return samples.allSatisfy { sample in
            let deltaX = sample.x - point.x
            let deltaY = sample.y - point.y
            return (deltaX * deltaX) + (deltaY * deltaY) >= minDistanceSquared
        }
    }
    
    mutating func fill(
        upToCount count: Int,
        spacing: ClosedRange<CGFloat> = 0...0,
        using rng: inout some RandomNumberGenerator
    ) {
        var delta = count - samples.count
        while delta > 0 {
            if sample(spacing: spacing, using: &rng) != nil {
                delta -= 1
            } else {
                let distance = 0.9 * minDistance
                guard distance >= 10 else { break }
                minDistance = distance
                inactiveIndices = .init()
            }
        }
    }
    
    @discardableResult
    mutating func sample(at point: CGPoint) -> CGPoint? {
        guard isValidPoint(point) else { return nil }
        samples.append(point)
        return point
    }
    
    @discardableResult
    mutating func sample(
        spacing: ClosedRange<CGFloat> = 0...0,
        using rng: inout some RandomNumberGenerator
    ) -> CGPoint? {
        guard !samples.isEmpty else { return sample(at: .zero) }
        
        let lowerBound = minDistance + spacing.lowerBound
        let upperBound = minDistance + spacing.upperBound
        let distanceBounds = lowerBound...upperBound
        
        // Choose an active sample.
        while let index = samples.indices.removingSubranges(inactiveIndices).first {
            let sample = samples[index]
            
            // Test random candidates within the search radius range.
            for _ in 0 ..< 20 {
                let direction: Angle = .degrees(.random(in: 0..<360, using: &rng))
                let distance: CGFloat = .random(in: distanceBounds, using: &rng)
                let candidate = CGPoint(
                    x: sample.x + distance * cos(direction.radians),
                    y: sample.y + distance * sin(direction.radians))
                
                if let point = self.sample(at: candidate) {
                    return point
                }
            }
            
            // No valid candidates found, deactivate sample.
            inactiveIndices.insert(index, within: samples)
        }
        
        return nil
    }
}

#Preview("Circles", traits: .landscapeLeft) {
    PoissonDiskLayout(sampleAnchor: .center, sampleRadius: 44) {
        ForEach(0 ..< 30) { _ in
            CircleAreaView()
        }
    }
    .border(.red)
    .padding(100)
    .ignoresSafeArea()
}

#Preview("Cards", traits: .landscapeLeft) {
    DisplayBoardCardLayout {
        ForEach(0 ..< 30) { _ in
            CardView {
                Text("Hello")
            }
        }
    }
    .border(.red)
    .padding(100)
    .ignoresSafeArea()
}

private struct CircleAreaView: View {
    var body: some View {
        ZStack {
            ZStack {
                Circle()
                    .fill(.quaternary.opacity(0.5))
                Circle()
                    .stroke(.secondary)
            }
            Circle()
                .fill(.primary)
                .frame(width: 5, height: 5)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(.blue)
    }
}

// MARK: - Random Number Generator
//import SwiftUI
//import GameplayKit

final class DisplayBoardRandomGenerator: RandomNumberGenerator {
    private var randomSource: any GKRandom
    
    init(seed: UInt64? = defaultSeed) {
        randomSource = seed.map {
            GKMersenneTwisterRandomSource(seed: $0)
        } ?? GKMersenneTwisterRandomSource()
    }
    
    func next() -> UInt64 {
        let high = UInt64(bitPattern: Int64(randomSource.nextInt()))
        let low = UInt64(bitPattern: Int64(randomSource.nextInt()))
        return (high << 32) ^ low
    }
    
    nonisolated static let defaultSeed: UInt64 = 415
    
    nonisolated static func defaultSeed(offsetBy offset: UInt64) -> UInt64 {
        defaultSeed + offset
    }
}

final class CardRandomGenerator {
    @MainActor
    static let main = CardRandomGenerator()
    
    private static let pinColors: [Color] = [
        .blue, .red, .green, .orange, .cyan, .purple, .yellow, .brown
    ]
    
    private var randomSource: any GKRandom
    private var cardRotationDistribution: GKRandomDistribution
    private var cardPinColorDistribution: GKRandomDistribution
    
    init(seed: UInt64? = DisplayBoardRandomGenerator.defaultSeed) {
        randomSource = seed.map { GKMersenneTwisterRandomSource(seed: $0) }
            ?? GKMersenneTwisterRandomSource()
        
        cardRotationDistribution = GKShuffledDistribution(
            randomSource: randomSource,
            lowestValue: 1,
            highestValue: 20)
        
        cardPinColorDistribution = GKShuffledDistribution(
            randomSource: randomSource,
            lowestValue: 0,
            highestValue: Self.pinColors.count - 1)
    }
    
    func nextCardRotation() -> Angle {
        let rotation = Double(cardRotationDistribution.nextUniform())
        return .degrees(rotation * 14.0 - 7.0)
    }
    
    func nextCardPinColor() -> Color {
        Self.pinColors[cardPinColorDistribution.nextInt()]
    }
}

// MARK: - 250417 Tables
// Display selectable, sortable data arranged in rows and columns.
/// https://developer.apple.com/documentation/swiftui/tables

struct Person: Identifiable {
    let givenName: String
    let familyName: String
    let emailAddress: String
    let id = UUID()

    var fullName: String { givenName + " " + familyName }
}

@State private var people = [
    Person(givenName: "Juan", familyName: "Chavez", emailAddress: "juanchavez@icloud.com"),
    Person(givenName: "Mei", familyName: "Chen", emailAddress: "meichen@icloud.com"),
    Person(givenName: "Tom", familyName: "Clark", emailAddress: "tomclark@icloud.com"),
    Person(givenName: "Gita", familyName: "Kumar", emailAddress: "gitakumar@icloud.com")
]

struct PeopleTable: View {
    var body: some View {
        Table(people) {
            TableColumn("Given Name", value: \.givenName)
            TableColumn("Family Name", value: \.familyName)
            TableColumn("E-Mail Address", value: \.emailAddress)
        }
    }
}

/*
 If there are more rows than can fit in the available space, Table provides vertical scrolling automatically. On macOS, the table also provides horizontal scrolling if there are more columns than can fit in the width of the view. Scroll bars appear as needed on iOS; on macOS, the Table shows or hides scroll bars based on the “Show scroll bars” system preference.
 */

var table: some View {
    Table(selection: $selection, sortOrder: $sortOrder) {
        TableColumn("Variety", value: \.variety)

        TableColumn("Days to Maturity", value: \.daysToMaturity) { plant in
            Text(plant.daysToMaturity.formatted())
        }

        TableColumn("Date Planted", value: \.datePlanted) { plant in
            Text(plant.datePlanted.formatted(date: .abbreviated, time: .omitted))
        }

        TableColumn("Harvest Date", value: \.harvestDate) { plant in
            Text(plant.harvestDate.formatted(date: .abbreviated, time: .omitted))
        }

        TableColumn("Last Watered", value: \.lastWateredOn) { plant in
            Text(plant.lastWateredOn.formatted(date: .abbreviated, time: .omitted))
        }

        TableColumn("Favorite", value: \.favorite, comparator: BoolComparator()) { plant in
            Toggle("Favorite", isOn: $garden[plant.id].favorite)
                .labelsHidden()
        }
        .width(50)
    } rows: {
        ForEach(plants) { plant in
            TableRow(plant)
                .itemProvider { plant.itemProvider }
        }
        .onInsert(of: [Plant.draggableType]) { index, providers in
            Plant.fromItemProviders(providers) { plants in
                garden.plants.insert(contentsOf: plants, at: index)
            }
        }
    }
}

// MARK: - Building tables with static rows
struct Purchase: Identifiable {
    let price: Decimal
    let id = UUID()
}

struct TipTable: View {
    let currencyStyle = Decimal.FormatStyle.Currency(code: "USD")

    var body: some View {
        Table(of: Purchase.self) {
            TableColumn("Base price") { purchase in
                Text(purchase.price, format: currencyStyle)
            }
            TableColumn("With 15% tip") { purchase in
                Text(purchase.price * 1.15, format: currencyStyle)
            }
            TableColumn("With 20% tip") { purchase in
                Text(purchase.price * 1.2, format: currencyStyle)
            }
            TableColumn("With 25% tip") { purchase in
                Text(purchase.price * 1.25, format: currencyStyle)
            }
        } rows: {
            TableRow(Purchase(price: 20))
            TableRow(Purchase(price: 50))
            TableRow(Purchase(price: 75))
        }
    }
}

// MARK: - Using tables on different platforms
/*
 You can define a single table for use on macOS, iOS, and iPadOS. However, on iPhone or in a compact horizontal size class environment — typical on on iPad in certain modes, like Slide Over — the table has limited space to display its columns. To conserve space, the table automatically hides headers and all columns after the first when it detects this condition.

 To provide a good user experience in a space-constrained environment, you can customize the first column to show more information when you detect that the horizontalSizeClass environment value becomes UserInterfaceSizeClass.compact. For example, you can modify the sortable table from above to conditionally show all the information in the first column:
 */
struct CompactableTable: View {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isCompact: Bool { horizontalSizeClass == .compact }
    #else
    private let isCompact = false
    #endif

    @State private var sortOrder = [KeyPathComparator(\Person.givenName)]

    var body: some View {
        Table(people, sortOrder: $sortOrder) {
            TableColumn("Given Name", value: \.givenName) { person in
                VStack(alignment: .leading) {
                    Text(isCompact ? person.fullName : person.givenName)
                    if isCompact {
                        Text(person.emailAddress)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            TableColumn("Family Name", value: \.familyName)
            TableColumn("E-Mail Address", value: \.emailAddress)
        }
        .onChange(of: sortOrder) { _, sortOrder in
            people.sort(using: sortOrder)
        }
    }
}

// MARK: - TableColumn
TableColumn("Given name", value: \.givenName) { person in
    Text(person.givenName)
}

/// For the common case of String properties, you can use the convenience initializer that doesn’t require an explicit content closure and displays that string verbatim as a Text view. This means you can write the previous example as:
TableColumn("Given name", value: \.givenName)

// MARK: - TableColumnContent
/*
 This type provides the body content of the column, as well as the types of the column’s row values and the comparator used to sort rows.

 You can factor column content out into separate types or properties, or by creating a custom type conforming to TableColumnContent.
 */

var body: some View {
    Table(people, selection: $selectedPeople, sortOrder: $sortOrder) {
        nameColumns
        TableColumn("Location", value: \.location) {
            LocationView($0.location)
        }
    }
}

@TableColumnBuilder<Person, KeyPathComparator<Person>>
private var nameColumns: some TableColumnContent<
    Person, KeyPathComparator<Person>
> {
    TableColumn("First Name", value: \.firstName) {
        PrimaryColumnView(person: $0)
    }
    TableColumn("Last Name", value: \.lastName)
    TableColumn("Nickname", value: \.nickname)
}

// MARK: - TableColumnForEach
/*
 Use TableColumnForEach to create columns based on a RandomAccessCollection of some data type. Either the collection’s elements must conform to Identifiable or you need to provide an id parameter to the TableColumnForEach initializer.

 The following example shows the interface for an AudioSampleTrack, which h as a collection of AudioSample across a dynamic number of AudioChannels. The Table is created for displaying rows for each sample. It has one static column for the sample’s timestamp and uses a TableColumnForEach instance to produce a column for each of the audio channels in the track.
 */

struct AudioChannel: Identifiable {
    let name: String
    let id: UUID
}

struct AudioSample: Identifiable {
    let id: UUID
    let timestamp: TimeInterval
    func level(channel: AudioChannel.ID) -> Double
}

@Observable
class AudioSampleTrack {
    let channels: [AudioChannel]
    var samples: some RandomAccessCollection<AudioSample> { get }
}

struct ContentView: View {
    var track: AudioSampleTrack

    var body: some View {
        Table(track.samples) {
            TableColumn("Timestamp (ms)") { sample in
                Text(sample.timestamp, format: .number.scale(1000))
                    .monospacedDigit()
            }
            TableColumnForEach(track.channels) { channel in
                TableColumn(channel.name) { sample in
                    Text(sample.level(channel: channel.id),
                         format: .number.precision(.fractionLength(2))
                    )
                    .monospacedDigit()
                }
                .width(ideal: 70)
                .alignment(.numeric)
            }
        }
    }
}

// MARK: - Supporting selection in tables
struct SelectableTable: View {
    @State private var selectedPeople = Set<Person.ID>()
    
    var body: some View {
        Table(people, selection: $selectedPeople) {
            TableColumn("Given Name", value: \.givenName)
            TableColumn("Family Name", value: \.familyName)
            TableColumn("E-Mail Address", value: \.emailAddress)
        }
        Text("\(selectedPeople.count) people selected")
    }
}

// MARK: - Supporting sorting in tables
struct SortableTable: View {
    @State private var sortOrder = [KeyPathComparator(\Person.givenName)]

    var body: some View {
        Table(people, sortOrder: $sortOrder) {
            TableColumn("Given Name", value: \.givenName)
            TableColumn("Family Name", value: \.familyName)
            TableColumn("E-Mail address", value: \.emailAddress)
        }
        .onChange(of: sortOrder) { _, sortOrder in
            people.sort(using: sortOrder)
        }
    }
}

// MARK: - tableColumnHeaders
Table(article.authors) {
    TableColumn("Name", value: \.name)
    TableColumn("Title", value: \.title)
}
.tableColumnHeaders(.hidden)


// MARK: - TableColumnCustomization
/*
 TableColumnCustomization can be created and provided to a table to enable column reordering and column visibility. The state can be queried and updated programmatically, as well as bound to persistent app or scene storage.
 */

struct BugReportTable: View {
    @ObservedObject var dataModel: DataModel
    @Binding var selectedBugReports: Set<BugReport.ID>

    @SceneStorage("BugReportTableConfig")
    private var columnCustomization: TableColumnCustomization<BugReport>

    var body: some View {
        Table(dataModel.bugReports, selection: $selectedBugReports,
            sortOrder: $dataModel.sortOrder,
            columnCustomization: $columnCustomization
        ) {
            TableColumn("Title", value: \.title)
                .customizationID("title")
            
            TableColumn("ID", value: \.id) {
                Link("\($0.id)", destination: $0.url)
            }
            .customizationID("id")
            
            TableColumn("Number of Reports", value: \.duplicateCount) {
                Text($0.duplicateCount, format: .number)
            }
            .customizationID("duplicates")
        }
    }
}

/*
 The state of a specific column is stored relative to its customization identifier, using using the value from the customizationID(_:) modifier. When column customization is encoded and decoded, it relies on stable identifiers to restore the associate the saved state with a specific column. If a table column does not have a customization identifier, it will not be customizable.

 These identifiers can also be used to programmatically change column customizations, such as programmatically hiding a column:
 */
columnCustomization[visibility: "duplicates"] = .hidden

/// With a binding to the overall customization, a binding to the visibility of a column can be accessed using the same subscript syntax:
struct BugReportTable: View {
    @SceneStorage("BugReportTableConfig")
    private var columnCustomization: TableColumnCustomization<BugReport>

    var body: some View {
        ...
        MyVisibilityView($columnCustomization[visibility: "duplicates"])
    }
}

struct MyVisibilityView: View {
    @Binding var visibility: Visibility
    ...
}

// MARK: - TableRowContent
struct GroupOfPeopleRows: TableRowContent {
    @Binding var people: [Person]

    var tableRowBody: some TableRowContent<Person> {
        ForEach(people) { person in
            TableRow(person)
                .itemProvider { person.itemProvider }
        }
        .dropDestination(for: Person.self) { destination, newPeople in
            people.insert(contentsOf: newPeople, at: destination)
        }
    }
}

// MARK: - DisclosureTableRow
/*
 A disclosure group row consists of a label row that is always visible, and some content rows that are conditionally visible depending on the state. Toggling the control will flip the state between “expanded” and “collapsed”.

 In the following example, a disclosure group has allDevices as the label row, and exposes its expanded state with the bound property, expanded. Upon toggling the disclosure control, the user can update the expanded state which will in turn show or hide the three content rows for iPhone, iPad, and Mac.
 */

private struct DeviceStats: Identifiable {
    // ...
}
@State private var expanded: Bool = true
@State private var allDevices: DeviceStats = /* ... */
@State private var iPhone: DeviceStats = /* ... */
@State private var iPad: DeviceStats = /* ... */
@State private var Mac: DeviceStats = /* ... */

var body: some View {
    Table(of: DeviceStats.self) {
        // ...
    } rows: {
        DisclosureTableRow(allDevices, isExpanded: $expanded) {
            TableRow(iPhone)
            TableRow(iPad)
            TableRow(Mac)
        }
    }
}

// MARK: - 250416 Lists
// Display a structured, scrollable column of information.
/// https://developer.apple.com/documentation/swiftui/lists

struct Person: Identifiable {
     let id = UUID()
     var name: String
     var phoneNumber: String
 }


var staff = [
    Person(name: "Juan Chavez", phoneNumber: "(408) 555-4301"),
    Person(name: "Mei Chen", phoneNumber: "(919) 555-2481")
]

struct StaffList: View {
    var body: some View {
        List {
            ForEach(staff) { person in
                Text(person.name)
            }
        }
    }
}

struct PersonRowView: View {
    var person: Person

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(person.name)
                .foregroundColor(.primary)
                .font(.headline)
            HStack(spacing: 3) {
                Label(person.phoneNumber, systemImage: "phone")
            }
            .foregroundColor(.secondary)
            .font(.subheadline)
        }
    }
}

struct StaffList: View {
    var body: some View {
        List {
            ForEach(staff) { person in
                PersonRowView(person: person)
            }
        }
    }
}

// MARK: - Plain List Style
private extension ServiceListView {
    var servicesListView: some View {
        List(services) { service in
            LXGeneralSummaryCell(
                cellWidth: containerWidth,
                viewConfig: getCardConfig(for: service)
            ) { actionType in
                didTapServiceSummaryCard(
                    actionType: actionType,
                    service: service
                )
            }
            .listRowInsets(.lxZero)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button {
                    serviceToDelete = service
                    isShowingServiceDeleteConfirmation = true
                } label: {
                    Image(systemSymbol: .trash)
                }
                .tint(.LX.redColor.color)
            }
        }
        .listStyle(.plain)
    }
}

// MARK: - Represent data hierarchy with sections
struct Department: Identifiable {
    let id = UUID()
    var name: String
    var staff: [Person]
}

struct Company {
    var departments: [Department]
}

var company = Company(departments: [
    Department(name: "Sales", staff: [
        Person(name: "Juan Chavez", phoneNumber: "(408) 555-4301"),
        Person(name: "Mei Chen", phoneNumber: "(919) 555-2481"),
        // ...
    ]),
    Department(name: "Engineering", staff: [
        Person(name: "Bill James", phoneNumber: "(408) 555-4450"),
        Person(name: "Anne Johnson", phoneNumber: "(417) 555-9311"),
        // ...
    ]),
    // ...
])

List {
    ForEach(company.departments) { department in
        Section(header: Text(department.name)) {
            ForEach(department.staff) { person in
                PersonRowView(person: person)
            }
        }
    }
}

/*
 The following example sets up a navigation-based UI by wrapping the list with a navigation view.
 Instances of NavigationLink wrap the list’s rows to provide a destination view to navigate to when the user taps the row.
 If a split view navigation is appropriate for the platform,
 the right panel initially contains the “No Selection” placeholder view,
 which the navigation view replaces with the destination view when the user makes a selection.
 */
NavigationView {
    List {
        ForEach(company.departments) { department in
            Section(header: Text(department.name)) {
                ForEach(department.staff) { person in
                    NavigationLink(destination: PersonDetailView(person: person)) {
                        PersonRowView(person: person)
                    }
                }
            }
        }
    }
    .navigationTitle("Staff Directory")


    // Placeholder
    Text("No Selection")
        .font(.headline)
}

struct PersonDetailView: View {
    var person: Person


    var body: some View {
        VStack {
            Text(person.name)
                .foregroundColor(.primary)
                .font(.title)
                .padding()
            HStack {
                Label(person.phoneNumber, systemImage: "phone")
            }
            .foregroundColor(.secondary)
        }
    }
}

// MARK: - List
/// A container that presents rows of data arranged in a single column, optionally providing the ability to select one or more members.
var body: some View {
    List {
        Text("A List Item")
        Text("A Second List Item")
        Text("A Third List Item")
    }
}

struct Ocean: Identifiable {
    let name: String
    let id = UUID()
}


private var oceans = [
    Ocean(name: "Pacific"),
    Ocean(name: "Atlantic"),
    Ocean(name: "Indian"),
    Ocean(name: "Southern"),
    Ocean(name: "Arctic")
]


var body: some View {
    List(oceans) {
        Text($0.name)
    }
}

struct Ocean: Identifiable, Hashable {
    let name: String
    let id = UUID()
}

private var oceans = [
    Ocean(name: "Pacific"),
    Ocean(name: "Atlantic"),
    Ocean(name: "Indian"),
    Ocean(name: "Southern"),
    Ocean(name: "Arctic")
]

// MARK: - Supporting selection in lists
@State private var multiSelection = Set<UUID>()

var body: some View {
    NavigationView {
        List(oceans, selection: $multiSelection) {
            Text($0.name)
        }
        .navigationTitle("Oceans")
        .toolbar { EditButton() }
    }
    Text("\(multiSelection.count) selections")
}

// MARK: - Refreshing the list content
struct Ocean: Identifiable, Hashable {
    let name: String
    let id = UUID()
    let stats: [String: String]
}

class OceanStore: ObservableObject {
    @Published var oceans = [Ocean]()
    func loadStats() async {}
}

@EnvironmentObject var store: OceanStore
var body: some View {
    NavigationView {
        List(store.oceans) { ocean in
            HStack {
                Text(ocean.name)
                StatsSummary(stats: ocean.stats) // A custom view for showing statistics.
            }
        }
        .refreshable {
            await store.loadStats()
        }
        .navigationTitle("Oceans")
    }
}

// MARK: - Supporting multidimensional lists
struct ContentView: View {
    struct Sea: Hashable, Identifiable {
        let name: String
        let id = UUID()
    }

    struct OceanRegion: Identifiable {
        let name: String
        let seas: [Sea]
        let id = UUID()
    }

    private let oceanRegions: [OceanRegion] = [
        OceanRegion(name: "Pacific",
                    seas: [Sea(name: "Australasian Mediterranean"),
                           Sea(name: "Philippine"),
                           Sea(name: "Coral"),
                           Sea(name: "South China")]),
        OceanRegion(name: "Atlantic",
                    seas: [Sea(name: "American Mediterranean"),
                           Sea(name: "Sargasso"),
                           Sea(name: "Caribbean")]),
        OceanRegion(name: "Indian",
                    seas: [Sea(name: "Bay of Bengal")]),
        OceanRegion(name: "Southern",
                    seas: [Sea(name: "Weddell")]),
        OceanRegion(name: "Arctic",
                    seas: [Sea(name: "Greenland")])
    ]


    @State private var singleSelection: UUID?
    
    var body: some View {
        NavigationView {
            List(selection: $singleSelection) {
                ForEach(oceanRegions) { region in
                    Section(header: Text("Major \(region.name) Ocean Seas")) {
                        ForEach(region.seas) { sea in
                            Text(sea.name)
                        }
                    }
                }
            }
            .navigationTitle("Oceans and Seas")
        }
    }
}

// MARK: - Creating hierarchical lists
struct ContentView: View {
    struct FileItem: Hashable, Identifiable, CustomStringConvertible {
        var id: Self { self }
        var name: String
        var children: [FileItem]? = nil
        var description: String {
            switch children {
            case nil:
                return "📄 \(name)"
            case .some(let children):
                return children.isEmpty ? "📂 \(name)" : "📁 \(name)"
            }
        }
    }
    let fileHierarchyData: [FileItem] = [
      FileItem(name: "users", children:
        [FileItem(name: "user1234", children:
          [FileItem(name: "Photos", children:
            [FileItem(name: "photo001.jpg"),
             FileItem(name: "photo002.jpg")]),
           FileItem(name: "Movies", children:
             [FileItem(name: "movie001.mp4")]),
              FileItem(name: "Documents", children: [])
          ]),
         FileItem(name: "newuser", children:
           [FileItem(name: "Documents", children: [])
           ])
        ]),
        FileItem(name: "private", children: nil)
    ]
    var body: some View {
        List(fileHierarchyData, children: \.children) { item in
            Text(item.description)
        }
    }
}

// MARK: - Outline Group
struct FileItem: Hashable, Identifiable, CustomStringConvertible {
    var id: Self { self }
    var name: String
    var children: [FileItem]? = nil
    var description: String {
        switch children {
        case nil:
            return "📄 \(name)"
        case .some(let children):
            return children.isEmpty ? "📂 \(name)" : "📁 \(name)"
        }
    }
}

let data =
  FileItem(name: "users", children:
    [FileItem(name: "user1234", children:
      [FileItem(name: "Photos", children:
        [FileItem(name: "photo001.jpg"),
         FileItem(name: "photo002.jpg")]),
       FileItem(name: "Movies", children:
         [FileItem(name: "movie001.mp4")]),
          FileItem(name: "Documents", children: [])
      ]),
     FileItem(name: "newuser", children:
       [FileItem(name: "Documents", children: [])
       ])
    ])

OutlineGroup(data, children: \.children) { item in
    Text("\(item.description)")
}

// MARK: - DisclosureGroup
struct ToggleStates {
    var oneIsOn: Bool = false
    var twoIsOn: Bool = true
}
@State private var toggleStates = ToggleStates()
@State private var topExpanded: Bool = true


var body: some View {
    DisclosureGroup("Items", isExpanded: $topExpanded) {
        Toggle("Toggle 1", isOn: $toggleStates.oneIsOn)
        Toggle("Toggle 2", isOn: $toggleStates.twoIsOn)
        DisclosureGroup("Sub-items") {
            Text("Sub-item 1")
        }
    }
}

// MARK: - badge(_:)
/*
 Use a badge to convey optional, supplementary information about a view. Keep the contents of the badge as short as possible. Badges appear only in list rows, tab bars, and menus.

 The following example shows a List with the value of recentItems.count represented by a badge on one of the rows:
 */

List {
    Text("Recents")
        .badge(recentItems.count)
    Text("Favorites")
}

// MARK: - Swipe Actions
List {
    ForEach(store.messages) { message in
        MessageCell(message: message)
            .swipeActions(edge: .leading) {
                Button { store.toggleUnread(message) } label: {
                    if message.isUnread {
                        Label("Read", systemImage: "envelope.open")
                    } else {
                        Label("Unread", systemImage: "envelope.badge")
                    }
                }
            }
            .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                    store.delete(message)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                Button { store.flag(message) } label: {
                    Label("Flag", systemImage: "flag")
                }
            }
        }
    }
}

// -> For labels or images that appear in swipe actions, SwiftUI automatically applies the fill symbol variant, as shown above.
.swipeActions(edge: .leading, allowsFullSwipe: false) {
    Button { store.toggleUnread(message) } label: {
        if message.isUnread {
            Label("Read", systemImage: "envelope.open")
        } else {
            Label("Unread", systemImage: "envelope.badge")
        }
    }
}

// tint color
MessageCell(message: message)
    .swipeActions(edge: .leading) {
        Button { store.toggleUnread(message) } label: {
            if message.isUnread {
                Label("Read", systemImage: "envelope.open")
            } else {
                Label("Unread", systemImage: "envelope.badge")
            }
        }
        .tint(.blue)
    }
    .swipeActions(edge: .trailing) {
        Button(role: .destructive) { store.delete(message) } label: {
            Label("Delete", systemImage: "trash")
        }
        Button { store.flag(message) } label: {
            Label("Flag", systemImage: "flag")
        }
        .tint(.orange)
    }
/*
 When you add swipe actions, SwiftUI no longer synthesizes the Delete actions that otherwise appear when using the ForEach/onDelete(perform:) method on a ForEach instance. You become responsible for creating a Delete action, if appropriate, among your swipe actions.
 */
/// When you add swipe actions, SwiftUI no longer synthesizes the Delete actions that otherwise appear when using the ForEach/onDelete(perform:) method on a ForEach instance. You become responsible for creating a Delete action, if appropriate, among your swipe actions.

// MARK: - selectionDisabled
@Binding var selection: Item.ID?
@Binding var items: [Item]

var body: some View {
    List(selection: $selection) {
        ForEach(items) { item in
            ItemView(item: item)
                .selectionDisabled(item.id == items.first?.id)
        }
    }
}

/// You can also use this modifier to specify the selectability of views within a Picker. The following example represents a flavor picker that disables selection on flavors that are unavailable.
Picker("Flavor", selection: $selectedFlavor) {
    ForEach(Flavor.allCases) { flavor in
        Text(flavor.rawValue.capitalized)
            .selectionDisabled(isSoldOut(flavor))
    }
}

// MARK: - RefreshAction
List(mailbox.conversations) { conversation in
    ConversationCell(conversation)
}
.refreshable {
    await mailbox.fetch()
}

// MARK: - Refreshing custom views
/*
 You can also offer refresh capability in your custom views. Read the refresh environment value to get the RefreshAction instance for a given Environment. If you find a non-nil value, change your view’s appearance or behavior to offer the refresh to the user, and call the instance to conduct the refresh. You can call the refresh instance directly because it defines a callAsFunction() method that Swift calls when you call the instance:
 */

/// https://www.swiftbysundell.com/articles/making-swiftui-views-refreshable/
struct RefreshableView: View {
    @Environment(\.refresh) private var refresh

    var body: some View {
        Button("Refresh") {
            Task {
                await refresh?()
            }
        }
        .disabled(refresh == nil)
    }
}

// MARK: - deleteDisabled
// Adds a condition for whether the view’s view hierarchy is deletable.
var body: some View {
    NavigationView {
        List {
            ForEach(contacts) { contact in
                Text(contact.name)
                    .deleteDisabled(contact.readOnly)

            }.onDelete { indexSet in
                contacts.remove(atOffsets: indexSet)
            }
        }
        .toolbar {
            EditButton()
        }
    }
}

// MARK: - EditMode
/// You receive an optional binding to the edit mode state when you read the editMode environment value. The binding contains an EditMode value that indicates whether edit mode is active, and that you can use to change the mode. To learn how to read an environment value, see EnvironmentValues.

@Environment(\.editMode) private var editMode
@State private var name = "Maria Ruiz"

var body: some View {
    Form {
        if editMode?.wrappedValue.isEditing == true {
            TextField("Name", text: $name)
        } else {
            Text(name)
        }
    }
    .animation(nil, value: editMode?.wrappedValue)
    .toolbar { // Assumes embedding this view in a NavigationView.
        /// You can set the edit mode through the binding, or you can rely on an EditButton to do that for you,
        /// as the example demonstrates. The button activates edit mode when the user taps it, and disables the mode when the user taps again.
        EditButton()
    }
}

//MARK: - 250415 Custom Layout
/// https://developer.apple.com/documentation/swiftui/custom-layout
// Place views in custom arrangements and create animated transitions between layout types.
/*
 You traditionally arrange views in your app’s user interface using built-in layout containers like HStack and Grid. If you need more complex layout behavior, you can define a custom layout container by creating a type that conforms to the Layout protocol and implementing its required methods:

    -> sizeThatFits(proposal:subviews:cache:) reports the size of the composite layout view.

    -> placeSubviews(in:proposal:subviews:cache:) assigns positions to the container’s subviews.

 You can define a basic layout type with only these two methods:
 */

struct BasicVStack: Layout {
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        // Calculate and return the size of the layout container.
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        // Tell each subview where to appear.
    }
}

// MARK: - Support additional behaviors
/*
 You can optionally implement other protocol methods and properties to provide more layout container features:
 
    -> Define explicit horizontal and vertical layout guides for the container by implementing explicitAlignment(of:in:proposal:subviews:cache:) for each dimension.
 
    -> Establish the preferred spacing around the container by implementing spacing(subviews:cache:).
 
    -> Indicate the axis of orientation for a container that has characteristics of a stack by implementing the layoutProperties static property.
 
    -> Create and manage a cache to store computed values across different layout protocol calls by implementing makeCache(subviews:).
 
 The protocol provides default implementations for these symbols if you don’t implement them. See each method or property for details.
 */

// MARK: - Set Layout Value
/// A key that the layout uses to read the rank for a subview.
private struct Rank: LayoutValueKey {
    static let defaultValue: Int = 1
}

extension View {
    /// Sets the rank layout value on a view.
    func rank(_ value: Int) -> some View {
        layoutValue(key: Rank.self, value: value)
    }
}

// MARK: - Radical Layout
struct MyRadialLayout: Layout {
    /// Returns a size that the layout container needs to arrange its subviews
    /// in a circle.
    ///
    /// This implementation uses whatever space the container view proposes.
    /// If the container asks for this layout's ideal size, it offers the
    /// the [`unspecified`](https://developer.apple.com/documentation/swiftui/proposedviewsize/unspecified)
    /// proposal, which contains `nil` in each dimension.
    /// To convert that to a concrete size, this method uses the proposal's
    /// [`replacingUnspecifiedDimensions(by:)`](https://developer.apple.com/documentation/swiftui/proposedviewsize/replacingunspecifieddimensions(by:))
    /// method.
    /// - Tag: sizeThatFitsRadial
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) -> CGSize {
        // Take whatever space is offered.
        proposal.replacingUnspecifiedDimensions()
    }

    /// Places the stack's subviews in a circle.
    /// - Tag: placeSubviewsRadial
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) {
        // Place the views within the bounds.
        let radius = min(bounds.size.width, bounds.size.height) / 3.0

        // The angle between views depends on the number of views.
        let angle = Angle.degrees(360.0 / Double(subviews.count)).radians

        // Read the ranks from each view, and find the appropriate offset.
        // This only has an effect for the specific case of three views with
        // nonuniform rank values. Otherwise, the offset is zero, and it has
        // no effect on the placement.
        // MARK: - Layout Value Read
        let ranks = subviews.map { subview in
            subview[Rank.self]
        }
        let offset = getOffset(ranks)

        for (index, subview) in subviews.enumerated() {
            // Find a vector with an appropriate size and rotation.
            var point = CGPoint(x: 0, y: -radius)
                .applying(CGAffineTransform(
                    rotationAngle: angle * Double(index) + offset))

            // Shift the vector to the middle of the region.
            point.x += bounds.midX
            point.y += bounds.midY

            // Place the subview.
            subview.place(at: point, anchor: .center, proposal: .unspecified)
        }
    }
}

extension MyRadialLayout {
    /// Finds the angular offset that arranges the views in rank order.
    ///
    /// This method produces an offset that tells a radial layout how much
    /// to rotate all of its subviews so that they display in order, from
    /// top to bottom, according to their ranks. The method only has meaning
    /// for exactly three laid-out views, initially positioned with the first
    /// view at the top, the second at the lower right, and the third in the
    /// lower left of the radial layout.
    ///
    /// - Parameter ranks: The rank values for the three subviews. Provide
    ///   exactly three ranks.
    ///
    /// - Returns: An angle in radians. The method returns zero if you provide
    ///   anything other than three ranks, or if the ranks are all equal,
    ///   representing a three-way tie.
    private func getOffset(_ ranks: [Int]) -> Double {
        guard ranks.count == 3,
              !ranks.allSatisfy({ $0 == ranks.first }) else { return 0.0 }

        // Get the offset as a fraction of a third of a circle.
        // Put the leader at the top of the circle, and then adjust by
        // a residual amount depending on what the other two are doing.
        var fraction: Double
        if ranks[0] == 1 {
            fraction = residual(rank1: ranks[1], rank2: ranks[2])
        } else if ranks[1] == 1 {
            fraction = -1 + residual(rank1: ranks[2], rank2: ranks[0])
        } else {
            fraction = 1 + residual(rank1: ranks[0], rank2: ranks[1])
        }

        // Convert the fraction to an angle in radians.
        return fraction * 2.0 * Double.pi / 3.0
    }

    /// Gets the residual fraction based on what the other two ranks are doing.
    private func residual(rank1: Int, rank2: Int) -> Double {
        if rank1 == 1 {
            return -0.5
        } else if rank2 == 1 {
            return 0.5
        } else if rank1 < rank2 {
            return -0.25
        } else if rank1 > rank2 {
            return 0.25
        } else {
            return 0
        }
    }
}

// MARK: - Equal Width HStack
struct MyEqualWidthHStack: Layout {
    /// Returns a size that the layout container needs to arrange its subviews
    /// horizontally.
    /// - Tag: sizeThatFitsHorizontal
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) -> CGSize {
        guard !subviews.isEmpty else { return .zero }

        let maxSize = maxSize(subviews: subviews)
        let spacing = spacing(subviews: subviews)
        let totalSpacing = spacing.reduce(0) { $0 + $1 }

        return CGSize(
            width: maxSize.width * CGFloat(subviews.count) + totalSpacing,
            height: maxSize.height)
    }

    /// Places the subviews in a horizontal stack.
    /// - Tag: placeSubviewsHorizontal
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) {
        guard !subviews.isEmpty else { return }

        let maxSize = maxSize(subviews: subviews)
        let spacing = spacing(subviews: subviews)

        let placementProposal = ProposedViewSize(width: maxSize.width, height: maxSize.height)
        var nextX = bounds.minX + maxSize.width / 2

        for index in subviews.indices {
            subviews[index].place(
                at: CGPoint(x: nextX, y: bounds.midY),
                anchor: .center,
                proposal: placementProposal)
            nextX += maxSize.width + spacing[index]
        }
    }

    /// Finds the largest ideal size of the subviews.
    private func maxSize(subviews: Subviews) -> CGSize {
        let subviewSizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let maxSize: CGSize = subviewSizes.reduce(.zero) { currentMax, subviewSize in
            CGSize(
                width: max(currentMax.width, subviewSize.width),
                height: max(currentMax.height, subviewSize.height))
        }

        return maxSize
    }

    /// Gets an array of preferred spacing sizes between subviews in the
    /// horizontal dimension.
    private func spacing(subviews: Subviews) -> [CGFloat] {
        subviews.indices.map { index in
            guard index < subviews.count - 1 else { return 0 }
            return subviews[index].spacing.distance(
                to: subviews[index + 1].spacing,
                along: .horizontal)
        }
    }
}

// MARK: - Layout Value Key
private struct Flexibility: LayoutValueKey {
    static let defaultValue: CGFloat? = nil
}

extension View {
    func layoutFlexibility(_ value: CGFloat?) -> some View {
        layoutValue(key: Flexibility.self, value: value)
    }
}

BasicVStack {
    Text("One View")
    Text("Another View")
        .layoutFlexibility(3)
}

// Retrieve a value during layout
extension BasicVStack {
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) -> CGSize {

        // Map the flexibility property of each subview into an array.
        let flexibilities = subviews.map { subview in
            subview[Flexibility.self]
        }

        // Calculate and return the size of the layout container.
        // ...
    }
}

// MARK: - AnyLayout
struct DynamicLayoutExample: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    var body: some View {
        let layout = dynamicTypeSize <= .medium ?
            AnyLayout(HStackLayout()) : AnyLayout(VStackLayout())

        layout {
            Text("First label")
            Text("Second label")
        }
    }
}

// MARK: - 250413 Layout Adjustments
/// https://developer.apple.com/documentation/swiftui/layout-adjustments

// When you add a frame modifier, SwiftUI wraps the affected view, effectively adding a new view to the view hierarchy.
struct MessageRow: View {
    let message: Message

    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color.yellow)
                Text(message.initials)
            }
            .frame(width: 40)


            Text(message.content)
        }
    }
}

// MARK: -  Adjust the alignment of individual views within a stack
/// https://developer.apple.com/documentation/swiftui/aligning-views-within-a-stack
HStack(alignment: .firstTextBaseline) {
    Image("microphone")
        .alignmentGuide(.firstTextBaseline) { context in
            context[.bottom] - 0.12 * context.height
        }
    Text("Connecting")
        .font(.caption)
    Text("Bryan")
        .font(.title)
}
.padding()
.border(Color.blue, width: 1)

HStack(alignment: .firstTextBaseline) {
    Image(systemName: "mic.circle")
        .font(.title)
    Text("Connecting")
        .font(.caption)
    Text("Bryan")
        .font(.title)
}
.padding()
.border(Color.blue, width: 1)

// MARK: - --> Aligning views across stacks
/// https://developer.apple.com/documentation/swiftui/aligning-views-across-stacks
/*
 As you nest stacks together, you may want specific items within those stacks to align with each other. By default, the alignment you specify for a stack applies only to that stack’s child views. To align child views that reside in the nested stacks, define a custom alignment, assign it to the enclosing view, and use the alignment guide modifier to identify specific views to align.
 */

// Define a custom alignment
extension VerticalAlignment {
    /// A custom alignment for image titles.
    private struct ImageTitleAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            // Default to bottom alignment if no guides are set.
            context[VerticalAlignment.bottom]
        }
    }

    /// A guide for aligning titles.
    static let imageTitleAlignmentGuide = VerticalAlignment(
        ImageTitleAlignment.self
    )
}

/*
 When you define an alignment on a stack, it projects through enclosed child views. Within the nested VStack instances, apply alignmentGuide(_:computeValue:) to the views to align, using your custom guide for the HStack.
 */
struct RowOfAlignedImages: View {
    var body: some View {
        HStack(alignment: .imageTitleAlignmentGuide) {
            VStack {
                Image("bell_peppers")
                    .resizable()
                    .scaledToFit()

                Text("Bell Peppers")
                    .font(.title)
                    .alignmentGuide(.imageTitleAlignmentGuide) { context in
                        context[.firstTextBaseline]
                    }
            }
            VStack {
                Image("chili_peppers")
                    .resizable()
                    .scaledToFit()


                Text("Chili Peppers")
                    .font(.title)
                    .alignmentGuide(.imageTitleAlignmentGuide) { context in
                        context[.firstTextBaseline]
                    }


                Text("Higher levels of capsicum")
                    .font(.caption)
            }
        }
    }
}

// MARK: - Alignment
/// https://developer.apple.com/documentation/swiftui/alignment
struct AlignmentGallery: View {
    var body: some View {
        BackgroundView()
            .overlay(alignment: .topLeading) { box(".topLeading") }
            .overlay(alignment: .top) { box(".top") }
            .overlay(alignment: .topTrailing) { box(".topTrailing") }
            .overlay(alignment: .leading) { box(".leading") }
            .overlay(alignment: .center) { box(".center") }
            .overlay(alignment: .trailing) { box(".trailing") }
            .overlay(alignment: .bottomLeading) { box(".bottomLeading") }
            .overlay(alignment: .bottom) { box(".bottom") }
            .overlay(alignment: .bottomTrailing) { box(".bottomTrailing") }
            .overlay(alignment: .leadingLastTextBaseline) { box(".leadingLastTextBaseline") }
            .overlay(alignment: .trailingFirstTextBaseline) { box(".trailingFirstTextBaseline") }
    }

    private func box(_ name: String) -> some View {
        Text(name)
            .font(.system(.caption, design: .monospaced))
            .padding(2)
            .foregroundColor(.white)
            .background(.blue.opacity(0.8), in: Rectangle())
    }
}

private struct BackgroundView: View {
    var body: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            GridRow {
                Text("Some text in an upper quadrant")
                Color.gray.opacity(0.3)
            }
            GridRow {
                Color.gray.opacity(0.3)
                Text("More text in a lower quadrant")
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .foregroundColor(.secondary)
        .border(.gray)
    }
}

// custom alignment title
ZStack(alignment: Alignment(horizontal: .center, vertical: .firstThird)) {
    // ...
}

//MARK: - Horizontal Alignment
/// https://developer.apple.com/documentation/swiftui/horizontalalignment
private struct HorizontalAlignmentGallery: View {
    var body: some View {
        HStack(spacing: 30) {
            column(alignment: .leading, text: "Leading")
            column(alignment: .center, text: "Center")
            column(alignment: .trailing, text: "Trailing")
        }
        .frame(height: 150)
    }


    private func column(alignment: HorizontalAlignment, text: String) -> some View {
        VStack(alignment: alignment, spacing: 0) {
            Color.red.frame(width: 1)
            Text(text).font(.title).border(.gray)
            Color.red.frame(width: 1)
        }
    }
}

/*
 During layout, SwiftUI aligns the views inside each stack by bringing together the specified guides of the affected views.
 SwiftUI calculates the position of a guide for a particular view based on the characteristics of the view. For example,
 the center guide appears at half the width of the view. You can override the guide calculation for a particular view using the alignmentGuide(_:computeValue:) view modifier.
 */

// Layout Direction
HorizontalAlignmentGallery()
    .environment(\.layoutDirection, .rightToLeft)

//MARK: - Custom alignment guides
private struct OneQuarterAlignment: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        context.width / 4
    }
}

extension HorizontalAlignment {
    static let oneQuarter = HorizontalAlignment(OneQuarterAlignment.self)
}

// Composite alignment
struct LayeredVerticalStripes: View {
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .oneQuarter, vertical: .center)) {
            verticalStripes(color: .blue)
                .frame(width: 300, height: 150)
            verticalStripes(color: .green)
                .frame(width: 180, height: 80)
        }
    }

    private func verticalStripes(color: Color) -> some View {
        HStack(spacing: 1) {
            ForEach(0..<4) { _ in color }
        }
    }
}

//MARK: - VerticalAlignment
private struct VerticalAlignmentGallery: View {
    var body: some View {
        VStack(spacing: 30) {
            row(alignment: .top, text: "Top")
            row(alignment: .center, text: "Center")
            row(alignment: .bottom, text: "Bottom")
            row(alignment: .firstTextBaseline, text: "First Text Baseline")
            row(alignment: .lastTextBaseline, text: "Last Text Baseline")
        }
    }

    private func row(alignment: VerticalAlignment, text: String) -> some View {
        HStack(alignment: alignment, spacing: 0) {
            Color.red.frame(height: 1)
            Text(text).font(.title).border(.gray)
            Color.red.frame(height: 1)
        }
    }
}

// Custom Alignment
private struct FirstThirdAlignment: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        context.height / 3
    }
}

extension VerticalAlignment {
    static let firstThird = VerticalAlignment(FirstThirdAlignment.self)
}

struct LayeredHorizontalStripes: View {
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .firstThird)) {
            horizontalStripes(color: .blue)
                .frame(width: 180, height: 90)
            horizontalStripes(color: .green)
                .frame(width: 70, height: 60)
        }
    }

    private func horizontalStripes(color: Color) -> some View {
        VStack(spacing: 1) {
            ForEach(0..<3) { _ in color }
        }
    }
}

//MARK: - AlignmentID
/// A type that you use to create custom alignment guides.
/*
 Every built-in alignment guide that VerticalAlignment or HorizontalAlignment defines as a static property, like top or leading, has a unique alignment identifier type that produces the default offset for that guide. To create a custom alignment guide, define your own alignment identifier as a type that conforms to the AlignmentID protocol, and implement the required defaultValue(in:) method:
 */
private struct FirstThirdAlignment: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        context.height / 3
    }
}

extension VerticalAlignment {
    static let firstThird = VerticalAlignment(FirstThirdAlignment.self)
}

struct StripesGroup: View {
    var body: some View {
        HStack(alignment: .firstThird, spacing: 1) {
            HorizontalStripes().frame(height: 60)
            HorizontalStripes().frame(height: 120)
            HorizontalStripes().frame(height: 90)
        }
    }
}

struct HorizontalStripes: View {
    var body: some View {
        VStack(spacing: 1) {
            ForEach(0..<3) { _ in Color.blue }
        }
    }
}

/*
 You can also use the alignmentGuide(_:computeValue:) view modifier to alter the behavior of your custom guide for a view, as you might alter a built-in guide. For example, you can change one of the stacks of stripes from the previous example to align its firstThird guide at two thirds of the height instead:
 */
struct StripesGroupModified: View {
    var body: some View {
        HStack(alignment: .firstThird, spacing: 1) {
            HorizontalStripes().frame(height: 60)
            HorizontalStripes().frame(height: 120)
            HorizontalStripes().frame(height: 90)
                .alignmentGuide(.firstThird) { context in
                    2 * context.height / 3
                }
        }
    }
}

//MARK: - ViewDimensions
// A view’s size and alignment guides in its own coordinate space.
/// https://developer.apple.com/documentation/swiftui/viewdimensions
/*
 This structure contains the size and alignment guides of a view. You receive an instance of this structure to use in a variety of layout calculations, like when you:

    Define a default value for a custom alignment guide; see defaultValue(in:).

    Modify an alignment guide on a view; see alignmentGuide(_:computeValue:).

    Ask for the dimensions of a subview of a custom view layout; see dimensions(in:).
 */

private struct FirstThirdAlignment: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        context.height / 3
    }
}

extension VerticalAlignment {
    static let firstThird = VerticalAlignment(FirstThirdAlignment.self)
}


/// As another example, you could use the view dimensions instance to look up the offset of an existing guide and modify it:
struct ViewDimensionsOffset: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Default")
            Text("Indented")
                .alignmentGuide(.leading) { context in
                    context[.leading] - 10
                }
        }
    }
}

//MARK: - contentMargins(_:for:)
ScrollView(.horizontal) {
    // ...
}
.contentMargins(.horizontal, 20.0)

TextEditor(text: $text)
    .contentMargins(.horizontal, 20.0, for: .scrollContent)

ScrollView {
    // ...
}
.clipShape(.rect(cornerRadius: 20.0))
.contentMargins(10.0, for: .scrollIndicators)

// MARK: - 250413 Swift 6
/// https://www.avanderlee.com/concurrency/preconcurrency-checking-swift/
struct RotatingFadeTransition: Transition {
    func body(content: Content, phase: TransitionPhase) -> some View {
        content
          .opacity(phase.isIdentity ? 1.0 : 0.0)
          .rotationEffect(phase.rotation)
    }
}
extension TransitionPhase {
    fileprivate var rotation: Angle {
        switch self {
        case .willAppear: return .degrees(30)
        case .identity: return .zero
        case .didDisappear: return .degrees(-30)
        }
    }
}

/*
 -> A type conforming to this protocol inherits @preconcurrency @MainActor isolation from the protocol if the conformance is included in the type’s base declaration:
    struct MyCustomType: Transition {
        // `@preconcurrency @MainActor` isolation by default
    }
 
 -> Isolation to the main actor is the default, but it’s not required. Declare the conformance in an extension to opt out of main actor isolation:
    extension MyCustomType: Transition {
        // `nonisolated` by default
    }
 */

// MARK: - What’s New and How to Migrate Article
/// https://www.avanderlee.com/concurrency/swift-6-migrating-xcode-projects-packages/

/// Using throws(ValidationError) we specify the error type to always be `ValidationError`
static func validate(name: String) throws(ValidationError) {
    guard !name.isEmpty else {
        throw ValidationError.emptyName
    }
    guard name.count > 2 else {
        throw ValidationError.nameTooShort(nameLength: name.count)
    }
}

internal import FrameworkDependency
private import FrameworkDependencyOnlyForThisFile
package import FrameworkDependencyOnlyForFilesInThisPackage

[1, 2, 3, -1, -2].count(where: { $0 > 0 }) // → 3
[1, 2, 3, -1, -2].contains(where: { $0 > 0 }) // → true


// MARK: - Race condition vs. Data Race: the differences explained Article
/// https://www.avanderlee.com/swift/race-condition-vs-data-race/
/*
 Race Condition
    -> A race condition occurs when the timing or order of events affects the correctness of a piece of code.
 
 Data Race
    -> A data race occurs when one thread accesses a mutable object while another thread is writing to it.
 */

// MARK: - Race Condition
/// A race condition can occur without a data race, while a data race can occur without a race condition.
/// For example, the order of events can be consistent, but if there’s always a read at the same time as a write, there’s still a data race.
let bankAcountOne = BankAccount(balance: 100)
let bankAcountTwo = BankAccount(balance: 100)

final class Bank {
    @discardableResult
    func transfer(amount: Int, from fromAccount: BankAccount, to toAccount: BankAccount) -> Bool {
        guard fromAccount.balance >= amount else {
            return false
        }
        toAccount.balance += amount
        fromAccount.balance -= amount
        
        return true
    }
}

bank.transfer(amount: 50, from: bankAcountOne, to: bankAcountTwo)
bank.transfer(amount: 70, from: bankAcountOne, to: bankAcountTwo)

/// When the transfer of 50 euros executes first, we’ll have the same outcome value as our first example:
print(bankAccountOne.balance) // 50 euros
print(bankAccountTwo.balance) // 150 euros

/// However, if the second transfer executes first, we’ll end up with a different balance:
print(bankAccountOne.balance) // 30 euros
print(bankAccountTwo.balance) // 170 euros

// The effect of a Data Race during a money transfer
final class Bank {
    @discardableResult
    func transfer(amount: Int, from fromAccount: BankAccount, to toAccount: BankAccount) -> Bool {
        guard fromAccount.balance >= amount else {
            return false
        }
        toAccount.balance += amount
        fromAccount.balance -= amount
        
        return true
    }
}

let bankAcountOne = BankAccount(balance: 100)
let bankAcountTwo = BankAccount(balance: 100)
bank.transfer(amount: 50, from: bankAcountOne, to: bankAcountTwo) // Executed on Thread 1
bank.transfer(amount: 70, from: bankAcountOne, to: bankAcountTwo) // Executed on Thread 2

----

// Thread 1 passes the balance check:
guard fromAccount.balance >= amount else {
    return false
}

// Thread 2, at the same time, performs the balance check:
guard fromAccount.balance >= amount else {
    return false
}

// Thread 1 updates the balances:
toAccount.balance += amount // 150
fromAccount.balance -= amount // 50

// Thread 2 updates the balances:
toAccount.balance += amount // 170
fromAccount.balance -= amount // 30

// Outcome:
print(bankAccountOne.balance) // 30 euros
print(bankAccountTwo.balance) // 170 euros

/// In theory, we could even end up with the following outcome:
print(bankAccountOne.balance) // 220 euros
print(bankAccountTwo.balance) // -20 euros

// MARK: - Data Race Fix
/// We can solve both race condition and data race by adding a locking mechanism around our transfer method:
private let lockQueue = DispatchQueue(label: "bank.lock.queue")

@discardableResult
func transfer(amount: Int, from fromAccount: BankAccount, to toAccount: BankAccount) -> Bool {
    lockQueue.sync {
        guard fromAccount.balance >= amount else {
            return false
        }
        toAccount.balance += amount
        fromAccount.balance -= amount
        
        return true
    }
}

actor BankAccountActor {
    var balance: Int
    
    init(balance: Int) {
        self.balance = balance
    }
    
    func transfer(amount: Int, to toAccount: BankAccountActor) async -> Bool {
        guard balance >= amount else {
            return false
        }
        balance -= amount
        await toAccount.deposit(amount: amount)
        
        return true
    }
    
    func deposit(amount: Int) {
        balance = balance + amount
    }
}

final class BankActor {
    @discardableResult
    func transfer(amount: Int, from fromAccount: BankAccountActor, to toAccount: BankAccountActor) async -> Bool {
        await fromAccount.transfer(amount: amount, to: toAccount)
    }
}

// MARK: - Thread Sanitizer explained: Data Races in Swift
func updateName() {
    DispatchQueue.global().async {
        self.recordAndCheckWrite(self.name) // Added by the compiler
        self.name.append("Antoine van der Lee")
    }

    // Executed on the Main Thread
    self.recordAndCheckWrite(self.name) // Added by the compiler
    print(self.name)
}

// Fix Data Race
private let lockQueue = DispatchQueue(label: "name.lock.queue")
private var name: String = "Antoine van der Lee"

func updateNameSync() {
    DispatchQueue.global().async {
        self.lockQueue.async {
            self.name.append("Antoine van der Lee")
        }
    }

    // Executed on the Main Thread
    lockQueue.async {
        // Executed on the lock queue
        print(self.name)
    }
}

// Prints:
// Antoine van der Lee
// Antoine van der Lee

actor NameController {
    private(set) var name: String = "My name is: "
    
    func updateName(to name: String) {
        self.name = name
    }
}

func updateName() async {
    DispatchQueue.global(qos: .userInitiated).async {
        Task {
            await self.nameController.updateName(to: "Antoine van der Lee")
        }
    }
    
    // Executed on the Main Thread
    print(await nameController.name)
}

// @available(*, deprecated, renamed: "fetchImages()")


// MARK: - 250412 Layout Fundamentals
/// https://developer.apple.com/documentation/swiftui/layout-fundamentals

// MARK: - List
var servicesListView: some View {
    List(services) { service in
        LXGeneralSummaryCell(
            cellWidth: containerWidth,
            viewConfig: getCardConfig(for: service)
        ) { actionType in
            didTapServiceSummaryCard(
                actionType: actionType,
                service: service
            )
        }
        .listRowInsets(.lxZero)
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                serviceToDelete = service
                isShowingServiceDeleteConfirmation = true
            } label: {
                Image(systemSymbol: .trash)
            }
            .tint(.LX.redColor.color)
        }
    }
    .listStyle(.plain)
}

// MARK: - HStack
var body: some View {
    /// If you need a horizontal stack that conforms to the Layout protocol, like when you want to create a conditional layout using AnyLayout, use HStackLayout instead.
    HStack(
        alignment: .top,
        spacing: 10
    ) {
        ForEach(
            1...5,
            id: \.self
        ) {
            Text("Item \($0)")
        }
    }
}

// MARK: - Grouping data with lazy stack views
/// https://developer.apple.com/documentation/swiftui/grouping-data-with-lazy-stack-views
struct ColorData: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
    let variations: [ShadeData]


    struct ShadeData: Identifiable {
        let id = UUID()
        var brightness: Double
    }


    init(color: Color, name: String) {
        self.name = name
        self.color = color
        self.variations = stride(from: 0.0, to: 0.5, by: 0.1)
            .map { ShadeData(brightness: $0) }
    }
}

struct ColorSelectionView: View {
    let sections = [
        ColorData(color: .red, name: "Reds"),
        ColorData(color: .green, name: "Greens"),
        ColorData(color: .blue, name: "Blues")
    ]


    var body: some View {
        ScrollView {
            LazyVStack(spacing: 1) {
                ForEach(sections) { section in
                    Section(header: SectionHeaderView(colorData: section)) {
                        ForEach(section.variations) { variation in
                            section.color
                                .brightness(variation.brightness)
                                .frame(height: 20)
                        }
                    }
                }
            }
        }
    }
}

struct SectionHeaderView: View {
    var colorData: ColorData

    var body: some View {
        HStack {
            Text(colorData.name)
                .font(.headline)
                .foregroundColor(colorData.color)
            Spacer()
        }
        .padding()
        .background(Color.primary
                        .colorInvert()
                        .opacity(0.75))
    }
}

// Pin Header
LazyVStack(spacing: 1, pinnedViews: [.sectionHeaders]) {
    // ...
}

// MARK: - Creating performant scrollable stacks
/// https://developer.apple.com/documentation/swiftui/creating-performant-scrollable-stacks

// -> Note
// Never profile your code using the iOS simulator. Always use real devices for performance testing.

ScrollView(.horizontal) {
    LazyHStack(alignment: .top, spacing: 10) {
        ForEach(1...100, id: \.self) {
            Text("Column \($0)")
        }
    }
}

ScrollView {
    LazyVStack(alignment: .leading) {
        ForEach(1...100, id: \.self) {
            Text("Row \($0)")
        }
    }
}

// MARK: - Grid
// A container view that arranges other views in a two dimensional layout.
/// https://developer.apple.com/documentation/swiftui/grid
Grid {
    GridRow {
        Text("Hello")
        Image(systemName: "globe")
    }
    GridRow {
        Image(systemName: "hand.wave")
        Text("World")
    }
}

/// If you need a grid that conforms to the Layout protocol, like when you want to create a conditional layout using AnyLayout, use GridLayout instead.
// Multicolumn cells
/*
 If you provide a view rather than a GridRow as an element in the grid’s content, the grid uses the view to create a row that spans all of the grid’s columns. For example, you can add a Divider between the rows of the previous example:
 */
Grid {
    GridRow {
        Text("Hello")
        Image(systemName: "globe")
    }
    Divider()
    GridRow {
        Image(systemName: "hand.wave")
        Text("World")
    }
}

/// To prevent a flexible view from taking more space on a given axis than the other cells in a row or column require,
/// add the gridCellUnsizedAxes(_:) view modifier to the view:
Divider()
    .gridCellUnsizedAxes(.horizontal)

// -> To make a cell span a specific number of columns rather than the whole grid,
// use the gridCellColumns(_:) modifier on a view that’s contained inside a GridRow.

/*
 The grid’s column count grows to handle the row with the largest number of columns. If you create rows with different numbers of columns, the grid adds empty cells to the trailing edge of rows that have fewer columns. The example below creates three rows with different column counts:
 */

Grid {
    GridRow {
        Text("Row 1")
        ForEach(0..<2) { _ in Color.red }
    }
    GridRow {
        Text("Row 2")
        ForEach(0..<5) { _ in Color.green }
    }
    GridRow {
        Text("Row 3")
        ForEach(0..<4) { _ in Color.blue }
    }
}

// Cell spacing and alignment
/// You can control the spacing between cells in both the horizontal and vertical dimensions and set a default alignment for the content in all the grid cells when you initialize the grid using the init(alignment:horizontalSpacing:verticalSpacing:content:) initializer. Consider a modified version of the previous example:
Grid(alignment: .bottom, horizontalSpacing: 1, verticalSpacing: 1) {
    // ...
}

/// A grid can size its rows and columns correctly because it renders all of its child views immediately.
/// If your app exhibits poor performance when it first displays a large grid that appears inside a ScrollView,
/// consider switching to a LazyVGrid or LazyHGrid instead.

// MARK: - GridRow
Grid {
    GridRow {
        Color.clear
            .gridCellUnsizedAxes([.horizontal, .vertical])
        ForEach(1..<4) { column in
            Text("C\(column)")
        }
    }
    ForEach(1..<4) { row in
        GridRow {
            Text("R\(row)")
            ForEach(1..<4) { _ in
                Circle().foregroundStyle(.mint)
            }
        }
    }
}

/// Important
// -> You can’t use EmptyView to create a blank cell because that resolves to the absence of a view and doesn’t generate a cell.

Grid(alignment: .leadingFirstTextBaseline) {
    GridRow {
        Text("Regular font:")
            .gridColumnAlignment(.trailing) // Align the entire first column.
        Text("Helvetica 12")
        Button("Select...") { }
    }
    GridRow {
        Text("Fixed-width font:")
        Text("Menlo Regular 11")
        Button("Select...") { }
    }
    GridRow {
        Color.clear
            .gridCellUnsizedAxes([.vertical, .horizontal])
        Toggle("Use fixed-width font for new documents", isOn: $isOn)
            .gridCellColumns(2)
    }
}

// MARK: - gridCellAnchor(_:)
Grid(horizontalSpacing: 1, verticalSpacing: 1) {
    GridRow {
        Color.red.frame(width: 60, height: 60)
        Color.red.frame(width: 60, height: 60)
    }
    GridRow {
        Color.red.frame(width: 60, height: 60)
        Color.blue.frame(width: 10, height: 10)
            .gridCellAnchor(UnitPoint(x: 0.25, y: 0.75))
    }
}

Color.blue.frame(width: 10, height: 10)
    .gridCellAnchor(.topTrailing)

/// If you use the gridCellColumns(_:) modifier to cause a cell to span more than one column,
/// or if you place a view in a grid outside of a row so that the view spans the entire grid,
/// the grid automatically converts its vertical and horizontal alignment guides to the unit point equivalent for the merged cell,

// MARK: - LazyHGrid
/// https://developer.apple.com/documentation/swiftui/lazyhgrid
/*
 You can achieve a similar layout using a Grid container.
 Unlike a lazy grid, which creates child views only when SwiftUI needs to display them,
 a regular grid creates all of its child views right away.
 This enables the grid to provide better support for cell spacing and alignment.
 Only use a lazy grid if profiling your app shows that a Grid view performs poorly because it tries to load too many views at once.
 */
struct HorizontalSmileys: View {
    let rows = [GridItem(.fixed(30)), GridItem(.fixed(30))]

    var body: some View {
        ScrollView(.horizontal) {
            LazyHGrid(rows: rows) {
                ForEach(0x1f600...0x1f679, id: \.self) { value in
                    Text(String(format: "%x", value))
                    Text(emoji(value))
                        .font(.largeTitle)
                }
            }
        }
    }

    private func emoji(_ value: Int) -> String {
        guard let scalar = UnicodeScalar(value) else { return "?" }
        return String(Character(scalar))
    }
}

// MARK: - LazyVGrid
struct VerticalSmileys: View {
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
         ScrollView {
             LazyVGrid(columns: columns) {
                 ForEach(0x1f600...0x1f679, id: \.self) { value in
                     Text(String(format: "%x", value))
                     Text(emoji(value))
                         .font(.largeTitle)
                 }
             }
         }
    }

    private func emoji(_ value: Int) -> String {
        guard let scalar = UnicodeScalar(value) else { return "?" }
        return String(Character(scalar))
    }
}

// MARK: - GridItem
/// A description of a row or a column in a lazy grid.
/// https://developer.apple.com/documentation/swiftui/griditem
struct GridItemDemo: View {
    let rows = [
        GridItem(.fixed(30), spacing: 1),
        GridItem(.fixed(60), spacing: 10),
        GridItem(.fixed(90), spacing: 20),
        GridItem(.fixed(10), spacing: 50)
    ]


    var body: some View {
        ScrollView(.horizontal) {
            LazyHGrid(rows: rows, spacing: 5) {
                ForEach(0...300, id: \.self) { _ in
                    Color.red.frame(width: 30)
                    Color.green.frame(width: 30)
                    Color.blue.frame(width: 30)
                    Color.yellow.frame(width: 30)
                }
            }
        }
    }
}

// MARK: - Adding a background to your view
/// https://developer.apple.com/documentation/swiftui/adding-a-background-to-your-view
let backgroundGradient = LinearGradient(
    colors: [Color.red, Color.blue],
    startPoint: .top,
    endPoint: .bottom
)

struct SignInView: View {
    @State private var name: String = ""

    var body: some View {
        VStack {
            Text("Welcome")
                .font(.title)
            HStack {
                TextField("Your name?", text: $name)
                    .textFieldStyle(.roundedBorder)
                Button(action: {}, label: {
                    Image(systemName: "arrow.right.square")
                        .font(.title)
                })
            }
            .padding()
        }
        .background(backgroundGradient)
    }
}

// Expand the background underneath your view

/*
 To create a background that’s larger than the vertical stack, use a different technique. You could add Spacer views above and below the content in the VStack to expand it, but that would also expand the size of the stack, possibly changing it’s layout. To add in a larger background without changing the size of the stack, nest the views within a ZStack to layer the VStack over the background view:
 */
struct SignInView: View {
    @State private var name: String = ""

    var body: some View {
        ZStack {
            backgroundGradient
            VStack {
                Text("Welcome")
                    .font(.title)
                HStack {
                    TextField("Your name?", text: $name)
                        .textFieldStyle(.roundedBorder)
                    Button(action: {}, label: {
                        Image(systemName: "arrow.right.square")
                            .font(.title)
                    })
                }
                .padding()
            }
        }
    }
}

/// To get the contents of the vertical stack to respect the safe areas and adjust to the keyboard, move the modifier to only apply to the background view.
struct SignInView: View {
    @State private var name: String = ""
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            VStack {
                Text("Welcome")
                    .font(.title)
                HStack {
                    TextField("Your name?", text: $name)
                        .textFieldStyle(.roundedBorder)
                    Button(action: {}, label: {
                        Image(systemName: "arrow.right.square")
                            .font(.title)
                    })
                }
                .padding()
            }
        }
    }
}

// MARK: - ZStack
///The ZStack assigns each successive subview a higher z-axis value than the one before it,
///meaning later subviews appear “on top” of earlier ones.
let colors: [Color] =
    [.red, .orange, .yellow, .green, .blue, .purple]

var body: some View {
    ZStack {
        ForEach(0..<colors.count) {
            Rectangle()
                .fill(colors[$0])
                .frame(width: 100, height: 100)
                .offset(x: CGFloat($0) * 10.0,
                        y: CGFloat($0) * 10.0)
        }
    }
}

// MARK: - Understanding Container Background for Widget in iOS 17
/// https://swiftsenpai.com/development/widget-container-background/

// No Longer Valid for widget
var body: some View {
    Text("Hello!")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.yellow)
}

// Needs to be
var body: some View {
    Text("Hello!")
        .containerBackground(for: .widget) {
            Color.yellow
        }
}

// or
var body: some View {
    Text("Hello!")
        .containerBackground(for: .widget) {
            VStack(spacing: 0) {
                Color.yellow
                Color.green
            }
        }
}

/// if you don’t want the system to automatically remove the background view for certain modes
var body: some WidgetConfiguration {
    StaticConfiguration(
        kind: "com.SwiftSenpaiDemo.MyWidget",
        provider: MyWidgetTimelineProvider()
    ) { entry in
        MyWidgetView(entry: entry)
    }
    // Disable container background removal
    .containerBackgroundRemovable(false)
}

/// The .containerBackground(for:alignment:content:) modifier differs from the background(_:ignoresSafeAreaEdges:) modifier by automatically filling an entire parent container. ContainerBackgroundPlacement describes the available containers.

// MARK: - ViewThatFits
/// A view that adapts to the available space by providing the first child view that fits.
/// https://developer.apple.com/documentation/swiftui/viewthatfits
struct UploadProgressView: View {
    var uploadProgress: Double

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack {
                Text("\(uploadProgress.formatted(.percent))")
                ProgressView(value: uploadProgress)
                    .frame(width: 100)
            }
            ProgressView(value: uploadProgress)
                .frame(width: 100)
            Text("\(uploadProgress.formatted(.percent))")
        }
    }
}

/*
 This use of ViewThatFits evaluates sizes only on the horizontal axis. The following code fits the UploadProgressView to several fixed widths:
 */
VStack {
    UploadProgressView(uploadProgress: 0.75)
        .frame(maxWidth: 200)
    UploadProgressView(uploadProgress: 0.75)
        .frame(maxWidth: 100)
    UploadProgressView(uploadProgress: 0.75)
        .frame(maxWidth: 50)
}

// MARK: - Spacer
/// A flexible space that expands along the major axis of its containing stack layout, or on both axes if not contained in a stack.


// MARK: - 250411 Drawing and graphics
/// https://developer.apple.com/documentation/swiftui/drawing-and-graphics

// MARK: - Lava Snow Fall (Pro SwiftUI)
// import SwiftUI

extension FallingSnow2 {
    class Particle {
        var x: Double
        var y: Double
        let xSpeed: Double
        let ySpeed: Double
        let deathDate = Date.now.timeIntervalSinceReferenceDate + 2
    
        init(x: Double, y: Double, xSpeed: Double, ySpeed: Double) {
            self.x = x
            self.y = y
            self.xSpeed = xSpeed
            self.ySpeed = ySpeed
        }
    }

    class ParticleSystem {
        var particles = [FallingSnow2.Particle]()
        var lastUpdate = Date.now.timeIntervalSinceReferenceDate
        
        func update(date: TimeInterval, size: CGSize) {
            let delta = date - lastUpdate
            lastUpdate = date

            for (index, particle) in particles.enumerated() {
                if particle.deathDate < date {
                    particles.remove(at: index)
                } else {
                    particle.x += particle.xSpeed * delta
                    particle.y += particle.ySpeed * delta
                }
            }

            let newParticle = FallingSnow2.Particle(x: .random(in: -32...size.width), y: -32, xSpeed: .random(in: -50...50), ySpeed: .random(in: 100...500))
            particles.append(newParticle)
        }
    }
}

struct FallingSnow2: SelfCreatingView {
    @State private var particleSystem = ParticleSystem()

    var body: some View {
        LinearGradient(
            colors: [.red, .indigo],
            startPoint: .top, endPoint: .bottom
        ).mask {
            TimelineView(.animation) { timeline in
                Canvas { ctx, size in
                    let timelineDate = timeline.date.timeIntervalSinceReferenceDate
                    particleSystem.update(date: timelineDate, size: size)
                    ctx.addFilter(.alphaThreshold(min: 0.5, color: .white))
                    ctx.addFilter(.blur(radius: 10))
                    
                    ctx.drawLayer { ctx in
                        for particle in particleSystem.particles {
                            ctx.opacity = particle.deathDate - timelineDate
                            ctx.fill(Circle().path(in: CGRect(x: particle.x, y: particle.y, width: 32, height: 32)), with: .color(.white))
                        }
                    }
                }
            }
        }
        .ignoresSafeArea()
        .background(.black)
    }

}

struct FallingSnow2_Previews: PreviewProvider {
    static var previews: some View {
        FallingSnow2()
    }
}

// MARK: - Shape Style
/// https://developer.apple.com/documentation/swiftui/shapestyle
struct MyShapeStyle: ShapeStyle {
    func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        if environment.colorScheme == .light {
            return Color.red.blendMode(.lighten)
        } else {
            return Color.red.blendMode(.darken)
        }
    }
}

/*
 In addition to creating a custom shape style,
 you can also use one of the concrete styles that SwiftUI defines.
 To indicate a specific color or pattern,
 you can use Color or the style returned by image(_:sourceRect:scale:),
 or one of the gradient types, like the one returned by radialGradient(_:center:startRadius:endRadius:).
 To set a color that’s appropriate for a given context on a given platform,
 use one of the semantic styles, like background or primary.
 */

///Filling a shape with a style with the fill(_:style:) modifier:
Path { path in
    path.move(to: .zero)
    path.addLine(to: CGPoint(x: 50, y: 0))
    path.addArc(
        center: .zero,
        radius: 50,
        startAngle: .zero,
        endAngle: .degrees(90),
        clockwise: false)
}
.fill(.radialGradient(
    Gradient(colors: [.yellow, .red]),
    center: .topLeading,
    startRadius: 15,
    endRadius: 80))

/// Tracing the outline of a shape with a style with either the stroke(_:lineWidth:) or the stroke(_:style:) modifier:
RoundedRectangle(cornerRadius: 10)
    .stroke(.mint, lineWidth: 10)
    .frame(width: 200, height: 50)

VStack(alignment: .leading) {
    Text("Primary")
        .font(.title)
    Text("Secondary")
        .font(.caption)
        .foregroundStyle(.secondary)
}

// MARK: - Inner Shadow
/*
 Inner Shadow in iOS 16 can be created using the Foreground Style on a foreground element. There are two caveats though.
 
 One, you must use a Text, Image or Shape since Foreground Style doesn’t work directly on background containers like VStack or HStack.
 Second, the Foreground Style needs a color to show the shadow. As a result, it will replace fill or background.
 */

.foregroundStyle(
    .blue.gradient
        .shadow(.inner(color: .white.opacity(0.3), radius: 3, x: 1, y: 1))
        .shadow(.drop(radius: 5, x: 5, y: 5))
)

// MARK: - VisualEffect
/// Visual Effects change the visual appearance of a view without changing its ancestors or descendents.
var body: some View {
    ContentRow()
        .visualEffect { content, geometryProxy in
            content.offset(x: geometryProxy.frame(in: .global).origin.y)
        }
}

// MARK: - onGeometryChange(for:of:action:)
@preconcurrency nonisolated
func onGeometryChange<T>(
    for type: T.Type,
    of transform: @escaping (GeometryProxy) -> T,
    action: @escaping (T) -> Void
) -> some View where T : Equatable, T : Sendable

/*
 You should avoid updating large parts of your app whenever the scroll geometry changes. To aid in this, you provide two closures to this modifier:
 */

ScrollView(.horizontal) {
    LazyHStack {
         ForEach(videos) { video in
             VideoView(video)
         }
     }
 }

struct VideoView: View {
    var video: VideoModel
    
    var body: some View {
        VideoPlayer(video)
            .onGeometryChange(for: Bool.self) { proxy in
                let frame = proxy.frame(in: .scrollView)
                let bounds = proxy.bounds(of: .scrollView) ?? .zero
                let intersection = frame.intersection(
                    CGRect(origin: .zero, size: bounds.size))
                let visibleHeight = intersection.size.height
                return (visibleHeight / frame.size.height) > 0.75
            } action: { isVisible in
                video.updateAutoplayingState(
                    isVisible: isVisible)
            }
    }
}

// MARK: - On Scroll Target Visibility Change
  struct ExampleView: View {
      @State var backgroundImage: String = "landscape-1"
      
      let images = ["landscape-1", "landscape-2", "landscape-3", "landscape-4"]
      
      var body: some View {
          VStack {
              ScrollView(.horizontal) {
                  HStack {
                      ForEach(images, id: \.self) { image in
                          Image(image)
                              .resizable()
                              .frame(width: 300, height: 300)
                              .clipShape(RoundedRectangle(cornerRadius: 12.0))
                      }
                  }
                  .scrollTargetLayout()
              }
              .scrollTargetBehavior(.viewAligned)
              .onScrollTargetVisibilityChange(idType: String.self) { imgs in
                  if let image = imgs.first {
                      withAnimation(.spring) {
                          backgroundImage = image
                      }
                  }
              }
              .frame(width: 300, height: 300)
              .padding(30)
          }
          .background {
              ZStack(alignment: .bottom) {
                  Image(backgroundImage)
                      .resizable()
                      .scaledToFit()
                      .blur(radius: 30)
                      .clipShape(RoundedRectangle(cornerRadius: 12.0))
  
                  RoundedRectangle(cornerRadius: 12.0)
                      .stroke(.gray)
                  
                  Text("Scroll horizontally for more images")
                      .padding(.bottom, 10)
                      .font(.caption)
              }
          }
      }
  }
  
// MARK: - On Scroll Visibility Change
struct ExampleView: View {
    @State var backgroundImage: String = "landscape-1"
    
    let images = ["landscape-1", "landscape-2", "landscape-3", "landscape-4"]
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(images, id: \.self) { image in
                        Image(image)
                            .resizable()
                            .frame(width: 300, height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 12.0))
                            .onScrollVisibilityChange(threshold: 0.8) { visible in
                                if visible {
                                    withAnimation(.spring) {
                                        backgroundImage = image
                                    }
                                }
                            }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .frame(width: 300, height: 300)
            .padding(30)
        }
        .background {
            ZStack(alignment: .bottom) {
                Image(backgroundImage)
                    .resizable()
                    .scaledToFit()
                    .blur(radius: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 12.0))

                RoundedRectangle(cornerRadius: 12.0)
                    .stroke(.gray)
                
                Text("Scroll horizontally for more images")
                    .padding(.bottom, 10)
                    .font(.caption)
            }
        }
    }
}

// MARK: - Scroll Taget Layout
struct ExampleView: View {
    let fruits = ["🍎", "🍌", "🍇", "🍉", "🍊", "🍓", "🍑", "🥭", "🍍", "🥝", "🫐", "🍈", "🍒", "🥥", "🥑"]
    let vegetables = ["🥦", "🥕", "🍆", "🌽", "🥒", "🍅", "🫑", "🧄", "🧅", "🥔", "🥬", "🥗"]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                ForEach(fruits + vegetables, id: \.self) { item in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.gray.gradient)
                        .frame(width: 100, height: 100)
                        .overlay {
                            Text(item)
                                .font(.system(size: 66))
                        }
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .frame(width: 440, height: 100)
        .border(.gray)
    }
}

// MARK: - Scroll Position
struct ExampleView: View {
    static let fruits = [ "🍎", "🍌", "🍇", "🍊", "🍉", "🍓", "🍑", "🥝", "🍒"]

    @State var fruitIds: [String?] = ["🍊", "🍊", "🍊"]
    
    var body: some View {
        VStack {
            Button("Randomize") {
                withAnimation {
                    fruitIds[0] = ExampleView.fruits[Int.random(in: 0..<ExampleView.fruits.count)]
                    fruitIds[1] = ExampleView.fruits[Int.random(in: 0..<ExampleView.fruits.count)]
                    fruitIds[2] = ExampleView.fruits[Int.random(in: 0..<ExampleView.fruits.count)]
                }
            }

            HStack {
                FruitView(fruitId: $fruitIds[0])
                FruitView(fruitId: $fruitIds[1])
                FruitView(fruitId: $fruitIds[2])
            }
            
            Text("Current Ids = \(fruitIds[0]!)\(fruitIds[1]!)\(fruitIds[2]!)")
        }
    }
    
    struct FruitView: View {
        @Binding var fruitId: String?

        var body: some View {
            ScrollView(.vertical) {
                LazyVStack {
                    ForEach(ExampleView.fruits, id: \.self) {
                        Text($0).font(.system(size: 46))
                    }
                }
                .scrollTargetLayout()
                
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $fruitId)
            .border(.blue)
            .frame(width: 60, height: 60)
        }
    }
}

// MARK: - Scroll Transition
struct ExampleView: View {
    @State var disableClipping = true
    
    var body: some View {
        VStack {
            Toggle("Disable ScrollView Clipping", isOn: $disableClipping)
            TransitionExampleView()
                .scrollClipDisabled(disableClipping)
                .padding(100)
                .border(.gray.opacity(0.5), width: 100)
        }
    }
    
    struct TransitionExampleView: View {
        let fruits = ["🍎", "🍌", "🍇", "🍉", "🍊", "🍓", "🍑", "🥭", "🍍", "🥝", "🫐", "🍈", "🍒", "🥥", "🥑"]
        let vegetables = ["🥦", "🥕", "🍆", "🌽", "🥒", "🍅", "🫑", "🧄", "🧅", "🥔", "🥬", "🥗"]
        
        var body: some View {
            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    ForEach(fruits + vegetables, id: \.self) { item in
                        EmojiView(emoji: item)
                            .scrollTransition(axis: .horizontal) { content, phase in
                                return content
                                    .scaleEffect(phase.isIdentity ? 1.0 : 0.2)
                                    .opacity(phase.isIdentity ? 1.0 : 0.2)
                                    .rotationEffect(rotation(for: phase))
                            }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .frame(width: 430, height: 100)
        }
        
        func rotation(for phase: ScrollTransitionPhase) -> Angle {
            switch phase {
                case .identity:
                    return .degrees(0)
                case .topLeading:
                    return .degrees(360)
                case .bottomTrailing:
                    return .degrees(-360)
            }
        }
        
        struct EmojiView: View {
            let emoji: String
            
            var body: some View {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.gray.gradient)
                    .frame(width: 100, height: 100)
                    .overlay {
                        Text(emoji)
                            .font(.system(size: 66))
                    }

            }
        }
    }
}

// MARK: - Shader
/// https://developer.apple.com/documentation/swiftui/shader
/*
 func colorEffect(Shader, isEnabled: Bool) -> some View
    Returns a new view that applies shader to self as a filter effect on the color of each pixel.
 
 func distortionEffect(Shader, maxSampleOffset: CGSize, isEnabled: Bool) -> some View
    Returns a new view that applies shader to self as a geometric distortion effect on the location of each pixel.
 
 func layerEffect(Shader, maxSampleOffset: CGSize, isEnabled: Bool) -> some View
    Returns a new view that applies shader to self as a filter on the raster layer created from self.
 */

// MARK: - Layer Shader
#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

[[ stitchable ]]
half4 Ripple(
    float2 position,
    SwiftUI::Layer layer,
    float2 origin,
    float time,
    float amplitude,
    float frequency,
    float decay,
    float speed
) {
    // The distance of the current pixel position from `origin`.
    float distance = length(position - origin);
    // The amount of time it takes for the ripple to arrive at the current pixel position.
    float delay = distance / speed;

    // Adjust for delay, clamp to 0.
    time -= delay;
    time = max(0.0, time);

    // The ripple is a sine wave that Metal scales by an exponential decay
    // function.
    float rippleAmount = amplitude * sin(frequency * time) * exp(-decay * time);

    // A vector of length `amplitude` that points away from position.
    float2 n = normalize(position - origin);

    // Scale `n` by the ripple amount at the current pixel position and add it
    // to the current pixel position.
    //
    // This new position moves toward or away from `origin` based on the
    // sign and magnitude of `rippleAmount`.
    float2 newPosition = position + rippleAmount * n;

    // Sample the layer at the new position.
    half4 color = layer.sample(newPosition);

    // Lighten or darken the color based on the ripple amount and its alpha
    // component.
    color.rgb += 0.3 * (rippleAmount / amplitude) * color.a;

    return color;
}

/// A modifier that applies a ripple effect to its content.
struct RippleModifier: ViewModifier {
    var origin: CGPoint

    var elapsedTime: TimeInterval

    var duration: TimeInterval

    var amplitude: Double = 12
    var frequency: Double = 15
    var decay: Double = 8
    var speed: Double = 1200

    func body(content: Content) -> some View {
        let shader = ShaderLibrary.Ripple(
            .float2(origin),
            .float(elapsedTime),
            // Parameters
            .float(amplitude),
            .float(frequency),
            .float(decay),
            .float(speed)
        )

        let maxSampleOffset = maxSampleOffset
        let elapsedTime = elapsedTime
        let duration = duration

        content.visualEffect { view, _ in
            view.layerEffect(
                shader,
                maxSampleOffset: maxSampleOffset,
                isEnabled: 0 < elapsedTime && elapsedTime < duration
            )
        }
    }

    var maxSampleOffset: CGSize {
        CGSize(width: amplitude, height: amplitude)
    }
}

// MARK: - Color Shader
/// Shaders also conform to the ShapeStyle protocol, letting their MSL shader function provide per-pixel color to fill any shape or text view. For a shader function to act as a fill pattern it must have a function signature matching:
#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

[[ stitchable ]]
half4 Stripes(
    float2 position,
    float thickness,
    device const half4 *ptr,
    int count
) {
    int i = int(floor(position.y / thickness));

    // Clamp to 0 ..< count.
    i = ((i % count) + count) % count;

    return ptr[i];
}

// import SwiftUI

#Preview("Stripes") {
    VStack {
        let fill = ShaderLibrary.Stripes(
            .float(12),
            .colorArray([
                .red, .orange, .yellow, .green, .blue, .indigo
            ])
        )

        Circle().fill(fill)
    }
    .padding()
}

// MARK: - 250411 Shapes
/// Trace and fill built-in and custom shapes with a color, gradient, or other pattern.
/// https://developer.apple.com/documentation/swiftui/shapes
/// If you need the efficiency or flexibility of immediate mode drawing — for example, to create particle effects — use a Canvas view instead.

// AnyShape
/// You can use this type to dynamically switch between shape types:
struct MyClippedView: View {
    var isCircular: Bool

    var body: some View {
        OtherView().clipShape(isCircular ?
            AnyShape(Circle()) : AnyShape(Capsule()))
    }
}

/*
 SwiftUI enables custom drawing with two subtly different types: paths and shapes. A path is a series of drawing instructions such as “start here, draw a line to here, then add a circle there”, all using absolute coordinates.
 In contrast, a shape has no idea where it will be used or how big it will be used, but instead will be asked to draw itself inside a given rectangle.
 */
/// https://www.hackingwithswift.com/books/ios-swiftui/paths-vs-shapes-in-swiftui
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))

        return path
    }
}

Triangle()
    .fill(.red)
    .frame(width: 300, height: 300)

Triangle()
    .stroke(.red, style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
    .frame(width: 300, height: 300)

struct Arc: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var clockwise: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)

        return path
    }
}

Arc(startAngle: .degrees(0), endAngle: .degrees(110), clockwise: true)
    .stroke(.blue, lineWidth: 10)
    .frame(width: 300, height: 300)

/*
 If you look at the preview of our arc, chances are it looks nothing like you expect. We asked for an arc from 0 degrees to 110 degrees with a clockwise rotation, but we appear to have been given an arc from 90 degrees to 200 degrees with a counterclockwise rotation.

 What’s happening here is two-fold:
    In the eyes of SwiftUI 0 degrees is not straight upwards, but instead directly to the right.
    Shapes measure their coordinates from the bottom-left corner rather than the top-left corner, which means SwiftUI goes the other way around from one angle to the other. This is, in my not very humble opinion, extremely alien.
 */
func path(in rect: CGRect) -> Path {
    let rotationAdjustment = Angle.degrees(90)
    let modifiedStart = startAngle - rotationAdjustment
    let modifiedEnd = endAngle - rotationAdjustment

    var path = Path()
    path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2, startAngle: modifiedStart, endAngle: modifiedEnd, clockwise: !clockwise)

    return path
}

// MARK: - 250411 Menus
/// Provide space-efficient, context-dependent access to commands and controls.
/// https://developer.apple.com/documentation/swiftui/menus-and-commands
Menu("Actions") {
    Button("Duplicate", action: duplicate)
    Button("Rename", action: rename)
    Button("Delete…", action: delete)
    Menu("Copy") {
        Button("Copy", action: copy)
        Button("Copy Formatted", action: copyFormatted)
        Button("Copy Library Path", action: copyPath)
    }
}

Menu {
    Button("Open in Preview", action: openInPreview)
    Button("Save as PDF", action: saveAsPDF)
} label: {
    Label("PDF", systemImage: "doc.fill")
}

/*
 To support subtitles on menu items, initialize your Button with a view builder that creates multiple Text views where the first text represents the title and the second text represents the subtitle. The same approach applies to other controls such as Toggle:
 */

Menu {
    Button(action: openInPreview) {
        Text("Open in Preview")
        Text("View the document in Preview")
    }
    Button(action: saveAsPDF) {
        Text("Save as PDF")
        Text("Export the document as a PDF file")
    }
} label: {
    Label("PDF", systemImage: "doc.fill")
}

// MARK: - Primary action
/*
 Menus can be created with a custom primary action. The primary action will be performed when the user taps or clicks on the body of the control, and the menu presentation will happen on a secondary gesture, such as on long press or on click of the menu indicator. The following example creates a menu that adds bookmarks, with advanced options that are presented in a menu.
 */
Menu {
    Button(action: addCurrentTabToReadingList) {
        Label("Add to Reading List", systemImage: "eyeglasses")
    }
    Button(action: bookmarkAll) {
        Label("Add Bookmarks for All Tabs", systemImage: "book")
    }
    Button(action: show) {
        Label("Show All Bookmarks", systemImage: "books.vertical")
    }
} label: {
    Label("Add Bookmark", systemImage: "book")
} primaryAction: {
    addBookmark()
}

// MARK: - Menu Style
Menu("Editing") {
    Button("Set In Point", action: setInPoint)
    Button("Set Out Point", action: setOutPoint)
}
.menuStyle(EditingControlsMenuStyle())

Menu("PDF") {
    Button("Open in Preview", action: openInPreview)
    Button("Save as PDF", action: saveAsPDF)
}
.menuStyle(ButtonMenuStyle())

// MARK: - 150407 Controls And Indicators
/// https://developer.apple.com/documentation/swiftui/controls-and-indicators

// MARK: - Edit Button
@State private var fruits = [
    "Apple",
    "Banana",
    "Papaya",
    "Mango"
]


var body: some View {
    NavigationView {
        List {
            ForEach(fruits, id: \.self) { fruit in
                Text(fruit)
            }
            .onDelete { fruits.remove(atOffsets: $0) }
            .onMove { fruits.move(fromOffsets: $0, toOffset: $1) }
        }
        .navigationTitle("Fruits")
        .toolbar {
            EditButton()
        }
    }
}

// MARK: - Paste Button
@State private var pastedText: String = ""

var body: some View {
    HStack {
        PasteButton(payloadType: String.self) { strings in
            pastedText = strings[0]
        }
        Divider()
        Text(pastedText)
        Spacer()
    }
}
https://developer.apple.com/documentation/swiftui/sharelink
// MARK: - Link
Link("View Our Terms of Service",
      destination: URL(string: "https://www.example.com/TOS.html")!)

/*
 When a user taps or clicks a Link, the default behavior depends on the contents of the URL. For example, SwiftUI opens a Universal Link in the associated app if possible, or in the user’s default web browser if not. Alternatively, you can override the default behavior by setting the openURL environment value with a custom OpenURLAction:
 */
Link("Visit Our Site", destination: URL(string: "https://www.example.com")!)
    .environment(\.openURL, OpenURLAction { url in
        print("Open \(url)")
        return .handled
    })

// MARK: - ShareLink
/// A view that controls a sharing presentation.
/// https://developer.apple.com/documentation/swiftui/sharelink

ShareLink(item: URL(string: "https://developer.apple.com/xcode/swiftui/")!)

ShareLink(item: URL(string: "https://developer.apple.com/xcode/swiftui/")!) {
    Label("Share", image: "MyCustomShareIcon")
}

ShareLink("Share URL", item: URL(string: "https://developer.apple.com/xcode/swiftui/")!)

/*
 The link can share any content that is Transferable. Many framework types, like URL, already conform to this protocol. You can also make your own types transferable.

 For example, you can use ProxyRepresentation to resolve your own type to a framework type:
 */
struct Photo: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(\.image)
    }

    public var image: Image
    public var caption: String
}


struct PhotoView: View {
    let photo: Photo

    var body: View {
        photo.image
            .toolbar {
                ShareLink(
                    item: photo,
                    preview: SharePreview(
                        photo.caption,
                        image: photo.image))
            }
    }
}

/// Some share activities support subject and message fields. You can pre-populate these fields with the subject and message parameters:
ShareLink(
    item: photo,
    subject: Text("Cool Photo"),
    message: Text("Check it out!")
    preview: SharePreview(
        photo.caption,
        image: photo.image))

// MARK: - SharePreview
/// https://developer.apple.com/documentation/swiftui/sharepreview
struct Photo: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(\.image)
    }

    public var image: Image
    public var caption: String
}


struct PhotoView: View {
    let photo: Photo

    var body: View {
        photo.image
            .toolbar {
                ShareLink(
                    item: photo,
                    preview: SharePreview(
                        photo.caption,
                        image: photo.image))
            }
    }
}

/// You can also provide a preview to speed up the sharing process. In the following example the preview appears immediately;
///  if you omit the preview instead, the system fetches the link’s metadata over the network:
ShareLink(
    item: URL(string: "https://developer.apple.com/xcode/swiftui/")!,
    preview: SharePreview(
        "SwiftUI",
        image: Image("SwiftUI")
    )
)

/// You can provide unique previews for each item in a collection of items that a ShareLink links to:
ShareLink(items: photos) { photo in
    SharePreview(photo.caption, image: photo.image)
}

// MARK: - Slider
// A control for selecting a value from a bounded linear range of values.
/// https://developer.apple.com/documentation/swiftui/slider
struct Slider<Label, ValueLabel> where Label : View, ValueLabel : View

/// The onEditingChanged closure passed to the slider receives callbacks when the user drags the slider. The example uses this to change the color of the value text.
@State private var speed = 50.0
@State private var isEditing = false

var body: some View {
    VStack {
        Slider(
            value: $speed,
            in: 0...100,
            onEditingChanged: { editing in
                isEditing = editing
            }
        )
        Text("\(speed)")
            .foregroundColor(isEditing ? .red : .blue)
    }
}

@State private var speed = 50.0
@State private var isEditing = false

var body: some View {
    Slider(
        value: $speed,
        in: 0...100,
        step: 5
    ) {
        Text("Speed")
    } minimumValueLabel: {
        Text("0")
    } maximumValueLabel: {
        Text("100")
    } onEditingChanged: { editing in
        isEditing = editing
    }
    Text("\(speed)")
        .foregroundColor(isEditing ? .red : .blue)
}

// MARK: - Stepper
// A control that performs increment and decrement actions.
/// https://developer.apple.com/documentation/swiftui/stepper

struct StepperView: View {
    @State private var value = 0
    let colors: [Color] = [.orange, .red, .gray, .blue,
                           .green, .purple, .pink]

    func incrementStep() {
        value += 1
        if value >= colors.count { value = 0 }
    }

    func decrementStep() {
        value -= 1
        if value < 0 { value = colors.count - 1 }
    }

    var body: some View {
        Stepper {
            Text("Value: \(value) Color: \(colors[value].description)")
        } onIncrement: {
            incrementStep()
        } onDecrement: {
            decrementStep()
        }
        .padding(5)
        .background(colors[value])
    }
}

/// The following example shows a stepper that displays the effect of incrementing or decrementing a value with the step size of step with the bounds defined by range:
struct StepperView: View {
    @State private var value = 0
    let step = 5
    let range = 1...50

    var body: some View {
        Stepper(
            value: $value,
            in: range,
            step: step
        ) {
            Text("Current: \(value) in \(range.description) " +
                 "stepping by \(step)")
        }
        .padding(10)
    }
}

// MARK: - Toggle
// A control that toggles between on and off states.
/// https://developer.apple.com/documentation/swiftui/toggle

@State private var vibrateOnRing = false
var body: some View {
    Toggle(isOn: $vibrateOnRing) {
        Text("Vibrate on Ring")
    }
}

@State private var vibrateOnRing = true
var body: some View {
    Toggle(
        "Vibrate on Ring",
        systemImage: "dot.radiowaves.left.and.right",
        isOn: $vibrateOnRing
    )
}

@State private var vibrateOnRing = true
var body: some View {
    Toggle("Vibrate on Ring", isOn: $vibrateOnRing)
}

/// For cases where adding a subtitle to the label is desired,
/// use a view builder that creates multiple Text views where the first text represents the title and the second text represents the subtitle:
@State private var vibrateOnRing = false
var body: some View {
    Toggle(isOn: $vibrateOnRing) {
        Text("Vibrate on Ring")
        Text("Enable vibration when the phone rings")
    }
}

// MARK: - Toggle Style
VStack {
    Toggle("Vibrate on Ring", isOn: $vibrateOnRing)
    Toggle("Vibrate on Silent", isOn: $vibrateOnSilent)
}
.toggleStyle(.switch)

/// https://developer.apple.com/documentation/swiftui/togglestyle
@MainActor @preconcurrency
protocol ToggleStyle

Toggle(isOn: $isFlagged) {
    Label("Flag", systemImage: "flag.fill")
}
.toggleStyle(.button)

struct ChecklistToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack {
                Image(systemName: configuration.isOn
                        ? "checkmark.circle.fill"
                        : "circle")
                configuration.label
            }
        }
        .tint(.primary)
        .buttonStyle(.borderless)
    }
}

extension ToggleStyle where Self == ChecklistToggleStyle {
    static var checklist: ChecklistToggleStyle { .init() }
}

Toggle(activity.name, isOn: $activity.isComplete)
    .toggleStyle(.checklist)

/// A type conforming to this protocol inherits @preconcurrency @MainActor isolation from the protocol if the conformance is included in the type’s base declaration:
struct MyCustomType: Transition {
    // `@preconcurrency @MainActor` isolation by default
}

/// Isolation to the main actor is the default, but it’s not required. Declare the conformance in an extension to opt out of main actor isolation:
extension MyCustomType: Transition {
    // `nonisolated` by default
}

// MARK: - Picker
// A control for selecting from a set of mutually exclusive values.
/// https://developer.apple.com/documentation/swiftui/picker
enum Flavor: String, CaseIterable, Identifiable {
    case chocolate, vanilla, strawberry
    var id: Self { self }
}

@State private var selectedFlavor: Flavor = .chocolate
List {
    Picker("Flavor", selection: $selectedFlavor) {
        Text("Chocolate").tag(Flavor.chocolate)
        Text("Vanilla").tag(Flavor.vanilla)
        Text("Strawberry").tag(Flavor.strawberry)
    }
}

/*
 For cases where adding a subtitle to the label is desired, use a view builder that creates multiple Text views where the first text represents the title and the second text represents the subtitle:
 */
List {
    Picker(selection: $selectedFlavor) {
        Text("Chocolate").tag(Flavor.chocolate)
        Text("Vanilla").tag(Flavor.vanilla)
        Text("Strawberry").tag(Flavor.strawberry)
    } label: {
        Text("Flavor")
        Text("Choose your favorite flavor")
    }
}

// MARK: - Iterating over a picker’s options
/// To provide selection values for the Picker without explicitly listing each option, you can create the picker with a ForEach:
/// ForEach automatically assigns a tag to the selection views using each option’s id. This is possible because Flavor conforms to the Identifiable protocol.
Picker("Flavor", selection: $selectedFlavor) {
    ForEach(Flavor.allCases) { flavor in
        Text(flavor.rawValue.capitalized)
    }
}

// Override the Tag
/// The example above relies on the fact that Flavor defines the type of its id parameter to exactly match the selection type. If that’s not the case, you need to override the tag. For example, consider a Topping type and a suggested topping for each flavor:
enum Topping: String, CaseIterable, Identifiable {
    case nuts, cookies, blueberries
    var id: Self { self }
}

extension Flavor {
    var suggestedTopping: Topping {
        switch self {
        case .chocolate: return .nuts
        case .vanilla: return .cookies
        case .strawberry: return .blueberries
        }
    }
}

@State private var suggestedTopping: Topping = .nuts
List {
    Picker("Flavor", selection: $suggestedTopping) {
        ForEach(Flavor.allCases) { flavor in
            Text(flavor.rawValue.capitalized)
                .tag(flavor.suggestedTopping)
        }
    }
    HStack {
        Text("Suggested Topping")
        Spacer()
        Text(suggestedTopping.rawValue.capitalized)
            .foregroundStyle(.secondary)
    }
}

// MARK: - Styling pickers
/*
 You can customize the appearance and interaction of pickers using styles that conform to the PickerStyle protocol, like segmented or menu. To set a specific style for all picker instances within a view, use the pickerStyle(_:) modifier. The following example applies the segmented style to two pickers that independently select a flavor and a topping:
 */
VStack {
    Picker("Flavor", selection: $selectedFlavor) {
        ForEach(Flavor.allCases) { flavor in
            Text(flavor.rawValue.capitalized)
        }
    }
    Picker("Topping", selection: $selectedTopping) {
        ForEach(Topping.allCases) { topping in
            Text(topping.rawValue.capitalized)
        }
    }
}
.pickerStyle(.segmented)

// MARK: - Date Picker
// A control for selecting an absolute date.
/// https://developer.apple.com/documentation/swiftui/datepicker

@State private var date = Date()
var body: some View {
    DatePicker(
        "Start Date",
        selection: $date,
        displayedComponents: [.date]
    )
}

/// For cases where adding a subtitle to the label is desired,
/// use a view builder that creates multiple Text views where the first text represents the title and the second text represents the subtitle:
@State private var date = Date()
var body: some View {
    DatePicker(selection: $date) {
        Text("Start Date")
        Text("Select the starting date for the event")
    }
}

/*
 You can limit the DatePicker to specific ranges of dates, allowing selections only before or after a certain date, or between two dates. The following example shows a date-and-time picker that only permits selections within the year 2021 (in the UTC time zone).
 */
@State private var date = Date()
let dateRange: ClosedRange<Date> = {
    let calendar = Calendar.current
    let startComponents = DateComponents(year: 2021, month: 1, day: 1)
    let endComponents = DateComponents(year: 2021, month: 12, day: 31, hour: 23, minute: 59, second: 59)
    return calendar.date(from:startComponents)!
        ...
        calendar.date(from:endComponents)!
}()

var body: some View {
    DatePicker(
        "Start Date",
         selection: $date,
         in: dateRange,
         displayedComponents: [.date, .hourAndMinute]
    )
}

///To use a different style of date picker, use the datePickerStyle(_:) view modifier. The following example shows the graphical date picker style.
@State private var date = Date()
var body: some View {
    DatePicker(
        "Start Date",
        selection: $date,
        displayedComponents: [.date]
    )
    .datePickerStyle(.graphical)
}

// MARK: - Multi Date Picker
// A control for picking multiple dates.
/// https://developer.apple.com/documentation/swiftui/multidatepicker
@State private var dates: Set<DateComponents> = []
var body: some View {
    MultiDatePicker("Dates Available", selection: $dates)
}

/*
 You can limit the MultiDatePicker to specific ranges of dates allowing selections only before or after a certain date or between two dates. The following example shows a multi-date picker that only permits selections within the 6th and (excluding) the 16th of December 2021 (in the UTC time zone):
 */
@Environment(\.calendar) var calendar
@Environment(\.timeZone) var timeZone

var bounds: Range<Date> {
    let start = calendar.date(from: DateComponents(
        timeZone: timeZone, year: 2022, month: 6, day: 6))!
    let end = calendar.date(from: DateComponents(
        timeZone: timeZone, year: 2022, month: 6, day: 16))!
    return start ..< end
}

@State private var dates: Set<DateComponents> = []

var body: some View {
    MultiDatePicker("Dates Available", selection: $dates, in: bounds)
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MultiDatePicker("Dates Available", selection: .constant([]))
            .environment(\.locale, Locale.init(identifier: "zh"))
            .environment(
                \.calendar, Calendar.init(identifier: .chinese))
            .environment(\.timeZone, TimeZone(abbreviation: "HKT")!)
    }
}

// MARK: - Color Picker
struct FormattingControls: View {
    @State private var bgColor =
        Color(.sRGB, red: 0.98, green: 0.9, blue: 0.2)

    var body: some View {
        VStack {
            ColorPicker("Alignment Guides", selection: $bgColor)
        }
    }
}

// MARK: - Gauge
struct SimpleGauge: View {
    @State private var batteryLevel = 0.4
    var body: some View {
        Gauge(value: batteryLevel) {
            Text("Battery Level")
        }
    }
}

struct LabeledGauge: View {
    @State private var current = 67.0
    @State private var minValue = 0.0
    @State private var maxValue = 170.0

    var body: some View {
        Gauge(value: current, in: minValue...maxValue) {
            Text("BPM")
        } currentValueLabel: {
            Text("\(Int(current))")
        } minimumValueLabel: {
            Text("\(Int(minValue))")
        } maximumValueLabel: {
            Text("\(Int(maxValue))")
        }
    }
}

/*
 Some visual presentations of Gauge don’t display all the labels required by the API. However, the accessibility system does use the label content and you should use these labels to fully describe the gauge for accessibility users.
 */

struct LabeledGauge: View {
    @State private var current = 67.0
    @State private var minValue = 0.0
    @State private var maxValue = 170.0

    var body: some View {
        Gauge(value: current, in: minValue...maxValue) {
            Text("BPM")
        } currentValueLabel: {
            Text("\(Int(current))")
        } minimumValueLabel: {
            Text("\(Int(minValue))")
        } maximumValueLabel: {
            Text("\(Int(maxValue))")
        }
        .gaugeStyle(.circular)
    }
}

// with custom colors
struct StyledGauge: View {
    @State private var current = 67.0
    @State private var minValue = 50.0
    @State private var maxValue = 170.0

    var body: some View {
        Gauge(value: current, in: minValue...maxValue) {
            Image(systemName: "heart.fill")
                .foregroundColor(.red)
        } currentValueLabel: {
            Text("\(Int(current))")
                .foregroundColor(Color.green)
        } minimumValueLabel: {
            Text("\(Int(minValue))")
                .foregroundColor(Color.green)
        } maximumValueLabel: {
            Text("\(Int(maxValue))")
                .foregroundColor(Color.red)
        }
        .gaugeStyle(.circular)
    }
}

/// You can further style a gauge’s appearance by supplying a tint color or a gradient to the style’s initializer.
/// The following example shows the effect of a gradient in the initialization of a CircularGaugeStyle gauge with a colorful gradient across the length of the gauge:
struct StyledGauge: View {
    @State private var current = 67.0
    @State private var minValue = 50.0
    @State private var maxValue = 170.0
    let gradient = Gradient(colors: [.green, .yellow, .orange, .red])

    var body: some View {
        Gauge(value: current, in: minValue...maxValue) {
            Image(systemName: "heart.fill")
                .foregroundColor(.red)
        } currentValueLabel: {
            Text("\(Int(current))")
                .foregroundColor(Color.green)
        } minimumValueLabel: {
            Text("\(Int(minValue))")
                .foregroundColor(Color.green)
        } maximumValueLabel: {
            Text("\(Int(maxValue))")
                .foregroundColor(Color.red)
        }
        .gaugeStyle(CircularGaugeStyle(tint: gradient))
    }
}

// MARK: - Progress View
/// https://developer.apple.com/documentation/swiftui/progressview
struct LinearProgressDemoView: View {
    @State private var progress = 0.5
    
    var body: some View {
        VStack {
            ProgressView(value: progress)
            Button("More") { progress += 0.05 }
        }
    }
}

var body: some View {
    ProgressView()
}

/*
 You can also create a progress view that covers a closed range of Date values. As long as the current date is within the range, the progress view automatically updates, filling or depleting the progress view as it nears the end of the range. The following example shows a five-minute timer whose start time is that of the progress view’s initialization:
 */

struct DateRelativeProgressDemoView: View {
    let workoutDateRange = Date()...Date().addingTimeInterval(5*60)

    var body: some View {
         ProgressView(timerInterval: workoutDateRange) {
             Text("Workout")
         }
    }
}

// MARK: - Styling progress views
struct BorderedProgressViews: View {
    var body: some View {
        VStack {
            ProgressView(value: 0.25) { Text("25% progress") }
            ProgressView(value: 0.75) { Text("75% progress") }
        }
        .progressViewStyle(PinkBorderedProgressViewStyle())
    }
}

struct PinkBorderedProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ProgressView(configuration)
            .padding(4)
            .border(.pink, width: 3)
            .cornerRadius(4)
    }
}

struct CircularProgressDemoView: View {
    @State private var progress = 0.6

    var body: some View {
        VStack {
            ProgressView(value: progress)
                .progressViewStyle(.circular)
        }
    }
}

// MARK: - ContentUnavailableView
ContentUnavailableView {
    Label("No Mail", systemImage: "tray.fill")
} description: {
    Text("New mails you receive will appear here.")
}

struct ContentView: View {
    @ObservedObject private var viewModel = ContactsViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.searchResults) { contact in
                    NavigationLink {
                        ContactsView(contact)
                    } label: {
                        Text(contact.name)
                    }
                }
            }
            .navigationTitle("Contacts")
            .searchable(text: $viewModel.searchText)
            .overlay {
                if searchResults.isEmpty {
                    ContentUnavailableView.search
                }
            }
        }
    }
}

// MARK: - Haptic Feedback
/*
 func sensoryFeedback<T>(SensoryFeedback, trigger: T) -> some View
    Plays the specified feedback when the provided trigger value changes.
 
 func sensoryFeedback<T>(trigger: T, (T, T) -> SensoryFeedback?) -> some View
    Plays feedback when returned from the feedback closure after the provided trigger value changes.
 
 func sensoryFeedback<T>(SensoryFeedback, trigger: T, condition: (T, T) -> Bool) -> some View
    Plays the specified feedback when the provided trigger value changes and the condition closure returns true.
 */

struct MyView: View {
    @State private var showAccessory = false
    var body: some View {
        ContentView()
            .sensoryFeedback(.selection, trigger: showAccessory)
            .onLongPressGesture {
                showAccessory.toggle()
            }
        
        if showAccessory {
            AccessoryView()
        }
    }
}

struct MyView: View {
    @State private var phase = Phase.inactive
    var body: some View {
        ContentView(phase: $phase)
            .sensoryFeedback(trigger: phase) { old, new in
                switch (old, new) {
                    case (.inactive, _): return .success
                    case (_, .expanded): return .impact
                    default: return nil
                }
            }
    }


    enum Phase {
        case inactive
        case preparing
        case active
        case expanded
    }
}

struct MyView: View {
    @State private var phase = Phase.inactive

    var body: some View {
        ContentView(phase: $phase)
            .sensoryFeedback(.selection, trigger: phase) { old, new in
                old == .inactive || new == .expanded
            }
    }

    enum Phase {
        case inactive
        case preparing
        case active
        case expanded
    }
}

// MARK: - ControlSize
// The size classes, like regular or small, that you can apply to controls within a view.
/*
 case mini
    A control version that is minimally sized.
 
 case small
    A control version that is proportionally smaller size for space-constrained views.
 
 case regular
    A control version that is the default size.
 
 case large
    A control version that is prominently sized.
 
 case extraLarge
    A control version that is substantially sized. The largest control size. Resolves to ControlSize.large on platforms other than visionOS.
 */

// MARK: - 250406 Images
/// https://developer.apple.com/documentation/swiftui/images

// Fit Image Into Available Space
/// https://developer.apple.com/documentation/swiftui/fitting-images-into-available-space
Image("Landscape_4")
     .resizable()
     .aspectRatio(contentMode: .fill)
     .frame(width: 300, height: 400, alignment: .topLeading)
     .border(.blue)
     .clipped()

Image("dot_green")
    .resizable()
    .interpolation(.none)
    .aspectRatio(contentMode: .fit)
    .frame(width: 300, height: 400, alignment: .topLeading)
    .border(.blue)

/// Fill a space with a repeating image using tiling
Image("dot_green")
       .resizable(resizingMode: .tile)
       .frame(width: 300, height: 400, alignment: .topLeading)
       .border(.blue)

// MARK: - Async Image
/// https://developer.apple.com/documentation/swiftui/asyncimage
/// WARNING: -- You can’t apply image-specific modifiers, like resizable(capInsets:resizingMode:),
/// directly to an AsyncImage. Instead,
/// apply them to the Image instance that your content closure gets when defining the view’s appearance.
AsyncImage(url: URL(string: "https://example.com/icon.png")) { image in
    image.resizable()
} placeholder: {
    ProgressView()
}
.frame(width: 50, height: 50)

AsyncImage(url: URL(string: "https://example.com/icon.png")) { phase in
    if let image = phase.image {
        image // Displays the loaded image.
    } else if phase.error != nil {
        Color.red // Indicates an error.
    } else {
        Color.blue // Acts as a placeholder.
    }
}

/*
 Getting load phases
    case empty
        No image is loaded.
    case success(Image)
        An image succesfully loaded.
    case failure(any Error)
        An image failed to load with an error.
 */

// MARK: - SymbolVariant
Image(systemName: "arrow.left")
    .symbolVariant(.square) // This shape takes precedence.
    .symbolVariant(.circle)
    .symbolVariant(.fill)

// or
Label("Airplane", systemImage: "airplane")
    .symbolVariant(.circle.fill)

// MARK: - Symbol Render Mode
/*
 static let hierarchical: SymbolRenderingMode
    renders symbols as multiple layers, with different opacities applied to the foreground style.
 static let monochrome: SymbolRenderingMode
    renders symbols as a single layer filled with the foreground style.
 static let multicolor: SymbolRenderingMode
    renders symbols as multiple layers with their inherit styles.
 static let palette: SymbolRenderingMode
    renders symbols as multiple layers, with different styles applied to the layers.
 */
Image(systemName: "exclamationmark.triangle.fill")
    .symbolRenderingMode(.palette)
    .foregroundStyle(Color.yellow, Color.cyan)

// MARK: - ImageRenderer
// An object that creates images from SwiftUI views.
/// https://developer.apple.com/documentation/swiftui/imagerenderer
/*
 Use ImageRenderer to export bitmap image data from a SwiftUI view. You initialize the renderer with a view, then render images on demand, either by calling the render(rasterizationScale:renderer:) method, or by using the renderer’s properties to create a CGImage, NSImage, or UIImage.
 */

var body: some View {
    let trophyAndDate = createAwardView(forUser: playerName,
                                         date: achievementDate)
    VStack {
        trophyAndDate
        Button("Save Achievement") {
            let renderer = ImageRenderer(content: trophyAndDate)
            if let image = renderer.cgImage {
                uploadAchievementImage(image)
            }
        }
    }
}


private func createAwardView(forUser: String, date: Date) -> some View {
    VStack {
        Image(systemName: "trophy")
            .resizable()
            .frame(width: 200, height: 200)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .shadow(color: .mint, radius: 5)
        Text(playerName)
            .font(.largeTitle)
        Text(achievementDate.formatted())
    }
    .multilineTextAlignment(.center)
    .frame(width: 200, height: 290)
}

/*
 Because ImageRenderer conforms to ObservableObject, you can use it to produce a stream of images as its properties change. Subscribe to the renderer’s objectWillChange publisher, then use the renderer to rasterize a new image each time the subscriber receives an update.
 */

// MARK: - Rendering to a PDF context
/*
 The render(rasterizationScale:renderer:) method renders the specified view to any CGContext. That means you aren’t limited to creating a rasterized CGImage. For example, you can generate PDF data by rendering to a PDF context. The resulting PDF maintains resolution-independence for supported members of the view hierarchy, such as text, symbol images, lines, shapes, and fills.

 The following example uses the createAwardView(forUser:date:) method from the previous example, and exports its contents as an 800-by-600 point PDF to the file URL renderURL. It uses the size parameter sent to the rendering closure to center the trophyAndDate view vertically and horizontally on the page.
 */

var body: some View {
    let trophyAndDate = createAwardView(forUser: playerName,
                                        date: achievementDate)
    VStack {
        trophyAndDate
        Button("Save Achievement") {
            let renderer = ImageRenderer(content: trophyAndDate)
            renderer.render { size, renderer in
                var mediaBox = CGRect(origin: .zero,
                                      size: CGSize(width: 800, height: 600))
                guard let consumer = CGDataConsumer(url: renderURL as CFURL),
                      let pdfContext =  CGContext(consumer: consumer,
                                                  mediaBox: &mediaBox, nil)
                else {
                    return
                }
                pdfContext.beginPDFPage(nil)
                pdfContext.translateBy(x: mediaBox.size.width / 2 - size.width / 2,
                                       y: mediaBox.size.height / 2 - size.height / 2)
                renderer(pdfContext)
                pdfContext.endPDFPage()
                pdfContext.closePDF()
            }
        }
    }
}

// MARK: - 150406 Text and symbol modifiers
/// https://developer.apple.com/documentation/swiftui/view-text-and-symbols

// MARK: - textSelection
var body: some View {
    VStack {
        Text("Event Invite")
            .font(.title)
        Text(invite.date.formatted(date: .long, time: .shortened))
            .textSelection(.enabled)

        List(invite.recipients) { recipient in
            VStack (alignment: .leading) {
                Text(recipient.name)
                Text(recipient.email)
                    .foregroundStyle(.secondary)
            }
        }
        .textSelection(.enabled)
    }
    .navigationTitle("New Invitation")
}

// MARK: - Text Selection Binding
struct SuggestionTextEditor: View {
    @State var text: String = ""
    @State var selection: TextSelection? = nil

    var body: some View {
        VStack {
            TextEditor(text: $text, selection: $selection)
            // A helper view that offers live suggestions based on selection.
            SuggestionsView(
                substrings: getSubstrings(text: text, indices: selection?.indices))
        }
        .textSelectionAffinity(.upstream)
    }

    private func getSubstrings(
        text: String, indices: TextSelection.Indices?
    ) -> [Substring] {
        // Resolve substrings representing the current selection...
    }
}

// struct SuggestionsView: View { ... }

// MARK: - Scaled Metric
struct ContentView: View {
    @ScaledMetric(relativeTo: .body) var scaledPadding: CGFloat = 10
    var body: some View {
        Text("The quick brown fox jumps over the lazy dog.")
            .font(Font.custom("MyFont", size: 18))
            .padding(scaledPadding)
            .border(Color.blue)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: - 250405 Accessibility modifiers
/// https://developer.apple.com/documentation/swiftui/view-accessibility

// sensoryFeedback
struct MyView: View {
    @State private var showAccessory = false
    
    var body: some View {
        ContentView()
            .sensoryFeedback(.selection, trigger: showAccessory)
            .onLongPressGesture {
                showAccessory.toggle()
            }

        if showAccessory {
            AccessoryView()
        }
    }
}

// MARK: - Designing your app for the Always On state
/// https://developer.apple.com/documentation/watchOS-Apps/designing-your-app-for-the-always-on-state
/// Customize your watchOS app’s user interface for continuous display.
TimelineView(PeriodicTimelineSchedule(from: Date(), by: 1.0/60.0)) { context in
    switch context.cadence {
    case .live:
        // Display up to 60 updates per second.
    case .seconds:
        // Only show items that update approximately once per second.
    case .minutes:
        // Only show items that update approximately once per minute.
    @unknown default:
       fatalError("*** Received an unknown cadence: \(context.cadence) ***")
    }
}

// MARK: - 250405 View Fundamentals
/// https://developer.apple.com/documentation/swiftui/view-fundamentals

// define the expensive object once and share it across multiple previews using the PreviewModifier protocol.
/*
 -- Define a structure conforming to the PreviewModifier protocol.
 -- Implement the static makeSharedContext() function returning the object with the expensive state.
 -- Inject that shared context into the view you want to preview using the body(content:context:) function.
 -- Add the modifier to the preview using the Preview(_:traits:_:body:) macro.
 */
// Create a struct conforming to the PreviewModifier protocol.
struct SampleData: PreviewModifier {
    // Define the object to share and return it as a shared context.
    static func makeSharedContext() async throws -> AppState {
        let appState = AppState()
        appState.expensiveObject = "An expensive object to reuse in previews"
        return appState
    }

    func body(content: Content, context: AppState) -> some View {
        // Inject the object into the view to preview.
        content
            .environment(context)
    }
}

// Add the modifier to the preview.
#Preview(traits: .modifier(SampleData())) {
    ComplexView()
}

// MARK: - Preview Trails
struct NavEmbedded: PreviewModifier {
    func body(content: Content, context: Void) -> some View {
        NavigationStack {
            content
        }
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    static var navEmbedded: Self = .modifier(NavEmbedded())
}

struct MockData: PreviewModifier {
    func body(content: Content, context: ModelContainer) -> some View {
        content
            .modelContainer(context)
    }
    
    static func makeSharedContext() async throws -> ModelContainer {
        let container = try! ModelContainer(
            for: Person.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        container.mainContext.insert(Person(firstName: "Stewart", lastName: "Lynch"))
        // ...

        return container
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    static var mockData: Self = .modifier(MockData())
}

// MARK: - Sample View Usage
struct PersonView: View {
    @Bindable var person: Person
    var body: some View {
        Form {
            TextField("First name", text: $person.firstName)
            TextField("Last Name", text: $person.lastName)
        }
        .font(.title)
            .navigationTitle("\(person.firstName) \(person.lastName)")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview(traits: .navEmbedded, .mockData) {
    @Previewable @Query(sort: \Person.lastName) var people: [Person]
    PersonView(person: people[0])
}

// MARK: - 250405 Persistent storage
/// https://developer.apple.com/documentation/swiftui/persistent-storage

@SceneStorage("ContentView.selectedProduct") private var selectedProduct: String?
@SceneStorage("DetailView.selectedTab") private var selectedTab = Tabs.detail

// MARK: - NSUserActivity
struct ContentView: View {
    // The data model for storing all the products.
    @EnvironmentObject var productsModel: ProductsModel
    
    // Used for detecting when this scene is backgrounded and isn't currently visible.
    @Environment(\.scenePhase) private var scenePhase

    // The currently selected product, if any.
    @SceneStorage("ContentView.selectedProduct") private var selectedProduct: String?
    
    let columns = Array(repeating: GridItem(.adaptive(minimum: 94, maximum: 120)), count: 3)
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(productsModel.products) { product in
                        NavigationLink(destination: DetailView(product: product, selectedProductID: $selectedProduct),
                                       tag: product.id.uuidString,
                                       selection: $selectedProduct) {
                            StackItemView(itemName: product.name, imageName: product.imageName)
                        }
                        .padding(8)
                        .buttonStyle(PlainButtonStyle())
                        
                        .onDrag {
                            /** Register the product user activity as part of the drag provider which
                                will  create a new scene when dropped to the left or right of the iPad screen.
                            */
                            let userActivity = NSUserActivity(activityType: DetailView.productUserActivityType)
                            
                            let localizedString = NSLocalizedString("DroppedProductTitle", comment: "Activity title with product name")
                            userActivity.title = String(format: localizedString, product.name)
                            
                            userActivity.targetContentIdentifier = product.id.uuidString
                            try? userActivity.setTypedPayload(product)
                            
                            return NSItemProvider(object: userActivity)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("ProductsTitle")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        
        .onContinueUserActivity(DetailView.productUserActivityType) { userActivity in
            if let product = try? userActivity.typedPayload(Product.self) {
                selectedProduct = product.id.uuidString
            }
        }
        .onChange(of: scenePhase) { newScenePhase in
            if newScenePhase == .background {
                // Make sure to save any unsaved changes to the products model.
                productsModel.save()
            }
        }
    }
}

// Product
class Product: Hashable, Identifiable, Codable, ObservableObject {
    let id: UUID
    let imageName: String
    @Published var name: String
    @Published var year: Int
    @Published var price: Double
    
    init(identifier: UUID, name: String, imageName: String, year: Int, price: Double) {
        self.name = name
        self.imageName = imageName
        self.year = year
        self.price = price
        self.id = identifier
    }
    
    // MARK: - Equatable
    
    static func == (lhs: Product, rhs: Product) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // MARK: - Codable
    
    private enum CoderKeys: String, CodingKey {
        case name
        case imageName
        case year
        case price
        case identifier
    }

    // Used for persistent storing of products to disk.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CoderKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(imageName, forKey: .imageName)
        try container.encode(year, forKey: .year)
        try container.encode(price, forKey: .price)
        try container.encode(id, forKey: .identifier)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CoderKeys.self)
        name = try values.decode(String.self, forKey: .name)
        year = try values.decode(Int.self, forKey: .year)
        price = try values.decode(Double.self, forKey: .price)
        imageName = try values.decode(String.self, forKey: .imageName)
        id = try values.decode(UUID.self, forKey: .identifier)
    }
}



// MARK: - 250405 Preferences
/// https://developer.apple.com/documentation/swiftui/preferences

/// Whereas you use the environment to configure the subviews of a view,
/// you use preferences to send configuration information from subviews toward their container.
/// However, unlike configuration information that flows down a view hierarchy from one container to many subviews,
/// a single container needs to reconcile potentially conflicting preferences flowing up from its many subviews.

/*
 When you use the PreferenceKey protocol to define a custom preference,
 you indicate how to merge preferences from multiple subviews.
 You can then set a value for the preference on a view using the preference(key:value:) view modifier.
 Many built-in modifiers, like navigationTitle(_:),
 rely on preferences to send configuration information to their container.
 */

/// https://www.kodeco.com/26733845-swiftui-view-preferences-tutorial-for-ios
/*
 There are three parts to making and using a view preference:
    -- Defining the preference key and the type of value it represents.
    -- Reporting a value for the preference key by a child view.
    -- Listening for those values on an ancestor view.
 */

struct TargetModel: Equatable, Identifiable {
  let id: Int
  let anchor: Anchor<CGRect>
}

// 1.
struct TargetPreferenceKey: PreferenceKey {
  // 2.
  static var defaultValue: [TargetModel] = []
  // 3.
  static func reduce(
    value: inout [TargetModel],
    nextValue: () -> [TargetModel]
  ) {
    value.append(contentsOf: nextValue())
  }
}

// for child view
    .anchorPreference(key: TargetPreferenceKey.self, value: .bounds) { anchor in
      [TargetModel(id: id, anchor: anchor)]
    }

// for parent view
@State var targets: [TargetModel] = []
    .onPreferenceChange(TargetPreferenceKey.self) { value in
        targets = value
    }

/// In ContentView, update the onChange(of:) modifier where you listen to changes of selectedTargetId. Replace the print statement with the following code:

/// 1. The handler uses the new ID value to find the TargetModel that matches the flower.
guard let target = targets.first(where: { $0.id == newValue }) else {
  return
}

/// 2. geometry is the GeometryProxy for the current view. This is why you are using anchors in the preference value — you can use an anchor as a subscript on geometry and get back the flower’s frame converted to the local coordinate space. Isn’t that just amazingly useful?
let targetFrame = geometry[target.anchor]

/// 3. Using the flower’s frame, you’re calculating the midpoint of the flower and setting beePosition to match. The existing animation takes over and Buzzy takes flight.
beePosition = CGPoint(x: targetFrame.midX, y: targetFrame.midY)

/// Create Mini Map
///https://www.kodeco.com/26733845-swiftui-view-preferences-tutorial-for-ios/page/3

let miniMapScale: CGFloat = 0.25

/*
 Here’s what this code is doing:
    -- overlayPreferenceValue(_:_:) is a view modifier that lets you transform the values of a preference key into an overlay view.
    -- At the moment, your overlay is just a rounded rectangle, you’ll add more interesting content shortly.
    -- You use miniMapScale to create a scaled-down version of the content view’s frame using the geometry reader.
 */
// 1.
.overlayPreferenceValue(TargetPreferenceKey.self) { mapTargets in
  // 2.
  ZStack {
    RoundedRectangle(cornerRadius: 8, style: .circular)
      .stroke(Color.black)
  }
  // 3.
  .frame(
    width: geometry.size.width * miniMapScale,
    height: geometry.size.height * miniMapScale)
  .position(x: geometry.size.width - 80, y: 100)
}

/*
 This is a lot of code, so here’s a breakdown of what is happening:

    -- ForEach is going to create a view for each TargetModel.
    -- GoemetryProxy extracts the frame for each target (and again, marvel at how useful and easy this is!).
    -- You use an affine transform to make a minimap-relative frame by scaling the original frame of the target down.
    -- You switch on each target’s ID to distinguish between flowers and the hive.
    -- house.fill adds a purple icon for the hive, and uses the map target frame to specify a suitable size and position.
    -- seal.fill adds a yellow icon for all the other targets (i.e. flowers) and assigns a size and a position for them too.
 */

.overlayPreferenceValue(TargetPreferenceKey.self) { mapTargets in
  ZStack {
    RoundedRectangle(cornerRadius: 8, style: .circular)
      .stroke(Color.black)
      
      // 1.
      ForEach(mapTargets) { target in
        // 2.
        let targetFrame = geometry[target.anchor]
        // 3.
        let mapTargetFrame = targetFrame.applying(
          CGAffineTransform(scaleX: miniMapScale, y: miniMapScale))

        // 4.
        switch target.id {
        // 5.
        case TargetModel.hiveID:
          Image(systemName: "house.fill")
            .foregroundColor(.purple)
            .frame(width: mapTargetFrame.width, height: mapTargetFrame.height)
            .position(x: mapTargetFrame.midX, y: mapTargetFrame.midY)
        // 6.
        default:
          Image(systemName: "seal.fill")
            .foregroundColor(.yellow)
            .frame(width: mapTargetFrame.width, height: mapTargetFrame.height)
            .position(x: mapTargetFrame.midX, y: mapTargetFrame.midY)
        }
      }
  }
  .frame(
    width: geometry.size.width * miniMapScale,
    height: geometry.size.height * miniMapScale)
  .position(x: geometry.size.width - 80, y: 100)
}

// MARK: - 250405 Environment values
/// https://developer.apple.com/documentation/swiftui/environment-values
/*
 A view inherits its environment from its container view,
 subject to explicit changes from an environment(_:_:) view modifier,
 or by implicit changes from one of the many modifiers that operate on environment values.
 As a result, you can configure a entire hierarchy of views by modifying the environment of the group’s container.
 */

// MARK: - EnvironmentValues
/// A collection of environment values propagated through a view hierarchy.
/// https://developer.apple.com/documentation/swiftui/environmentvalues
/// Create a custom environment value by declaring a new property in an extension to the environment values structure and applying the Entry() macro to the variable declaration:
extension EnvironmentValues {
    @Entry var myCustomValue: String = "Default value"
}

extension View {
    func myCustomValue(_ myCustomValue: String) -> some View {
        environment(\.myCustomValue, myCustomValue)
    }
}

// Ref: previous ways
/// https://stackoverflow.com/questions/71719412/swiftui-globally-changing-an-environment-variable
@Observable
final class Theme {
    var accentColour: NSColor
    
    init(accentColour: NSColor) {
        self.accentColour = accentColour
    }
}

extension EnvironmentValues {
    var accentColour: Theme {
        get {
            self[AccentColourKey.self]
        } set {
            self[AccentColourKey.self] = newValue
        }
    }
}

struct AccentColourKey: EnvironmentKey {
    static var defaultValue: Theme = .init(accentColour: .controlAccentColor)
}

struct EnvironmentView: View {
    @Environment(\.accentColour) var theme: Theme
    
    var body: some View {
        Button(action: {
            withAnimation(.bouncy) {
                theme.accentColour = .cyan
            }
        }, label: {
            Text("Tap me")
        })
        .buttonStyle(.borderedProminent)
        .tint(Color(nsColor: self.theme.accentColour))
        .font(.largeTitle)
    }
}

///declaration of your environment inside a view
@Environment(\.preferredColorTheme) var colorTheme: Color.Theme

///the assignment of the new theme goes wherever you need, inside a button action, onChange modifier, init, ...
let blackTheme = BlackTheme()
colorTheme.theme = blackTheme

// MARK: - Entry
/// Macro --- Creates an environment values, transaction, container values, or focused values entry.
/// https://developer.apple.com/documentation/swiftui/entry()

// Environment Values
/// https://developer.apple.com/documentation/swiftui/environmentvalues
@Environment(\.locale) var locale: Locale

extension EnvironmentValues {
    @Entry var myCustomValue: String = "Default value"
}

extension View {
    func myCustomValue(_ myCustomValue: String) -> some View {
        environment(\.myCustomValue, myCustomValue)
    }
}

// Container Value
/// https://developer.apple.com/documentation/swiftui/containervalues
@ViewBuilder var content: some View {
    Text("A")
        .containerValue(\.myCustomValue, 1)
}

ForEach(subviews: content) { subview in
    Text("value = \(subview.containerValues.myCustomValue)") // shows "value = 1"
}


// MARK: - 250404 Sequence(first:
/// https://developer.apple.com/documentation/swift/sequence(first:next:)
// Walk the elements of a tree from a node up to the root
for node in sequence(first: leaf, next: { $0.parent }) {
  // node is leaf, then leaf.parent, then leaf.parent.parent, etc.
}

// Iterate over all powers of two (ignoring overflow)
for value in sequence(first: 1, next: { $0 * 2 }) {
  // value is 1, then 2, then 4, then 8, etc.
}

// MARK: - 250404 Matched Navigation Transition
/// matchedTransitionSource(id:in:configuration:)
/// https://developer.apple.com/documentation/swiftui/view/matchedtransitionsource(id:in:configuration:)
/// navigationTransition(_:)
/// https://developer.apple.com/documentation/swiftui/view/navigationtransition(_:)
/// Sets the navigation transition style for this view.

struct ContentView: View {
    @Namespace private var namespace
    var body: some View {
        NavigationStack {
            NavigationLink {
                DetailView()
                    .navigationTransition(.zoom(sourceID: "world", in: namespace))
            } label: {
                Image(systemName: "globe")
                    .matchedTransitionSource(id: "world", in: namespace)
            }
        }
    }
}

// MARK: - 250403 Model data
/// https://developer.apple.com/documentation/swiftui/model-data
/*
 The $ prefix asks a wrapped property for its projectedValue, which for state is a binding to the underlying storage. Similarly, you can get a binding from a binding using the $ prefix, allowing you to pass a binding through an arbitrary number of levels of view hierarchy.
 */


//MARK: - 250403 App Extensions
/// https://developer.apple.com/documentation/swiftui/app-extensions
/*
 Widgets provide quick access to relevant content from your app. Define a structure that conforms to the Widget protocol, and declare a view hierarchy for the widget. Configure the views inside the widget as you do other SwiftUI views, using view modifiers, including a few widget-specific modifiers.
 */

// MARK: - Creating a widget extension
/// https://developer.apple.com/documentation/widgetkit/creating-a-widget-extension

//
/// `StaticConfiguration` for the body property. Other types of widget configurations include:
/// `AppIntentConfiguration` that enables user customization, such as a weather widget that needs a zip or postal code for a city, or a package-tracking widget that needs a tracking number.
/// `ActivityConfiguration` to present live data, such as scores during a sporting event or a food delivery estimate.

/*
 To configure a static widget, provide the following information:

 kind
    A string that identifies the widget. This is an identifier you choose, and should be descriptive of what the widget represents.

 provider
    An object that conforms to TimelineProvider and produces a timeline that tells WidgetKit when to render the widget. A timeline is a sequence that contains a custom TimelineEntry type you define. The entries in this sequence identify the date when you want WidgetKit to update the widget’s content and includes properties your widget’s view needs to render in the custom type.

 content
    A closure that contains SwiftUI views. WidgetKit invokes this to render the widget’s content, passing a TimelineEntry parameter from the provider.
 */

/// Note the usage of the @main attribute on this widget.
/// This attribute indicates that the GameStatusWidget is the entry point for the widget extension, implying that the extension contains a single widget.
/// -> To support multiple widgets, see the `WidgetBundle`.
@main
struct GameStatusWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "com.mygame.game-status",
            provider: GameStatusProvider(),
        ) { entry in
            GameStatusView(entry.gameStatus)
        }
        .configurationDisplayName("Game Status")
        .description("Shows an overview of your game status")
        .supportedFamilies([.systemSmall])
    }
}

/// Important
///  >  For an app’s widget to appear in the widget gallery, a person must launch the app that contains the widget at least once after the app is installed.

// Provide timeline entries
struct GameStatusEntry: TimelineEntry {
    var date: Date
    var gameStatus: String
}

struct GameStatusProvider: TimelineProvider {
    func getTimeline(in context: Context, completion: @escaping (Timeline<GameStatusEntry>) -> Void) {
        // Create a timeline entry for "now."
        let date = Date()
        let entry = GameStatusEntry(
            date: date,
            gameStatus: gameStatusFromServer
        )


        // Create a date that's 15 minutes in the future.
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: date)!


        // Create the timeline with the entry and a reload policy with the date
        // for the next update.
        let timeline = Timeline(
            entries:[entry],
            policy: .after(nextUpdateDate)
        )


        // Call the completion to pass the timeline to WidgetKit.
        completion(timeline)
    }
}

// Generate a preview for the widget gallery
struct GameStatusProvider: TimelineProvider {
    var hasFetchedGameStatus: Bool
    var gameStatusFromServer: String
    
    
    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        let date = Date()
        let entry: GameStatusEntry
        
        
        if context.isPreview && !hasFetchedGameStatus {
            entry = GameStatusEntry(date: date, gameStatus: "—")
        } else {
            entry = GameStatusEntry(date: date, gameStatus: gameStatusFromServer)
        }
        completion(entry)
    }
}

// Display content in your widget
struct GameStatusView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var gameStatus: GameStatus
    var selectedCharacter: CharacterDetail


    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall: GameTurnSummary(gameStatus)
        default: GameDetailsNotAvailable()
        }
    }
}

// Hide sensitive content
struct BankAccountView: View {
    var body: some View {
        VStack {
            Text("Account #")
            
            Text(accountNumber)
                .font(.headline)
                /// Marks the view as containing sensitive, private user data.
                .privacySensitive() // Hide only the account number.
        }
    }
}

/*
 If a person chooses to hide privacy sensitive content, WidgetKit renders a placeholder or redactions you configure. To configure redactions, implement the redacted(reason:) callback, read out the privacy property, and provide custom placeholder views. You can also choose to render a view as unredacted with the `unredacted(`) view modifier.
 */

// MARK: - App Intent
/// https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities
/*
 Important

 An interaction with a button or toggle should do more than open the app. If you want to offer an interaction that opens the app, use Link and widgetURL(_:) as described in Linking to specific app scenes from your widget or Live Activity.
 */

// Understand the role of app intents
/*
 As a result of the timeline mechanism and of rendering in a separate process, the system can’t run your code or update data bindings at the time it renders your widget. This is where the App Intents framework comes into play. App intents allow you to expose actions of your app to the system and enable it to perform the actions when needed — for example, when a person interacts with a button or a toggle in a widget.
 */

// MARK: - Add an app intent that performs the action
/*
 Buttons and toggles you add to your widgets and Live Activities use functionality that you expose to the system by adopting the App Intents framework. Before you add a button or toggle, make the app functionality available to the system using an app intent:

  1, For a widget, create a new structure that adopts the `AppIntent` protocol and add it to your app target. For a Live Activity interactive, adopt the `LiveActivityIntent` protocol. If the interaction starts or pauses media playback, adopt the `AudioPlaybackIntent` protocol.

  2, Implement the protocol’s requirements.

  3, Define input parameters that your action needs using the `@Parameter` property wrapper and make sure their type conforms to the AppEntity protocol.
   --> ``Make sure input parameters have assigned values because, unlike app intents you define for system functionality like Siri, widgets don’t resolve parameters for app intents``.

  4, In the protocol’s required perform() function, add code for the action you want to make available to the widget.
 */

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct SuperCharge: AppIntent {
    
    static var title: LocalizedStringResource = "Emoji Ranger SuperCharger"
    static var description = IntentDescription("All heroes get instant 100% health.")
    
    func perform() async throws -> some IntentResult {
        EmojiRanger.superchargeHeros()
        return .result()
    }
}

// MARK: - Implement the perform function
/// Interactions with a toggle or button always guarantee a timeline reload.
struct EmojiRangerWidgetEntryView: View {
    var entry: SimpleEntry
    
    @Environment(\.widgetFamily) var family
    
    @ViewBuilder
    var body: some View {
        switch family {
            
            
        case .systemLarge:
            VStack {
                HStack(alignment: .top) {
                    AvatarView(entry.hero)
                        .foregroundStyle(.white)
                    Text(entry.hero.bio)
                        .foregroundStyle(.white)
                }
                .padding()
                if #available(iOS 17.0, *) {
                    HStack(alignment: .top) {
                        Button(intent: SuperCharge()) {
                            Image(systemName: "bolt.fill")
                        }
                    }
                    .tint(.white)
                    .padding()
                }
            }
            .containerBackground(for: .widget) {
                Color.gameBackgroundColor
            }
            .widgetURL(entry.hero.url)
            
            // Code for other widget sizes.
        }
    }
}

/// Mark the receiver as their content might be invalidated.
nonisolated
func invalidatableContent(_ invalidatable: Bool = true) -> some View

struct TodoItemView: View {
    var todo: Todo


    var body: some View {
        Toggle(isOn: todo.complete, intent: ToggleTodoIntent(todo.id)) {
            Text(todo.body)
        }
        .toggleStyle(TodoToggleStyle())
    }
}

// SwiftUI Views For Widgets
/// https://developer.apple.com/documentation/widgetkit/swiftui-views

// MARK: - Preview Widget
#Preview(as: .systemMedium, widget: {
    EmojiRangerWidget()
}, timeline: {
    SimpleEntry(date: Date(), relevance: nil, hero: .spouty)
})

// MARK: - Widget Bundle
@main
struct GameWidgets: WidgetBundle {
   var body: some Widget {
       GameStatusWidget()
       CharacterDetailWidget()
   }
}

// MARK: - Keeping a widget up to date
/// https://developer.apple.com/documentation/widgetkit/keeping-a-widget-up-to-date
/*
 A widget’s budget applies to a 24-hour period.
 WidgetKit tunes the 24-hour window to the user’s daily usage pattern,
 which means the daily budget doesn’t necessarily reset at exactly midnight.
 For a widget the user frequently views,
  -- > a daily budget typically includes from 40 to 70 refreshes.
 This rate roughly translates to widget reloads every 15 to 60 minutes,
 but it’s common for these intervals to vary due to the many factors involved.
 */

/// Your timeline provider should create timeline entries that are at least about 5 minutes apart. WidgetKit may coalesce reloads across multiple widgets, affecting the exact time a widget is reloaded.

// Generate a timeline for predictable events
// Create the timeline with the entry and a reload policy with the date
// for the next update.
let timeline = Timeline(
    entries:[entry],
    policy: .after(nextUpdateDate)
)

// Inform WidgetKit when a timeline changes
WidgetCenter.shared.reloadTimelines(ofKind: "com.mygame.character-detail")

/// In the following code, the app calls getCurrentConfigurations(_:) to retrieve the list of user-configured widgets. It then iterates through the resulting WidgetInfo objects to find one with an intent configured with the character that received the healing potion. If it finds one, the app calls reloadTimelines(ofKind:) for that widget’s kind.
WidgetCenter.shared.getCurrentConfigurations { result in
    guard case .success(let widgets) = result else { return }


    // Iterate over the WidgetInfo elements to find one that matches
    // the character from the push notification.
    if let widget = widgets.first(
        where: { widget in
            let intent = widget.configuration as? SelectCharacterIntent
            return intent?.character == characterThatReceivedHealingPotion
        }
    ) {
        WidgetCenter.shared.reloadTimelines(ofKind: widget.kind)
    }
}

WidgetCenter.shared.reloadAllTimelines()

// MARK: - Display dynamic dates
/// https://developer.apple.com/documentation/widgetkit/displaying-dynamic-dates
let components = DateComponents(minute: 11, second: 14)
let futureDate = Calendar.current.date(byAdding: components, to: Date())!
Text(futureDate, style: .relative)
// Displays:
// 11 min, 14 sec
Text(futureDate, style: .offset)
// Displays:
// -11 minutes


let components = DateComponents(minute: 15)
let futureDate = Calendar.current.date(byAdding: components, to: Date())!
Text(futureDate, style: .timer)
// Displays:
// 15:00

// Absolute Date or Time
let components = DateComponents(year: 2020, month: 4, day: 1, hour: 9, minute: 41)
let aprilFirstDate = Calendar.current(components)!
Text(aprilFirstDate, style: .date)
Text("Date: \(aprilFirstDate, style: .date)")
Text("Time: \(aprilFirstDate, style: .time)")
// Displays:
// April 1, 2020
// Date: April 1, 2020
// Time: 9:41AM

/// display a time interval between two dates:
let startComponents = DateComponents(hour: 9, minute: 30)
let startDate = Calendar.current.date(from: startComponents)!
let endComponents = DateComponents(hour: 14, minute: 45)
let endDate = Calendar.current.date(from: endComponents)!
Text(startDate ... endDate)
Text("The meeting will take place: \(startDate ... endDate)")
// Displays:
// 9:30AM-2:45PM
// The meeting will take place: 9:30AM-2:45PM

// MARK: - Making a configurable widget
/// https://developer.apple.com/documentation/widgetkit/making-a-configurable-widget

/*
 To add configurable properties to your widget:
 
    -- Add custom app intent types that conform to WidgetConfigurationIntent to define the configurable properties to your Xcode project.
 
    -- Specify an AppIntentTimelineProvider as your widget’s timeline provider to incorporate the person’s choices into your timeline entries.
 
    -- Add code to your custom app intent types to provide the data if their properties rely on dynamic data.
 */

// MARK: - Add a custom app intent to your project
struct SelectCharacterIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Character"
    static var description = IntentDescription("Selects the character to display information for.")
    
    /// The order of the parameters in the intent determines the order in which they appear when a person edits your widget.
    /// To add parameters to the intent, add one or more @Parameter property wrappers.
    /// WidgetKit uses the parameter type information to automatically create the user interface for editing the widget.
    /// For example, if the type is String, the person enters a string value.
    /// If the type is an Int, they use a number pad.
    /// For a parameter that is a predefined, static, list of values, define a custom type that conforms to AppEnum.
    @Parameter(title: "Character")
    var character: CharacterDetail
    
    init(character: CharacterDetail) {
        self.character = character
    }
    
    init() {}
}

struct CharacterDetail: AppEntity {
    let id: String
    let avatar: String
    let healthLevel: Double
    let heroType: String
    let isAvailable = true
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Character"
    static var defaultQuery = CharacterQuery()
            
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(avatar) \(id)")
    }
    
    static let allCharacters: [CharacterDetail] = [
        CharacterDetail(id: "Power Panda", avatar: "🐼", healthLevel: 0.14, heroType: "Forest Dweller"),
        CharacterDetail(id: "Unipony", avatar: "🦄", healthLevel: 0.67, heroType: "Free Rangers"),
        CharacterDetail(id: "Spouty", avatar: "🐳", healthLevel: 0.83, heroType: "Deep Sea Goer")
    ]
}

/// If your widget includes nonoptional parameters, you must supply a default value. For types such as String, Int, or enumerations that use AppEnum, one option is to supply a default value as follows:
@Parameter(title: "Title", default: "A Default Title")
var title: String

// -> A second option is to use a query type that implements defaultResult(), as shown in the next section.
struct CharacterQuery: EntityQuery {
    func entities(for identifiers: [CharacterDetail.ID]) async throws -> [CharacterDetail] {
        CharacterDetail.allCharacters.filter { identifiers.contains($0.id) }
    }
    
    func suggestedEntities() async throws -> [CharacterDetail] {
        CharacterDetail.allCharacters.filter { $0.isAvailable }
    }
    
    func defaultResult() async -> CharacterDetail? {
        try? await suggestedEntities().first
    }
}

// MARK: - Handle customized values in your widget
struct CharacterDetailWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectCharacterIntent.self,
            provider: CharacterDetailProvider()) { entry in
            CharacterDetailView(entry: entry)
        }
        .configurationDisplayName("Character Details")
        .description("Displays a character's health and other details")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct CharacterDetailProvider: AppIntentTimelineProvider {
    func timeline(for configuration: SelectCharacterIntent, in context: Context) async -> Timeline<CharacterDetailEntry> {
        // Create the timeline and return it. The .never reload policy indicates
        // that the containing app will use WidgetCenter methods to reload the
        // widget's timeline when the details change.
        let entry = CharacterDetailEntry(date: Date(), detail: configuration.character)
        let timeline = Timeline(entries: [entry], policy: .never)
        return timeline
    }
}

// MARK: - 250403 Control Widget
/// https://developer.apple.com/documentation/widgetkit/creating-controls-to-perform-actions-across-the-system
/*
 Controls are defined using templates in order to ensure that they control will work at all sizes and in all system spaces in which they might be displayed. These templates define images (specifically, symbol images) and text using simple SwiftUI views like Label, Text, and Image; and tint colors using the tint(_:) modifier.
 */

/*
 Controls provide their values to the system using a ControlValueProvider or an AppIntentControlValueProvider. Providers require two functions: previewValue and currentValue(). previewValue prepares a canned synchronous value to show people when the control displays in the controls gallery. The controls gallery displays controls using their preview value and in their inactive state. The system fetches the currentValue() when the control renders. The system fetches this value asynchronously, and gives you the opportunity to fetch the value from a shared data source or a server. Use a custom intent with AppIntentControlValueProvider to provide options for a configurable control.
 */

/// Use `AppIntent` or `OpenIntent` for control buttons and `SetValueIntent` for control toggles.

// MARK: - Add a control toggle to your app
struct TimerToggle: ControlWidget {
    static let kind: String = "com.example.MyApp.TimerToggle"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: Self.kind,
            provider: Provider()
        ) { value in
            ControlWidgetToggle(
                "Productivity Timer",
                isOn: value,
                action: ToggleTimerIntent(),
                valueLabel: { isOn in
                    Label(isOn ? "Running" : "Stopped", systemImage: "timer")
                }
            )
        }
        .displayName("Productivity Timer")
        .description("Start and stop a productivity timer.")
    }
}

extension TimerToggle {
    struct Provider: ControlValueProvider {
        var previewValue: Bool {
            false
        }

        func currentValue() async throws -> Bool {
            let isRunning = true // Check if the timer is running
            return isRunning
        }
    }
}

struct ToggleTimerIntent: SetValueIntent {
    static var title: LocalizedStringResource = "Productivity Timer"

    @Parameter(title: "Timer is running")
    var value: Bool

    func perform() async throws -> some IntentResult {
        // Start / stop the timer based on `value`.
        return .result()
    }
}

// MARK: - Create a button control
struct PerformActionButton: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: "com.example.myApp.performActionButton"
        ) {
            ControlWidgetButton(action: PerformAction()) {
                Label("Perform Action", systemImage: "checkmark.circle")
            }
        }
        .displayName("Perform Action")
        .description("An example control that performs an action.")
    }
}

struct PerformAction: AppIntent {
    static let title: LocalizedStringResource = "Perform action"

    func perform() async throws -> some IntentResult {
        // Code that performs the action...
        return .result()
    }
}

// MARK: - Open your app with a control
import AppIntents

struct LaunchAppIntent: OpenIntent {
    static var title: LocalizedStringResource = "Launch App"
    @Parameter(title: "Target")
    var target: LaunchAppEnum
}

enum LaunchAppEnum: String, AppEnum {
    case timer
    case history

    static var typeDisplayRepresentation = TypeDisplayRepresentation("Productivity Timer's app screens")
    static var caseDisplayRepresentations = [
        LaunchAppEnum.timer : DisplayRepresentation("Timer"),
        LaunchAppEnum.history : DisplayRepresentation("History")
    ]
}

// MARK: - App Intent driven development in Swift and SwiftUI
/// https://www.avanderlee.com/swift/app-intent-driven-development/
struct SelectFavoritesGroupIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Group"
    static var description = IntentDescription("Selects the group to display stocks for.")

    @Parameter(title: "Group")
    var group: WidgetFavoritesGroup?

    init(group: WidgetFavoritesGroup) {
        self.group = group
    }

    init() { }

    func perform() async throws -> some IntentResult {
        return .result()
    }
}

extension WidgetFavoritesGroup: AppEntity {
    static var defaultQuery = FavoriteGroupsQuery()
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "WidgetFavoritesGroup"
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)")
    }
}

struct FavoriteGroupsQuery: EntityQuery {
    func entities(for identifiers: [WidgetFavoritesGroup.ID]) async throws -> [WidgetFavoritesGroup] {
        /// Filter all available groups using the given identifiers
    }

    func suggestedEntities() async throws -> [WidgetFavoritesGroup] {
        /// Return a list of suggested favorite groups to use
    }

    func defaultResult() async -> WidgetFavoritesGroup? {
        /// Return default selected group
    }
}

AppIntentConfiguration(
    kind: kind,
    intent: SelectFavoritesGroupIntent.self, // <- This is our intent
    provider: DefaultTimelineProvider()) { entry in
        StockAnalyzerWatchlistWidgetsEntryView(entry: entry)
    }

// in app
final class WatchlistGroupsManagementViewModel: ObservableObject {

    @Published var watchlistGroups: [WidgetFavoritesGroup] = []

    func loadGroups() async throws {
        watchlistGroups = try await WidgetFavoritesGroup.defaultQuery.suggestedEntities()
    }
}

// MARK: - 250403 DeepLink Handling
/// https://www.avanderlee.com/swiftui/deeplink-url-handling/
struct ContentView: View {
    /// We store the opened recipe name as a state property to redraw our view accordingly.
    @State private var openedRecipeName: String?

    var body: some View {
        VStack {
            Text("Hello, recipe!")

            if let openedRecipeName {
                Text("Opened recipe: \(openedRecipeName)")
            }
        }
        .padding()
        /// Responds to any URLs opened with our app. In this case, the URLs
        /// defined inside the URL Types section.
        .onOpenURL { incomingURL in
            print("App was opened via URL: \(incomingURL)")
            handleIncomingURL(incomingURL)
        }
    }

    /// Handles the incoming URL and performs validations before acknowledging.
    private func handleIncomingURL(_ url: URL) {
        guard url.scheme == "recipeapp" else {
            return
        }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("Invalid URL")
            return
        }

        guard let action = components.host, action == "open-recipe" else {
            print("Unknown URL, we can't handle this one!")
            return
        }

        guard let recipeName = components.queryItems?.first(where: { $0.name == "name" })?.value else {
            print("Recipe name not found")
            return
        }

        openedRecipeName = recipeName
    }
}

// Handling URLs inside an AppDelegate or SceneDelegate
// AppDelegate
func application(_ application: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    /// Handle the URL property accordingly
}

// SceneDelegate
func scene(_ scene: UIScene,
           willConnectTo session: UISceneSession,
           options connectionOptions: UIScene.ConnectionOptions) {
    guard let url = connectionOptions.urlContexts.first?.url {
        return
    }

    /// Handle the URL property accordingly
}

Button("Open Recipe") {
    UIApplication
        .shared
        .open(URL(string: "recipeapp://open-recipe?name=Opened%20from%20inside%20the%20app")!)
}

// MARK: - 250403 Universal Links
/// https://www.avanderlee.com/swiftui/universal-links-ios/
/*
 Universal Links allow you to link to content inside your app when a user opens a particular URL. Webpages will open in the app browser by default, but you can configure specific paths to open in your app if the user has it installed.
 */

Deeplink: // recipeapp://open-recipe?name=recipename
Universal Links: // www.recipes.com/recipename

/// associated domain file to your website.
/// an example of such a file for my Stock Analyzer app: https://stock-analyzer.app/.well-known/apple-app-site-association.
{
    "applinks": {
        "details": [{
            "appIDs": ["4QMDKC8VLJ.com.swiftlee.StockAnalyzer"],
            "components": [{
                "/": "/stock/*",
                "comment": "Matches any URL whose path starts with /stock/"
            }]
        }]
    },
    "appclips": {
        "apps": [
            "4QMDKC8VLJ.com.swiftlee.StockAnalyzer.Clip"
        ]
    }
}

/// Apple provides a few examples:
{
  "applinks": {
      "details": [
           {
             "appIDs": [ "ABCDE12345.com.example.app", "ABCDE12345.com.example.app2" ],
             "components": [
               {
                  "#": "no_universal_links",
                  "exclude": true,
                  "comment": "Matches any URL with a fragment that equals no_universal_links and instructs the system not to open it as a universal link."
               },
               {
                  "/": "/buy/*",
                  "comment": "Matches any URL with a path that starts with /buy/."
               },
               {
                  "/": "/help/website/*",
                  "exclude": true,
                  "comment": "Matches any URL with a path that starts with /help/website/ and instructs the system not to open it as a universal link."
               },
               {
                  "/": "/help/*",
                  "?": { "articleNumber": "????" },
                  "comment": "Matches any URL with a path that starts with /help/ and that has a query item with name 'articleNumber' and a value of exactly four characters."
               }
             ]
           }
       ]
   }
}


//MARK: - 250324 Search
// Enable people to search for text or other content within your app
/// https://developer.apple.com/documentation/swiftui/search
/*
 To enhance the search interaction, you can also:
    -> Offer suggestions during search, for both text and tokens.
    -> Implement search scopes that help people to narrow the search space.
    -> Detect when people activate the search field, and programmatically dismiss the search field using environment values.
 */

// MARK: - Adding a search interface to your app
/// https://developer.apple.com/documentation/swiftui/adding-a-search-interface-to-your-app
/*
 The searchable modifier that creates the field takes a Binding to a string that represents the search field’s text. You provide the storage for the string
 — and optionally for an array of discrete search tokens —
 that you use to conduct the search.
 */

// Place the search field automatically
struct ContentView: View {
    @State private var departmentId: Department.ID?
    @State private var productId: Product.ID?
    @State private var searchText: String = ""


    var body: some View {
        NavigationSplitView {
            DepartmentList(departmentId: $departmentId)
        } content: {
            ProductList(departmentId: departmentId, productId: $productId)
        } detail: {
            ProductDetails(productId: productId)
        }
        .searchable(text: $searchText) // Adds a search field.
    }
}

// Control the placement structurally
NavigationSplitView {
    DepartmentList(departmentId: $departmentId)
        .searchable(text: $searchText)
} content: {
    ProductList(departmentId: departmentId, productId: $productId)
} detail: {
    ProductDetails(productId: productId)
}

// Control the placement programmatically
NavigationSplitView {
    DepartmentList(departmentId: $departmentId)
} content: {
    ProductList(departmentId: departmentId, productId: $productId)
} detail: {
    ProductDetails(productId: productId)
}
.searchable(text: $searchText, placement: .sidebar)

// Set a prompt for the search field
DepartmentList(departmentId: $departmentId)
    .searchable(text: $searchText, prompt: "Departments and products")

// MARK: - Performing a search operation
/// https://developer.apple.com/documentation/swiftui/performing-a-search-operation

//MARK: - Provide storage for a Token
/*
 You create tokens by defining a group of values that conform to the Identifiable protocol, then instantiate the collection of values. For example you can create an enumeration of fruit tokens:
 */
enum FruitToken: String, Identifiable, Hashable, CaseIterable {
    case apple
    case pear
    case banana
    
    var id: Self { self }
}

/// Then add a new published property to your model to store a collection of tokens:
@Published var tokens: [FruitToken] = []

ProductList(departmentId: departmentId, productId: $productId)
    .searchable(text: $model.searchText, tokens: $model.tokens) { token in
        switch token {
        case .apple: Text("Apple")
        case .pear: Text("Pear")
        case .banana: Text("Banana")
        }
    }

//MARK: - Support tokens that have a mutable component
struct FruitToken: String, Identifiable, Hashable, CaseIterable {
    enum Kind {
        case apple
        case pear
        case banana
        var id: Self { self }
    }


    enum Hydration: String, Identifiable, Hashable, CaseIterable {
        case hydrated
        case dehydrated
    }


    var kind: Kind
    var hydration: Hydration = .hydrated
}

ProductList(departmentId: departmentId, productId: $productId)
    .searchable(text: $model.searchText, tokens: $model.tokens) { $token in
        Picker(selection: $token.hydration) {
            ForEach(FruitToken.Hydration.allCases) { hydration in
                switch hydration {
                case .hydrated: Text("Hydrated")
                case .dehydrated: Text("Dehydrated")
                }
            }
        } label: {
            switch token.kind {
            case .apple: Text("Apple")
            case .pear: Text("Pear")
            case .banana: Text("Banana")
            }
        }
    }

// Conduct the search
/*
 you can create a method that returns only the items in an array of products with names that match the search text or one of the tokens currently in the search field:
 */

func filteredProducts(
    products: [Product],
    searchText: String,
    tokens: [FruitToken]
) -> [Product] {
    guard !searchText.isEmpty || !tokens.isEmpty else { return products }
    return products.filter { product in
        product.name.lowercased().contains(searchText.lowercased()) ||
        tokens.map({ $0.rawValue }).contains(product.name.lowercased())
    }
}

//MARK: - Suggesting Search Terms
/// https://developer.apple.com/documentation/swiftui/suggesting-search-terms

ProductList(departmentId: departmentId, productId: $productId)
    .searchable(text: $model.searchText)
    .searchSuggestions {
        /*
         If you omit the search completion modifier for a particular suggestion view, SwiftUI displays the view, but the view doesn’t react to taps or clicks. However, you can group the views with Section containers that have headers, enabling you to distinguish different kinds of suggestions, like recent searches and common search terms.
         */
        Text("🍎 Apple").searchCompletion("apple")
        Text("🍐 Pear").searchCompletion("pear")
        Text("🍌 Banana").searchCompletion("banana")
    }

//MARK: - Suggest tokens
ProductList(departmentId: departmentId, productId: $productId)
    .searchable(text: $model.searchText, tokens: $model.tokens) { token in
        switch token {
        case .apple: Text("Apple")
        case .pear: Text("Pear")
        case .banana: Text("Banana")
        }
    }
    .searchSuggestions {
        ///You can use any type that conforms to the Identifiable protocol as a token
        Text("Apple").searchCompletion(FruitToken.apple)
        Text("Pear").searchCompletion(FruitToken.pear)
        Text("Banana").searchCompletion(FruitToken.banana)
    }

//MARK: - Simplify token suggestions

@Published var suggestions: [FruitToken] = FruitToken.allCases
/*
 Then you can provide this array to one of the searchable modifiers that takes a suggestedTokens input parameter, like searchable(text:tokens:suggestedTokens:placement:prompt:token:). SwiftUI uses this to generate the suggestions automatically:
 */
ProductList(departmentId: departmentId, productId: $productId)
    .searchable(
        text: $model.searchText,
        tokens: $model.tokens,
        suggestedTokens: $model.suggestions
    ) { token in
        switch token {
        case .apple: Text("Apple")
        case .pear: Text("Pear")
        case .banana: Text("Banana")
        }
    }

//MARK: - Update suggestions dynamically
ProductList(departmentId: departmentId, productId: $productId)
    .searchable(text: $model.searchText)
    .searchSuggestions {
        ForEach(model.suggestedSearches) { suggestion in
            Label(suggestion.title,  image: suggestion.image)
                .searchCompletion(suggestion.text)
        }
        /// optional to not display the suggestions
        // .searchSuggestions(.hidden, for: .content)
    }

//MARK: - Scoping a search operation
enum ProductScope {
    case fruit
    case vegetable
}

@Published var scope: ProductScope = .fruit

ProductList(departmentId: departmentId, productId: $productId)
    .searchable(text: $model.searchText, tokens: $model.tokens) { token in
        switch token {
        case .apple: Text("Apple")
        case .pear: Text("Pear")
        case .banana: Text("Banana")
        }
    }
    .searchScopes($model.scope) {
        Text("Fruit").tag(ProductScope.fruit)
        Text("Vegetable").tag(ProductScope.vegetable)
    }

//MARK: - Managing search interface activation
/// https://developer.apple.com/documentation/swiftui/managing-search-interface-activation

//MARK: - Control activation through a binding
struct SheetView: View {
    @State private var isPresented = true
    @State private var text = ""
  
    var body: some View {
        NavigationStack {
            SheetContent()
                .searchable(text: $text, isPresented: $isPresented)
        }
    }
}

//MARK: - Detect search activation
struct SearchingExample: View {
    @State private var searchText = ""


    var body: some View {
        NavigationStack {
            SearchedView()
                .searchable(text: $searchText)
        }
    }
}


struct SearchedView: View {
    @Environment(\.isSearching) private var isSearching


    var body: some View {
        Text(isSearching ? "Searching" : "Not searching")
    }
}

//MARK: - Dismiss the search interface
struct ContentView: View {
    @State private var searchText = ""


    var body: some View {
        NavigationStack {
            SearchedView(searchText: searchText)
                .searchable(text: $searchText)
        }
    }
}


private struct SearchedView: View {
    var searchText: String


    let items = ["a", "b", "c"]
    var filteredItems: [String] { items.filter { $0 == searchText.lowercased() } }


    @State private var isPresented = false
    @Environment(\.dismissSearch) private var dismissSearch


    var body: some View {
        if let item = filteredItems.first {
            Button("Details about \(item)") {
                isPresented = true
            }
            .sheet(isPresented: $isPresented) {
                NavigationStack {
                    DetailView(item: item, dismissSearch: dismissSearch)
                }
            }
        }
    }
}

private struct DetailView: View {
    var item: String
    var dismissSearch: DismissSearchAction


    @Environment(\.dismiss) private var dismiss


    var body: some View {
        Text("Information about \(item).")
            .toolbar {
                Button("Add") {
                    // Store the item here...


                    dismiss()
                    dismissSearch()
                }
            }
    }
}

//MARK: - React to search submission
/// https://developer.apple.com/documentation/swiftui/view/onsubmit(of:_:)
SearchedView()
    .searchable(text: $searchText)
    .onSubmit(of: .search) {
        submitCurrentSearchQuery()
    }

/*
 You can use the submitScope(_:) modifier to stop a submit trigger from a control from propagating higher up in the view hierarchy to higher View.onSubmit(of:_:) modifiers.
 */

Form {
    TextField("Username", text: $viewModel.userName)
    SecureField("Password", text: $viewModel.password)


    TextField("Tags", text: $viewModel.tags)
        .submitScope()
}
.onSubmit {
    guard viewModel.validate() else { return }
    viewModel.login()
}

//MARK: - searchPresentationToolbarBehavior
/// https://developer.apple.com/documentation/swiftui/view/searchpresentationtoolbarbehavior(_:)
// By default on iOS, a toolbar may hide parts of its content when presenting search to focus on searching. You can override this behavior by providing a value of avoidHidingContent to this modifer.
@State private var searchText = ""


List {
    // ... content
}
.searchable(text: $searchText)
.searchPresentationToolbarBehavior(.avoidHidingContent)

//MARK: - findNavigator(isPresented:)
/// https://developer.apple.com/documentation/swiftui/view/findnavigator(ispresented:)
/*
 Add this modifier to a TextEditor, or to a view hierarchy that contains at least one text editor, to control the presentation of the find and replace interface. When you set the isPresented binding to true, the system shows the interface, and when you set it to false, the system hides the interface. The following example shows and hides the interface based on the state of a toolbar button:
 */
TextEditor(text: $text)
    .findNavigator(isPresented: $isPresented)
    .toolbar {
        Toggle(isOn: $isPresented) {
            Label("Find", systemImage: "magnifyingglass")
        }
    }

// MARK: - LX Drawing Group, Compositing Group, and Geometry Group
/// https://www.reddit.com/r/SwiftUI/comments/1eswbi2/when_should_i_use_drawinggroup_geometrygroup_and/?rdt=63891
/*
 Apple’s documentation does an ok job of explaining if you read carefully (maybe two or three times). They also have some examples

 Drawing Group: renders the view as an image offscreen first before showing https://developer.apple.com/documentation/swiftui/view/drawinggroup(opaque:colormode:)

 “Don’t move around while animating”

 Geometry Group: Isolates the geometry (e.g. position and size) of the view from its parent view https://developer.apple.com/documentation/swiftui/view/geometrygroup()

 “Lay out together”
 ///https://fatbobman.com/en/posts/mastring-geometrygroup/#:~:text=understandable%20documentation%20explanation%3A-,geometryGroup(),animation%20to%20their%20frame%20rectangle.

 Composition Group: makes compositing effects in this view’s ancestor views, such as opacity and the blend mode, take effect before this view is rendered. https://developer.apple.com/documentation/swiftui/view/compositinggroup()

 “Parent needs to take care of their sh*t before the kid takes care of their selfs”
 */

// MARK: - Drawing Group
/// https://developer.apple.com/documentation/swiftui/view/drawinggroup(opaque:colormode:)
// Composites this view’s contents into an offscreen image before final display.
nonisolated
func drawingGroup(
    opaque: Bool = false,
    colorMode: ColorRenderingMode = .nonLinear
) -> some View

/// In the example below, the contents of the view are composited to a single bitmap; the bitmap is then displayed in place of the view:
VStack {
    ZStack {
        Text("DrawingGroup")
            .foregroundColor(.black)
            .padding(20)
            .background(Color.red)
        Text("DrawingGroup")
            .blur(radius: 2)
    }
    .font(.largeTitle)
    .compositingGroup()
    .opacity(1.0)
}
 .background(Color.white)
 .drawingGroup()

// Warning: Views backed by native platform views may not render into the image.
// -> Instead, they log a warning and display a placeholder image to highlight the error.

// MARK: - Geometry Group
/// https://developer.apple.com/documentation/swiftui/view/geometrygroup()
/// Returns: a new view whose geometry is isolated from that of its parent view.
nonisolated
func geometryGroup() -> some View

/*
 The example below shows one use of this function: ensuring that the member views of each row in the stack apply (and animate as) a single geometric transform from their ancestor view, rather than letting the effects of the ancestor views be applied separately to each leaf view. If the members of ItemView may be added and removed at different times the group ensures that they stay locked together as animations are applied.
 */
VStack {
    ForEach(items) { item in
        ItemView(item: item)
            .geometryGroup()
    }
}

// MARK: - Compositing Group
/*
 In the example below the compositingGroup() modifier separates the application of effects into stages. It applies the opacity(_:) effect to the VStack before the blur(radius:) effect is applied to the views inside the enclosed ZStack.
 -> This limits the scope of the opacity change to the outermost view.
 */
VStack {
    ZStack {
        Text("CompositingGroup")
            .foregroundColor(.black)
            .padding(20)
            .background(Color.red)
        Text("CompositingGroup")
            .blur(radius: 2)
    }
    .font(.largeTitle)
    .compositingGroup()
    .opacity(0.9)
}



// MARK: - 250323 Toolbars
// Provide immediate access to frequently used commands and controls.
/// https://developer.apple.com/documentation/swiftui/toolbars

//MARK: - toolbar(removing:)
/// https://developer.apple.com/documentation/swiftui/view/toolbar(removing:)
nonisolated
func toolbar(removing defaultItemKind: ToolbarDefaultItemKind?) -> some View

NavigationSplitView {
    SidebarView()
        .toolbar(removing: .sidebarToggle)
} detail: {
    DetailView()
}

//MARK: - toolbar(content:)
/// https://developer.apple.com/documentation/swiftui/view/toolbar(content:)
nonisolated
func toolbar<Content>(@ToolbarContentBuilder content: () -> Content) -> some View where Content : ToolbarContent

/*
 The toolbar modifier expects a collection of toolbar items which you can provide either by supplying a collection of views with each view wrapped in a ToolbarItem, or by providing a collection of views as a ToolbarItemGroup. The example below uses a collection of ToolbarItem views to create a macOS toolbar that supports text editing features:
 */
struct StructToolbarItemGroupView: View {
    @State private var text = ""
    @State private var bold = false
    @State private var italic = false
    @State private var fontSize = 12.0

    var displayFont: Font {
        let font = Font.system(size: CGFloat(fontSize),
                               weight: bold == true ? .bold : .regular)
        return italic == true ? font.italic() : font
    }

    var body: some View {
        TextEditor(text: $text)
            .font(displayFont)
            .toolbar {
                ToolbarItemGroup {
                    Slider(
                        value: $fontSize,
                        in: 8...120,
                        minimumValueLabel:
                            Text("A").font(.system(size: 8)),
                        maximumValueLabel:
                            Text("A").font(.system(size: 16))
                    ) {
                        Text("Font Size (\(Int(fontSize)))")
                    }
                    .frame(width: 150)
                    Toggle(isOn: $bold) {
                        Image(systemName: "bold")
                    }
                    Toggle(isOn: $italic) {
                        Image(systemName: "italic")
                    }
                }
            }
            .navigationTitle("My Note")
    }
}

//MARK: - static let keyboard: ToolbarItemPlacement
/*
 On iOS, keyboard items are above the software keyboard when present, or at the bottom of the screen when a hardware keyboard is attached.

 On macOS, keyboard items will be placed inside the Touch Bar.

 A FocusedValue can be used to adjust the content of the keyboard bar based on the currently focused view. In the example below, the keyboard bar gains additional buttons only when the appropriate TextField is focused
 */
enum Field {
    case suit
    case rank
}

struct KeyboardBarDemo : View {
    @FocusedValue(\.field) var field: Field?
    var body: some View {
        HStack {
            TextField("Suit", text: $suitText)
                .focusedValue(\.field, .suit)
            TextField("Rank", text: $rankText)
                .focusedValue(\.field, .rank)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                if field == .suit {
                    Button("♣️", action: {})
                    Button("♥️", action: {})
                    Button("♠️", action: {})
                    Button("♦️", action: {})
                }
                DoneButton()
            }
        }
    }
}

//MARK: - Difference Between FocusedValue and FocusedState
/*
In SwiftUI, `@FocusState` and `@FocusedValue` are property wrappers that facilitate focus management within your app's user interface, but they serve different purposes and use cases.

**`@FocusState`**: This property wrapper allows you to control and monitor which view is currently focused. It's particularly useful for managing the focus of input fields, such as `TextField` or `SecureField`. By associating a `@FocusState` variable with a specific view, you can programmatically set or observe its focus state. For example:


```swift
struct ContentView: View {
    @FocusState private var isUsernameFocused: Bool
    @State private var username: String = ""

    var body: some View {
        TextField("Username", text: $username)
            .focused($isUsernameFocused)
            .onChange(of: isUsernameFocused) { focused in
                if focused {
                    print("Username field is focused")
                }
            }
    }
}
```

In this example, the `isUsernameFocused` state variable tracks whether the `TextField` is focused, allowing you to respond to focus changes accordingly.

**`@FocusedValue`**: This property wrapper enables you to access values from the currently focused view or one of its ancestors. It's useful when you need to retrieve specific data associated with the focused view, such as the content of a text field. To implement `@FocusedValue`, you define a custom key conforming to the `FocusedValueKey` protocol and extend `FocusedValues` to include your key. Here's how you can set it up:


```swift
struct CommentFocusedKey: FocusedValueKey {
    typealias Value = String
}

extension FocusedValues {
    var commentFocusedValue: String? {
        get { self[CommentFocusedKey.self] }
        set { self[CommentFocusedKey.self] = newValue }
    }
}
```

With this setup, you can use the `focusedValue` modifier to assign a value to the focused view


```swift
TextField("Any comment?", text: $comment)
    .focused($isCommentFieldFocused)
    .focusedValue(\.commentFocusedValue, comment)
```

Then, in another part of your view hierarchy, you can access this focused value:

```swift
struct CommentPreview: View {
    @FocusedValue(\.commentFocusedValue) var comment

    var body: some View {
        Text(comment ?? "Not focused")
    }
}
```

This allows the `CommentPreview` view to display the current content of the focused comment field.

In summary, use `@FocusState` when you need to manage or observe which view is currently focused, and use `@FocusedValue` when you need to access specific data associated with the focused view.
*/


// MARK: - 250323 Modal presentations
/// https://developer.apple.com/documentation/swiftui/modal-presentations

// MARK: - sheet(item:onDismiss:content:)
/// https://developer.apple.com/documentation/swiftui/view/sheet(item:ondismiss:content:)
struct ShowPartDetail: View {
    @State private var sheetDetail: InventoryItem?

    var body: some View {
        Button("Show Part Details") {
            sheetDetail = InventoryItem(
                id: "0123456789",
                partNumber: "Z-1234A",
                quantity: 100,
                name: "Widget")
        }
        .sheet(item: $sheetDetail,
               onDismiss: didDismiss) { detail in
            VStack(alignment: .leading, spacing: 20) {
                Text("Part Number: \(detail.partNumber)")
                Text("Name: \(detail.name)")
                Text("Quantity On-Hand: \(detail.quantity)")
            }
            .onTapGesture {
                sheetDetail = nil
            }
        }
    }
    func didDismiss() {
        // Handle the dismissing action.
    }
}

struct InventoryItem: Identifiable {
    var id: String
    let partNumber: String
    let quantity: Int
    let name: String
}

// MARK: - fullScreenCover(item:onDismiss:content:)
/// https://developer.apple.com/documentation/swiftui/view/fullscreencover(item:ondismiss:content:)
struct FullScreenCoverItemOnDismissContent: View {
    @State private var coverData: CoverData?

    var body: some View {
        Button("Present Full-Screen Cover With Data") {
            coverData = CoverData(body: "Custom Data")
        }
        .fullScreenCover(item: $coverData,
                         onDismiss: didDismiss) { details in
            VStack(spacing: 20) {
                Text("\(details.body)")
            }
            .onTapGesture {
                coverData = nil
            }
        }
    }

    func didDismiss() {
        // Handle the dismissing action.
    }
}

struct CoverData: Identifiable {
    var id: String {
        return body
    }
    let body: String
}

// MARK: - alert(_:isPresented:presenting:actions:message:)
/// https://developer.apple.com/documentation/swiftui/view/alert(_:ispresented:presenting:actions:message:)
struct SaveDetails: Identifiable {
    let name: String
    let error: String
    let id = UUID()
}

struct SaveButton: View {
    @State private var didError = false
    @State private var details: SaveDetails?
    let alertTitle: String = "Save failed."

    var body: some View {
        Button("Save") {
            details = model.save(didError: $didError)
        }
        .alert(
            Text(alertTitle),
            isPresented: $didError,
            presenting: details
        ) { details in
            Button(role: .destructive) {
                // Handle the deletion.
            } label: {
                Text("Delete \(details.name)")
            }
            Button("Retry") {
                // Handle the retry action.
            }
        } message: { details in
            Text(details.error)
        }
    }
}

// MARK: - alert(isPresented:error:actions:message:)
/// https://developer.apple.com/documentation/swiftui/view/alert(ispresented:error:actions:message:)
struct TicketPurchase: View {
    @State private var error: TicketPurchaseError? = nil
    @State private var showAlert = false


    var body: some View {
        TicketForm(showAlert: $showAlert, error: $error)
            .alert(isPresented: $showAlert, error: error) { _ in
                Button("OK") {
                    // Handle acknowledgement.
                }
            } message: { error in
                Text(error.recoverySuggestion ?? "Try again later.")
            }
    }
}


// MARK: - 250323 TabView
/// https://developer.apple.com/documentation/swiftui/tabview
/// To create a user interface with tabs, place Tabs in a TabView. On iOS, you can also use one of the badge modifiers, like badge(_:), to assign a badge to each of the tabs.
TabView {
    Tab("Received", systemImage: "tray.and.arrow.down.fill") {
        ReceivedView()
    }
    .badge(2)

    Tab("Sent", systemImage: "tray.and.arrow.up.fill") {
        SentView()
    }

    Tab("Account", systemImage: "person.crop.circle.fill") {
        AccountView()
    }
    .badge("!")
}

TabView(selection: $selection) {
    Tab("Received", systemImage: "tray.and.arrow.down.fill", value: 0) {
        ReceivedView()
    }

    Tab("Sent", systemImage: "tray.and.arrow.up.fill", value: 1) {
        SentView()
    }

    Tab("Account", systemImage: "person.crop.circle.fill", value: 2) {
        AccountView()
    }
}

// The following example uses a ForEach to create a scrolling tab view that shows the temperatures of various cities.
TabView {
    ForEach(cities) { city in
        TemperatureView(city)
    }
}
.tabViewStyle(.page)

// The sidebarAdaptable style supports declaring a secondary tab hierarchy by grouping tabs with a TabSection.
TabView {
    Tab("Requests", systemImage: "paperplane") {
        RequestsView()
    }


    Tab("Account", systemImage: "person.crop.circle.fill") {
        AccountView()
    }


    TabSection("Messages") {
        Tab("Received", systemImage: "tray.and.arrow.down.fill") {
            ReceivedView()
        }


        Tab("Sent", systemImage: "tray.and.arrow.up.fill") {
            SentView()
        }


        Tab("Drafts", systemImage: "pencil") {
            DraftsView()
        }
    }
}
.tabViewStyle(.sidebarAdaptable)

// MARK: - Changing tab structure between horizontal and regular size classes
struct BrowseTabExample: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    @State var selection: MusicTab = .listenNow
    @State var browseTabPath: [MusicTab] = []
    @State var playlists = [Playlist("All Playlists"), Playlist("Running")]

    var body: some View {
            TabView(selection: $selection) {
                Tab("Listen Now", systemImage: "play.circle", value: .listenNow) {
                    ListenNowView()
                }

                Tab("Radio", systemImage: "dot.radiowaves.left.and.right", value: .radio) {
                    RadioView()
                }

                Tab("Search", systemImage: "magnifyingglass", value: .search) {
                    SearchDetailView()
                }

                Tab("Browse", systemImage: "list.bullet", value: .browse) {
                    LibraryView(path: $browseTabPath)
                }
                .hidden(sizeClass != .compact)

                TabSection("Library") {
                    Tab("Recently Added", systemImage: "clock", value: MusicTab.library(.recentlyAdded)) {
                        RecentlyAddedView()
                    }

                    Tab("Artists", systemImage: "music.mic", value: MusicTab.library(.artists)) {
                        ArtistsView()
                    }
                }
                .hidden(sizeClass == .compact)

                TabSection("Playlists") {
                    ForEach(playlists) { playlist in
                        Tab(playlist.name, image: playlist.imafe, value: MusicTab.playlists(playlist)) {
                            playlist.detailView()
                        }
                    }
                }
                .hidden(sizeClass == .compact)
            }
            .tabViewStyle(.sidebarAdaptable)
            .onChange(of: sizeClass, initial: true) { _, sizeClass in
                if sizeClass == .compact && selection.showInBrowseTab {
                    browseTabPath = [selection]
                    selection = .browse
                } else if sizeClass == .regular && selection == .browse {
                    selection = browseTabPath.last ?? .library(.recentlyAdded)
                }
            }
        }
    }
}


struct LibraryView: View {
    @Binding var path: [MusicTab]

    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(MusicLibraryTab.allCases, id: \.self) { tab in
                    NavigationLink(tab.rawValue, value: MusicTab.library(tab))
                }
                // Code to add playlists here
            }
            .navigationDestination(for: MusicTab.self) { tab in
                tab.detail()
            }
        }
    }
}

// MARK: - Adding support for customization
/// You can allow people to customize the tabs in a TabView by using sidebarAdaptable style with the tabViewCustomization(_:) modifier. Customization allows people to drag tabs from the sidebar to the tab bar, hide tabs, and rearrange tabs in the sidebar.
@AppStorage
private var customization: TabViewCustomization

TabView {
    Tab("Home", systemImage: "house") {
        MyHomeView()
    }
    .customizationID("com.myApp.home")

    Tab("Reports", systemImage: "chart.bar") {
        MyReportsView()
    }
    .customizationID("com.myApp.reports")

    TabSection("Categories") {
        Tab("Climate", systemImage: "fan") {
            ClimateView()
        }
        .customizationID("com.myApp.climate")

        Tab("Lights", systemImage: "lightbulb") {
            LightsView()
        }
        .customizationID("com.myApp.lights")
    }
    .customizationID("com.myApp.browse")
}
.tabViewStyle(.sidebarAdaptable)
.tabViewCustomization($customization)

/*
 nonisolated
 init(
     _ titleKey: LocalizedStringKey,
     systemImage: String,
     value: Value,
     @ViewBuilder content: () -> Content
 ) where Label == DefaultTabLabel
 */

/*
 nonisolated
 init(
     value: Value,
     @ViewBuilder content: () -> Content,
     @ViewBuilder label: () -> Label
 )
 */

// MARK: - 250323 Navigation
/// https://developer.apple.com/documentation/swiftui/navigation
// LX: Sample Code 250323NavigationSample

// NavigationLink
/// https://developer.apple.com/documentation/swiftui/navigationlink
// MARK: - Create a presentation link
NavigationStack {
    List {
        NavigationLink("Mint", value: Color.mint)
        NavigationLink("Pink", value: Color.pink)
        NavigationLink("Teal", value: Color.teal)
    }
    .navigationDestination(for: Color.self) { color in
        ColorDetail(color: color)
    }
    .navigationTitle("Colors")
}

// MARK: - Control a presentation link programmatically
@State private var colors: [Color] = []

NavigationStack(path: $colors) {
    // ...
}

func showBlue() {
    colors.append(.blue)
}

// MARK: - Coordinate with a list
// Serialize the path
/*
 When the values you present on the navigation stack conform to the Codable protocol, you can use the path’s codable property to get a serializable representation of the path. Use that representation to save and restore the contents of the stack. For example, you can define an ObservableObject that handles serializing and deserializing the path:
 */
class MyModelObject: ObservableObject {
    @Published var path: NavigationPath

    static func readSerializedData() -> Data? {
        // Read data representing the path from app's persistent storage.
    }


    static func writeSerializedData(_ data: Data) {
        // Write data representing the path to app's persistent storage.
    }

    init() {
        if let data = Self.readSerializedData() {
            do {
                let representation = try JSONDecoder().decode(
                    NavigationPath.CodableRepresentation.self,
                    from: data)
                self.path = NavigationPath(representation)
            } catch {
                self.path = NavigationPath()
            }
        } else {
            self.path = NavigationPath()
        }
    }

    func save() {
        guard let representation = path.codable else { return }
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(representation)
            Self.writeSerializedData(data)
        } catch {
            // Handle error.
        }
    }
}

@StateObject private var pathState = MyModelObject()
@Environment(\.scenePhase) private var scenePhase


var body: some View {
    NavigationStack(path: $pathState.path) {
        // Add a root view here.
    }
    .onChange(of: scenePhase) { phase in
        if phase == .background {
            pathState.save()
        }
    }
}

// MARK: - 250320 Windows
/// https://developer.apple.com/documentation/swiftui/windows
/*
 WindowGroup
 A scene that presents a group of identically structured windows.
 */
@main
struct Mail: App {
    var body: some Scene {
        WindowGroup {
            MailViewer() // Define a view hierarchy for the window.
        }
    }
}
/*
 Important
 To enable an iPadOS app to simultaneously display multiple windows,
 be sure to include the UIApplicationSupportsMultipleScenes key with a value of true in the UIApplicationSceneManifest dictionary of your app’s Information Property List.
 */

// Open windows programmatically
WindowGroup(id: "mail-viewer") { // Identify the window group.
    MailViewer()
}

struct NewViewerButton: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button("Open new mail viewer") {
            openWindow(id: "mail-viewer") // Match the group's identifier.
        }
    }
}

// Present data in a window
/// If you initialize a window group with a presentation type, you can pass data of that type to the window when you open it. For example, you can define a second window group for the Mail app that displays a specified message:
@main
struct Mail: App {
    var body: some Scene {
        WindowGroup {
            MailViewer(id: "mail-viewer")
        }

        // A window group that displays messages.
        WindowGroup(for: Message.ID.self) { $messageID in
            MessageDetail(messageID: messageID)
        }
    }
}

/// Be sure that the type you present conforms to both the Hashable and Codable protocols. Also, prefer lightweight data for the presentation value. For model values that conform to the Identifiable protocol, the value’s identifier works well as a presentation type, as the above example demonstrates.
struct NewMessageButton: View {
    var message: Message
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        Button("Open message") {
            openWindow(value: message.id)
        }
    }
}

/*
 WindowGroup(for: Message.ID.self) { $messageID in
     MessageDetail(messageID: messageID)
 } defaultValue: {
     model.makeNewMessage().id // A new message that your model stores.
 }
 */

// Title your app’s windows
WindowGroup("Message", for: Message.ID.self) { $messageID in
    MessageDetail(messageID: messageID)
}

// Distinguish windows that present like data
WindowGroup("Message", id: "message", for: UUID.self) { $uuid in
    MessageDetail(uuid: uuid)
}
WindowGroup("Account", id: "account-info", for: UUID.self) { $uuid in
    AccountDetail(uuid: uuid)
}

struct ActionButtons: View {
    var messageID: UUID
    var accountID: UUID

    @Environment(\.openWindow) private var openWindow

    var body: some View {
        HStack {
            Button("Open message") {
                openWindow(id: "message", value: messageID)
            }
            Button("Edit account information") {
                openWindow(id: "account-info", value: accountID)
            }
        }
    }
}

/// The dismiss action doesn’t close the window if you call it from a modal — like a sheet or a popover — that you present from the window. In that case, the action dismisses the modal presentation instead.
struct AccountDetail: View {
    var uuid: UUID?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            // ...


            Button("Dismiss") {
                dismiss()
            }
        }
    }
}

// MARK: - 250320 Scenes: Scene Phase
/// https://developer.apple.com/documentation/swiftui/scenephase
struct MyView: View {
    @ObservedObject var model: DataModel
    @Environment(\.scenePhase) private var scenePhase


    var body: some View {
        TimerView()
            .onChange(of: scenePhase) {
                model.isTimerRunning = (scenePhase == .active)
            }
    }
}

@main
struct MyApp: App {
    @Environment(\.scenePhase) private var scenePhase


    var body: some Scene {
        WindowGroup {
            MyRootView()
        }
        .onChange(of: scenePhase) {
            if scenePhase == .background {
                // Perform cleanup when all scenes within
                // MyApp go to the background.
            }
        }
    }
}

/*
 case active
    The scene is in the foreground and interactive.
 case inactive
    The scene is in the foreground but should pause its work.
 case background
    The scene isn’t currently visible in the UI.
 */


// MARK: - 250320 Scenes: handlesExternalEvents
/// https://developer.apple.com/documentation/swiftui/scene/handlesexternalevents(matching:)
/// Specifies the external events for which SwiftUI opens a new instance of the modified scene.
/// conditions:
/// A set of strings that SwiftUI compares against the incoming user activity or URL to see if SwiftUI can open a new scene instance to handle the external event.
nonisolated
func handlesExternalEvents(matching conditions: Set<String>) -> some Scene
// MARK: - 250320 Scenes: Configuring scene visibility
/// https://developer.apple.com/documentation/swiftui/scene/defaultlaunchbehavior(_:)
// Sets the preferred visibility of the non-transient system views overlaying the app.
nonisolated
func persistentSystemOverlays(_ preferredVisibility: Visibility) -> some Scene

// In iOS, the following example hides every persistent system overlay.
struct ImmersiveView: View {
    var body: some View {
        Text("Maximum immersion")
            .persistentSystemOverlays(.hidden)
    }
}

// MARK: - 250320 Scenes: Scene
/// https://developer.apple.com/documentation/swiftui/scene
@MainActor @preconcurrency
protocol Scene

/*
 You create an App by combining one or more instances that conform to the Scene protocol in the app’s body. You can use the built-in scenes that SwiftUI provides, like WindowGroup, along with custom scenes that you compose from other scenes. To create a custom scene, declare a type that conforms to the Scene protocol. Implement the required body computed property and provide the content for your custom scene:
 */
struct MyScene: Scene {
    var body: some Scene {
        WindowGroup {
            MyRootView()
        }
    }
}

@SceneBuilder @MainActor @preconcurrency
var body: Self.Body { get }

associatedtype Body : Scene

/*
 Read the scenePhase environment value from within a scene or one of its views to check whether a scene is active or in some other state. You can create a property that contains the scene phase, which is one of the values in the ScenePhase enumeration, using the Environment attribute:
 */
struct MyScene: Scene {
    @Environment(\.scenePhase) private var scenePhase
    // ...
}

struct MyScene: Scene {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var cache = DataCache()

    var body: some Scene {
        WindowGroup {
            MyRootView()
        }
        .onChange(of: scenePhase) { newScenePhase in
            if newScenePhase == .background {
                cache.empty()
            }
        }
    }
}

// MARK: - 250320 App Structure: Scene Delegate
/// https://developer.apple.com/documentation/swiftui/uiapplicationdelegateadaptor#Scene-delegates
// Some iOS apps define a UIWindowSceneDelegate to handle scene-based events, like app shortcuts:
class MySceneDelegate: NSObject, UIWindowSceneDelegate, ObservableObject {
    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem
    ) async -> Bool {
        // Do something with the shortcut...


        return true
    }
}

// You can provide this kind of delegate to a SwiftUI app by returning the scene delegate’s type from the application(_:configurationForConnecting:options:) method inside your app delegate:
extension MyAppDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {


        let configuration = UISceneConfiguration(
                                name: nil,
                                sessionRole: connectingSceneSession.role)
        if connectingSceneSession.role == .windowApplication {
            configuration.delegateClass = MySceneDelegate.self
        }
        return configuration
    }
}

/*
 When you configure the UISceneConfiguration instance, you only need to indicate the delegate class, and not a scene class or storyboard. SwiftUI creates and manages the delegate instance, and sends it any relevant delegate callbacks.
 Hint: -> As with the app delegate, if you make your scene delegate an observable object, SwiftUI automatically puts it in the Environment, from where you can access it with the EnvironmentObject property wrapper, and create bindings to its published properties.
 */
@EnvironmentObject private var appDelegate: MyAppDelegate

// MARK: - 250320 App Structure: UIApplicationDelegateAdaptor
/// https://developer.apple.com/documentation/swiftui/uiapplicationdelegateadaptor
/// A property wrapper type that you use to create a UIKit app delegate.
@MainActor @preconcurrency @propertyWrapper
struct UIApplicationDelegateAdaptor<DelegateType> where DelegateType : NSObject, DelegateType : UIApplicationDelegate


class MyAppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // Record the device token.
    }
}

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: MyAppDelegate

    var body: some Scene { ... }
}

// If your app delegate conforms to the ObservableObject protocol, as in the example above, then SwiftUI puts the delegate it creates into the Environment. You can access the delegate from any scene or view in your app using the EnvironmentObject property wrapper:
@EnvironmentObject private var appDelegate: MyAppDelegate

/*
 --> Important
 Manage an app’s life cycle events without using an app delegate whenever possible. For example, prefer to handle changes in ScenePhase instead of relying on delegate callbacks, like application(_:didFinishLaunchingWithOptions:).
 */

/*
 Use the projected value to get a binding to a value that the delegate publishes. Access the projected value by prefixing the name of the delegate instance with a dollar sign ($). For example, you might publish a Boolean value in your application delegate:
 */
class MyAppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    @Published var isEnabled = false
    // ...
}

struct MyView: View {
    @EnvironmentObject private var appDelegate: MyAppDelegate

    var body: some View {
        Toggle("Enabled", isOn: $appDelegate.isEnabled)
    }
}


// MARK: - 250320 App Structure: UILaunchScreen
/// https://developer.apple.com/documentation/bundleresources/information-property-list/uilaunchscreen
// Property List Key -> `UILaunchScreen`
/// You use this key to define the launch screen that the system displays while your app launches. If you need to provide different launch screens in response to being launched by different URL schemes, use UILaunchScreens instead.
/// https://www.avanderlee.com/xcode/launch-screen/

// Note
// Use this key to configure the user interface during app launch in a way that doesn’t rely on storyboards.
/// If you prefer to use storyboards, use UILaunchStoryboardName instead (https://developer.apple.com/documentation/bundleresources/information-property-list/uilaunchstoryboardname).

// Configuring launch screens per URL scheme
/// https://www.avanderlee.com/xcode/launch-screen/#configuring-launch-screens-per-url-scheme

// MARK: - 250320 App Structure: App
/// https://developer.apple.com/documentation/swiftui/app
//  You can have exactly one entry point among all of your app’s files.
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            Text("Hello, world!")
        }
    }
}

// SwiftUI provides some concrete scene types to handle common scenarios,
// like for displaying documents or settings. You can also create custom scenes.
@main
struct Mail: App {
    var body: some Scene {
        WindowGroup {
            MailViewer()
        }
        Settings {
            SettingsView()
        }
    }
}

/*
 You can declare state in your app to share across all of its scenes. For example, you can use the StateObject attribute to initialize a data model, and then provide that model on a view input as an ObservedObject or through the environment as an EnvironmentObject to scenes in the app:
 */

@main
struct Mail: App {
    @StateObject private var model = MailModel()

    var body: some Scene {
        WindowGroup {
            MailViewer()
                .environmentObject(model) // Passed through the environment.
        }
        Settings {
            SettingsView(model: model) // Passed as an observed object.
        }
    }
}

/// If you precede your App conformer’s declaration with the @main attribute, the system calls the conformer’s main() method to launch the app.
/// SwiftUI provides a default implementation of the method that manages the launch process in a platform-appropriate way.
@MainActor @preconcurrency
static func main()

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension App {
    /// Initializes and runs the app.
    ///
    /// If you precede your ``SwiftUI/App`` conformer's declaration with the
    /// [@main](https://docs.swift.org/swift-book/ReferenceManual/Attributes.html#ID626)
    /// attribute, the system calls the conformer's `main()` method to launch
    /// the app. SwiftUI provides a
    /// default implementation of the method that manages the launch process in
    /// a platform-appropriate way.
    @MainActor @preconcurrency public static func main()
}

@MainActor @preconcurrency
init()

associatedtype Body : Scene

@SceneBuilder @MainActor @preconcurrency
var body: Self.Body { get }


/// A type conforming to this protocol inherits @preconcurrency @MainActor isolation from the protocol if the conformance is included in the type’s base declaration:
struct MyCustomType: Transition {
    // `@preconcurrency @MainActor` isolation by default
}

/// Isolation to the main actor is the default, but it’s not required. Declare the conformance in an extension to opt out of main actor isolation:
extension MyCustomType: Transition {
    // `nonisolated` by default
}

