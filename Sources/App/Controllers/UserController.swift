import Vapor
import FluentProvider
import AuthProvider

struct UserController {
    func addRoutes(to drop: Droplet) {
        let userGroup = drop.grouped("user")
        //user/register - POST
        //user/login - POST
        //user/profile - POST, GET
        //user/forgot - POST - TBD
        userGroup.post("register", handler: createUser)
        userGroup.post("profile", handler: createUser)
        userGroup.get(User.parameter, handler: getUser)
    }

    func createUser(_ req: Request) throws -> ResponseRepresentable {
        guard let json = req.json else {
            throw Abort.badRequest
        }
        
        guard
            let email = json["email"]?.string,
            let password = json["password"]?.string
            else {
                throw Abort.badRequest
        }
        
        guard
            try User.makeQuery().filter("email", email).first() == nil
            else {
                throw Abort.badRequest
        }
        
        let hashedPassword = try BCryptHasher().make(password.bytes).makeString()
        
        let user = User(username: email, password: hashedPassword)
        try user.save()
        
        return user
    }

    func allUsers(_ req: Request) throws -> ResponseRepresentable {
        let users = try User.all()
        return try users.makeJSON()
    }

    func getUser(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.parameters.next(User.self)
        return user
    }
    
    func login(_ req: Request) throws -> ResponseRepresentable {
        
        guard let json = req.json else {
            throw Abort.badRequest
        }
        
        guard
            let email = json["email"]?.string,
            let password = json["password"]?.string
            else {
                throw Abort.badRequest
        }
        
        let credentials = Password(username: email, password: password)
        
        // returns matching user (throws error if user doesn't exist)
        let user = try User.authenticate(credentials)
        
        // persists user and creates a session cookie
        req.auth.authenticate(user)
        
        return user
    }
    
    func profile(_ req: Request) throws -> ResponseRepresentable {
        // returns user from session
        let user: User = try req.auth.assertAuthenticated()
        return user
    }
    
    func logout(_ req: Request) throws -> ResponseRepresentable {
        try req.auth.unauthenticate()
        var json = JSON()
        try json.set("success", true)
        return json
    }
}
