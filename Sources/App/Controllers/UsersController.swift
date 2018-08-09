import Vapor
import Fluent

struct UsersController : RouteCollection {
    
    let apiRoot:[PathComponentsRepresentable] = ["api", "users"]
    
    func boot(router: Router) throws {
        
        // group the routes under a namespace. Great!
        let routeGroup = router.grouped(apiRoot)
        
        routeGroup.post(User.self, use: createHandler)
        routeGroup.get(use: getAllHandler)
        routeGroup.get(User.parameter, use: getHandler)
        routeGroup.get(User.parameter, "acronyms", use: getAcronymsHandler)
    }
    
    func createHandler(_ req: Request, user:User) throws -> Future<User> {
        return user.save(on:req)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[User]> {
        return User.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(User.self)
    }
    
    func getAcronymsHandler(_ req: Request) throws -> Future<[Acronym]> {
        return try req.parameters.next(User.self).flatMap(to: [Acronym].self) {
            user  in
            try user.acronyms.query(on: req).all()
        }
    }
    
}
