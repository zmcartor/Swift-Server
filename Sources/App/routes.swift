import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
    
    let acronymsController = AcronymsController()
    try router.register(collection: acronymsController)
    
    // FLATMAP IS FOR CHANGING FUTURE VALUE TO ANOTHER FUTURE VALUE
    // MAP IS FOR CHANGING FUTURE VALUE TO SCALAR VALUE
    
    // uses the request as a 'worker' and 'db connection' to create a query.
    /*
    router.get("api", "acronyms"){ req -> Future<[Acronym]> in
        return Acronym.query(on: req).all()
    }
 */
    
    router.delete("api", "acronyms", Acronym.parameter) { req -> Future<HTTPStatus> in
        return try req.parameters.next(Acronym.self).delete(on: req).transform(to: HTTPStatus.noContent)
    }
    
    // grab a parameter from the request. This isn't a specific model "parameter"
    // run a query with a keypath. wohoo!
    router.get("api", "acronyms", "search") {
        req -> Future<[Acronym]> in
        
        guard let searchTerm = req.query[String.self, at: "term"] else {
                throw Abort(.badRequest)
        }
        
        // create a FILTER GROUP to match either short/long in query.
        return Acronym.query(on: req).group(.or){ or in
            or.filter(\.short == searchTerm)
            or.filter(\.long == searchTerm)
        }.all()
    }
    
    // grab only the FIRST acronym
    router.get("api", "acronyms", "first") {
        req -> Future<Acronym> in
        return Acronym.query(on: req)
            .first() // first returns an OPTIONAL. Not transforming to another future, so it's map
            .map(to: Acronym.self) { acronym in
                guard let acronym = acronym else {
                    throw Abort(.notFound)
                }
                return acronym
        }
    }
    
    // query results can also be sorted.
    router.get("api", "acronyms", "sorted") {
        req -> Future<[Acronym]> in
        return Acronym.query(on: req)
            .sort(\.short, .ascending)
            .all()
    }
}
