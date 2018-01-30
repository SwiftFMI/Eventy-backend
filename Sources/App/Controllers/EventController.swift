import Vapor
import FluentProvider
import AuthProvider

struct EventController {
    func addRoutes(to drop: Droplet, middleware: [MiddlewareType: Middleware]) {
        let eventsGroup = drop.grouped("events")
        eventsGroup.get("public", handler: allPublicEvents)
        
        //event/:id/upload - POST - upload asset
        //event/register - GET (html page)
        //event/join - POST (userId)
        //event/members/{id} - GET
        
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
        
        sessionRoute.post("join", handler: join)
        sessionRoute.post("upload", handler: upload)
        
        sessionRoute.grouped([middleware[.persist]!]).post("private","create") { request in
            guard let json = request.json else {
                throw Abort.badRequest
            }
            
            let event = try Event(json: json)
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
    
    
    func upload(_ req: Request) throws -> ResponseRepresentable {
        return ""
    }
}
