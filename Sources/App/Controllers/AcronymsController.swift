import Vapor
import Fluent

struct AcronymsController : RouteCollection {
    
    let apiRoot:[PathComponentsRepresentable] = ["api", "acronyms"]
    
    func boot(router: Router) throws {
    
        // group the routes under a namespace. Great!
        let routeGroup = router.grouped(apiRoot)
          
        // register all our routes in here
        routeGroup.get(use: getAllHandler)
        routeGroup.get(Acronym.parameter, use: getSingle)
        routeGroup.patch(Acronym.self, at: Acronym.parameter, use:updateAcro)
            
        //  /<id>/user route
        routeGroup.get(Acronym.parameter, "user", use:getUserHandler)
          
        // this entity is being POSTED to it. Not a lookup parameter.
        routeGroup.post(Acronym.self, use: createAcro)
            
        routeGroup.post(Acronym.parameter, "categories", Category.parameter, use: addCategoriesHandler)
            
        routeGroup.get(Acronym.parameter, "categories", use: getCategoriesHandler)
        
        routeGroup.delete(Acronym.parameter, "categories", Category.parameter, use:removeCategoriesHandler)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Acronym]> {
        print("WHOA THIS ROUTE CALLLED WOWOHOO!")
        return Acronym.query(on: req).all()
    }
    
    // because acronym is a parameter, this looks up from DB when passed an ID.
    func getSingle(_ req: Request) throws  -> Future<Acronym> {
        return try req.parameters.next(Acronym.self)
    }
    
    // this will AUTOMATICALLY decode the acronym from the post body, wow!
    func createAcro(_ req: Request, acronym: Acronym) throws -> Future<Acronym> {
        return acronym.save(on: req)
    }
    
    func updateAcro(_ req: Request, acronym: Acronym ) throws -> Future<Acronym> {
        return try req.parameters.next(Acronym.self).map(){ lookup in
            lookup.userID = acronym.userID
            lookup.short = acronym.short
            lookup.long = acronym.long
            return lookup
            }.save(on:req)
    }
    
    // get the acroymn PARENT using .get to load the relation as future
    func getUserHandler(_ req: Request) throws -> Future<User> {
        return try req
            .parameters.next(Acronym.self)
            .flatMap(to: User.self) { acronym in
                return acronym.user.get(on: req)
        }
    }
    
    func addCategoriesHandler(_ req:Request) throws -> Future<HTTPStatus> {
        
        return try flatMap(to: HTTPStatus.self, req.parameters.next(Acronym.self), req.parameters.next(Category.self)) { ac, cat in
            return ac.categories.attach(cat, on: req).transform(to: HTTPStatus.created)
        }
    }
    
    func getCategoriesHandler(_ req: Request) throws -> Future<[Category]> {
        return try req.parameters.next(Acronym.self).flatMap(to: [Category].self) { ac in
            try ac.categories.query(on: req).all()
        }
    }
    
    func removeCategoriesHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self, req.parameters.next(Acronym.self), req.parameters.next(Category.self)) {
            acc, cat in
            return acc.categories.detach(cat, on: req).transform(to: HTTPStatus.noContent)
        }
        
    }
    
}
