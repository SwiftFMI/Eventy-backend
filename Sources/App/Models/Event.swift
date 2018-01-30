import Vapor
import FluentProvider
import HTTP

final class Event: Model {
    let storage = Storage()
    
    fileprivate static let tableName = "Events"
    
    var id: Node?
    var creatorId: User
    var title: String
    var description: String
    var startDate: Date
    var endDate: Date
    var locationId: Location
    var isPrivate: Bool
    
    struct Keys {
        static let creatorId = "creator_id"
        static let title = "title"
        static let description = "description"
        static let startDate = "start_date"
        static let endDate = "end_date"
        static let locationId = "location_id"
        static let isPrivate = "private"
    }

    init(creatorId:User, title:String, description:String, startDate:Date, endDate:Date, locationId:Location, isPrivate:Bool) {
        self.creatorId = creatorId
        self.title = title
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.locationId = locationId
        self.isPrivate = isPrivate
    }
    // MARK: Fluent Serialization
    /// Initializes the Event from the
    /// database row
    init(row: Row) throws {
        creatorId = try row.get(Event.Keys.creatorId)
        title = try row.get(Event.Keys.title)
        description = try row.get(Event.Keys.description)
        startDate = try row.get(Event.Keys.startDate)
        endDate = try row.get(Event.Keys.endDate)
        locationId = try row.get(Event.Keys.locationId)
        isPrivate = try row.get(Event.Keys.isPrivate)
    }

    // Serializes the User to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Event.Keys.creatorId, creatorId)
        try row.set(Event.Keys.title, title)
        try row.set(Event.Keys.description, description)
        try row.set(Event.Keys.startDate, startDate)
        try row.set(Event.Keys.endDate, endDate)
        try row.set(Event.Keys.locationId, locationId)
        try row.set(Event.Keys.isPrivate, isPrivate)
        return row
    }
    
}

extension Event: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) {
            $0.id()
            $0.int(Event.Keys.creatorId)
            $0.string(Event.Keys.title)
            $0.string(Event.Keys.description)
            $0.date(Event.Keys.startDate)
            $0.date(Event.Keys.endDate)
            $0.int(Event.Keys.locationId)
            $0.bool(Event.Keys.isPrivate)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON
extension Event: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(
            creatorId: try json.get(Event.Keys.creatorId),
            title: try json.get(Event.Keys.title),
            description: try json.get(Event.Keys.description),
            startDate: try json.get(Event.Keys.startDate),
            endDate: try json.get(Event.Keys.endDate),
            locationId: try json.get(Event.Keys.locationId),
            isPrivate: try json.get(Event.Keys.isPrivate)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Event.Keys.creatorId, creatorId)
        try json.set(Event.Keys.title, title)
        try json.set(Event.Keys.description, description)
        try json.set(Event.Keys.startDate, startDate)
        try json.set(Event.Keys.endDate, endDate)
        try json.set(Event.Keys.locationId, locationId)
        try json.set(Event.Keys.isPrivate, isPrivate)
        return json
    }
}


// MARK: HTTP

// This allows Event models to be returned
// directly in route closures
extension Event: ResponseRepresentable { }

// MARK: Update

// This allows the Event model to be updated
// dynamically by the request.
//extension Event: Updateable {
//    // Updateable keys are called when `post.update(for: req)` is called.
//    // Add as many updateable keys as you like here.
//    public static var updateableKeys: [UpdateableKey<Event>] {
//        return [
//            // If the request contains a String at key "content"
//            // the setter callback will be called.
//            UpdateableKey(Event.Keys.key, String.self) { obj, content in
//                obj.key = content
//            }
//        ]
//    }
//}


extension Event {
    var assets: Siblings<Event, Asset, Pivot<Event, Asset>> {
        return siblings()
    }
}

extension Event {
    var participants: Siblings<Event, User, Pivot<Event, User>> {
        return siblings()
    }
}
