import Vapor
import Leaf

// this is a type for passing data into the view
struct IndexContext: Encodable {
    let title: String
    let acronyms: [Acronym]?
}

struct WebsiteController: RouteCollection {

    func boot(router: Router) throws {
        router.get(use: indexHandler)
    }
    
    func indexHandler(_ req: Request) throws -> Future<View> {
        
        return Acronym.query(on: req).all().flatMap(to:View.self){ acros in
            
            let acroData = acros.isEmpty ? nil : acros
            let context = IndexContext(title: "Acronyms", acronyms: acroData)
            return try req.view().render("index", context)
        }
        
        let context = IndexContext(title: "Whompers!!")
        return try req.view().render("index", context)
    }
}
