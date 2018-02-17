import Vapor
import FluentProvider
import AuthProvider
import Multipart

struct EventController {
    let fileStorage:FileStorage

    init(storage:FileStorage) {
        self.fileStorage = storage
    }
    
    func addRoutes(to drop: Droplet, middleware: [MiddlewareType: Middleware]) {
        let eventsGroup = drop.grouped("events")
        
        eventsGroup.get("public", handler: allPublicEvents)
        
        //events/:id/upload - POST - upload asset == DONE
        //events/register - GET (html page) - use private api now
        //events/join - POST (userId)
        //events/members/{id} - GET
        
        //private API will be removed later
        //events/private/create - POST
        
        let sessionRoute = eventsGroup.grouped([middleware[.session]!])
        
        sessionRoute.get("members", ":id") { request in
            guard let eventId = request.parameters["id"]?.int else {
                throw Abort.badRequest
            }
            
            guard
                let event = try Event.makeQuery().filter("id", eventId).first()
                else {
                    throw Abort.badRequest
            }
            
            return try event.participants.all().makeJSON()
        }
        
        sessionRoute.post(":id","join", handler: join)
        sessionRoute.post(":id","upload", handler: upload)
        
    sessionRoute.grouped([middleware[.persist]!]).post("private","create") { request in
            
            guard let json = request.json else {
                throw Abort.badRequest
            }
            
            guard
                let user = try? request.auth.assertAuthenticated(User.self),
                let title = json["title"]?.string,
                let description = json["description"]?.string,
                let startDateString = json["startDate"]?.string,
                let endDateString = json["endDate"]?.string,
                let locationId = json["location"]?.string,
                let isPrivate = json["isPrivate"]?.bool
                else {
                    throw Abort.badRequest
            }
            
            let startDate = Date()
            let endDate = Date().addingTimeInterval(24 * 60 * 60)
            
            let loc = Location.init(name: "Sofia", lat: 42.0, long: 21.0)
            //TODO: load the location by id?
            try loc.save()
            
            let event = try Event(creator: user, title: title, description: description, startDate: startDate, endDate: endDate, location: loc, isPrivate: false)
            try event.save()
            return event
        }
        
    }
    
    func allPublicEvents(_ req: Request) throws -> ResponseRepresentable {
        let events = try Event.all().filter { $0.isPrivate == false }
        return try events.makeJSON()
    }
    
    func join(_ req: Request) throws -> ResponseRepresentable {
        return ""
    }
    
    
    func upload(_ request: Request) throws -> ResponseRepresentable {
        
        guard let eventId = request.parameters["id"]?.int else {
            throw Abort.badRequest
        }
        
        guard let event = try Event.find(eventId) else {
            throw Abort.notFound
        }
        
        
        
//        guard let fileBytes = request.formData?["file"]?.bytes else {
//            throw Abort.badRequest
//        }
        
        guard let file = request.formData?["file"]?.part else {
            throw Abort.badRequest
        }
        
        
        
        let relativePath = "assets/\(eventId)"
        
        let fileName = try fileStorage.uploadFile(part:file, folder:relativePath)
        let url = relativePath + "/" + fileName
        
        let asset = Asset(name: fileName, url: url)
        try asset.save()
        
        try event.assets.add(asset)
        
        return asset
    }
}
