import Vapor
import FluentPostgreSQL

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentPostgreSQLProvider())

    /// Register routes to the router
    let router = EngineRouter.default()

    try router.register(collection: AcronymsController())
    try router.register(collection: UsersController())
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a SQLite database
    try services.register(FluentPostgreSQLProvider())

    let postgresqlConfig = PostgreSQLDatabaseConfig(
        hostname: "127.0.0.1",
        port: 5432,
        username: "zm",
        database: "til",
        password: nil
    )
    services.register(postgresqlConfig)

    /// Configure migrations
    var migrations = MigrationConfig()
    
    // configure the User migration first
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: Acronym.self, database: .psql)
    
    services.register(migrations)
}
