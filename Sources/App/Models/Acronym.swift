import Vapor
import FluentPostgreSQL

final class Acronym : Content {
    var id : Int?
    var short : String
    var long : String
    var userID: User.ID
 
    init(short: String, long: String, userId: User.ID) {
        self.short = short
        self.long = long
        self.userID = userId
    }
}

// Query the parent of this Acronym (which is a user object)
extension Acronym {
    var user: Parent<Acronym, User> {
        return parent(\.userID)
    }
    
    var categories : Siblings<Acronym, Category, AcronymCategoryPivot> {
        // calling 'siblings' returns all related categories THROUGH this pivot table.
        return siblings()
    }
}

// this will automatically set the associatedTypes for database, id, idKey
extension Acronym: PostgreSQLModel {}

// enables REST lookup by allowing model to act as a param
extension Acronym: Parameter {}

extension Acronym: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            
            // this adds all the fields to the DB
            try addProperties(to: builder)
            
            // create the foreign key constraints
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}
