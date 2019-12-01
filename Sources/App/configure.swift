import Vapor
import Fluent
import FluentSQLite
import Leaf

/// Called before your application initializes.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#configureswift)
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    // Configure the rest of your application here
    
    // Mark: - Configure Leaf
    try services.register(LeafProvider())
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    
    var middleware = MiddlewareConfig.default()
    middleware.use(FileMiddleware.self)
    services.register(middleware)
    
    // Mark: - Configure Database
    let directoryConfig = DirectoryConfig.detect()
    services.register(directoryConfig)
    
    // Tells Vapor that we intend to use both Fluent and SQLite in our requests
    try services.register(FluentSQLiteProvider())
    
    // Creates an empty DatabasesConfig object, which
    // is used to connect any sort of database to the rest of Fluent
    var databaseConfig = DatabasesConfig()
    
    // opens polls.db in the current working directory, ready to use
    let db = try SQLiteDatabase(storage: .file(path: "\(directoryConfig.workDir)polls.db"))
    
    // connects that SQLite database to Vapor's built-in .sqlite database identifier
    databaseConfig.add(database: db, as: .sqlite)
    
    // Registers the whole thing with the application services, so it can be
    // used elsewhere in the app
    services.register(databaseConfig)
    
    // the last step before we're done with Fluent's configuration is to tell it
    // that migration is available for Poll on our SQLite database, which means
    // we're telling it to configure the create and destroy the database on our behalf.
    // this is done by adding the lines below
    
    // create a migrationconfig
    var migrationConfig = MigrationConfig()
    
    // tell the migration config that our Poll struct should be migrated using
    // the SQLite database identifer
    migrationConfig.add(model: Poll.self, database: .sqlite)
    
    // register that with our app's services
    services.register(migrationConfig)
}
