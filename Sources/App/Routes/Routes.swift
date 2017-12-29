import Vapor
import AuthProvider
import Sessions

extension Droplet {
    func setupRoutes() throws {
        get("hello") { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
        }
        
        get("plaintext") { req in
            return "Hello, world!"
        }
        
        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }
        
        get("description") { req in return req.description }
        
        //TODO:
        
        let userController = UserController()
        userController.addRoutes(to:self)
        
        let persistMW = PersistMiddleware(User.self)
        let memory = MemorySessions()
        let sessionMW = SessionsMiddleware(memory)
        let loginRoute = grouped([sessionMW, persistMW])
        
        loginRoute.post("login", handler: userController.login)
        loginRoute.get("logout", handler: userController.logout)
        
        let passwordMW = PasswordAuthenticationMiddleware(User.self)
        let authRoute = grouped([sessionMW, persistMW, passwordMW])
        authRoute.get("profile", handler: userController.profile)
        
        //user/register - POST
        //user/login - POST
        
        //events - GET (key & uid)
        //event/:id - GET - event details
        
        //SECURED:
        //user/profile - POST, GET
        //user/forgot - POST - TBD
        //event/:id/upload - POST - upload asset
        //event/register - GET (html page)
        //event/join - POST (userId)
        //event/:id/members - GET
        
        //TBD
        //asset/:id - GET (comments)
        
        
        
        
        
        
        
        
    }
}
