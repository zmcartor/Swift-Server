import Vapor
import Leaf

// this is a type for passing data into the view
struct IndexContext: Encodable {
    let title: String
    let acronyms: [Acronym]?
}

struct AcronymContext: Encodable {
    let title: String
    let acronym: Acronym
    let user: User
}

struct WebsiteController: RouteCollection {

    func boot(router: Router) throws {
        router.get(use: indexHandler)
        router.get("acronyms", Acronym.parameter, use: acronymHandler)
    }
    
    func indexHandler(_ req: Request) throws -> Future<View> {
        
        return Acronym.query(on: req).all().flatMap(to:View.self){ acros in
            
            let acroData = acros.isEmpty ? nil : acros
            let context = IndexContext(title: "Acronyms", acronyms: acroData)
            return try req.view().render("index", context)
        }
    }
    
    func acronymHandler(_ req: Request) throws -> Future<View> {
        
        // save off our variables since there is no easy way to inject 'next' varibles into future.
        var theAcro:Acronym?
        
        return try req.parameters.next(Acronym.self).flatMap(to: User.self) { acro in
            theAcro = acro
            return acro.user.get(on: req)
        }
        .flatMap(to:View.self) { user in
            let context = AcronymContext(title: "An Acro", acronym: theAcro!, user: user)
            return try req.view().render("acronym", context)
        }
    }
}
