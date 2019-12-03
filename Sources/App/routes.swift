import Routing
import Vapor
import Foundation

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    
    router.get { req -> Future<View> in
        let context = [String: String]()
        return try req.view().render("home", context)
    }
    
    // were using the decoding helper form of post():
    // the first parameter is an object we want Vapor to decode
    // and everything after at is the route it should be attached to.
    // inside the route closure we have a valid poll object that we can
    // then save to the database
    router.post(Poll.self, at: "polls", "create") { req, poll -> Future<Poll> in
        
        // when we save the poll we are given a Future<Poll> back
        // a promist that some work will complete, and we'll be given the new poll
        
        // we can send that Future<Poll> back from our route, and Vapor will
        // automatically wait for it to complete
        
        
        // returning a Future<Poll>
        // in fact, now it's required
        return poll.save(on: req)
        
        /*
         The real magic lies in the transformation of poll
         it starts as a Poll object but it's incomplete:
         
         we're taking the values submitted through a form
         (title, options, etc.), but that doesn't include the UUID
         that identifies this poll uniquely.
         
         That's because we can't expect (or trust!) users to provide
         such data, so it needs to be filled in by Fluent. When the save()
         method completes, Flient will automatically have filled in its UUID
         with a new, unique value, and it's safe to return.
        */
    }
    
    
    /*
    It returns 'Future<[Poll]>' which is an array of Poll
    objects. We already made the Poll struct conform to Content
    so it can be returned as JSON, and that automatically means
    arrays of polls can be returned as JSON.
    */
    router.get("polls", "list") { req -> Future<View> in
        
        /*
         Running Poll.query() starts a Fluent search for Poll
         objects, which means we're able to search for polls that interest us.
         
         In this case we're using all(), which simply returns all polls, but in project 4
         I'll show you how to filter that list.
         
         Just like saving things, running queries returns a future because it won't complete
         immediately. There could potentially be thousands of polls to read and convert to JSON,
         so using a future means that work can happen in the background while Vapor goes back
         to processing other things.
         
         */
        
        let futurePolls: Future<[Poll]> = Poll.query(on: req).all()
        
        var polls: [Poll] = []
        let _ = futurePolls.map { closurePolls in
            for poll in closurePolls {
                polls.append(poll)
            }
        }
        
        var context = [String: [Poll]]()
        context["polls"] = polls
        return try req.view().render("polls", context)
    }
    
    /*
     Get a specific poll
     
     */
    router.get("polls", UUID.parameter) { req -> Future<Poll> in
        let id = try req.parameters.next(UUID.self)
        
        return Poll.find(id, on: req).map(to: Poll.self) { poll in
            guard let poll = poll else { throw Abort(.notFound) }
            
            return poll
        }
    }
    
    /*
     Delete a poll with a specific UUID.parameter
     
     */
    router.delete("polls", UUID.parameter) { req -> Future<String> in
        let id = try req.parameters.next(UUID.self)
        
        return try Poll.find(id, on: req).map(to: String.self) { poll in
            guard let poll = poll, let id = poll.id else { throw Abort(.notFound) }
            let _ = poll.delete(on: req)
            return "deleted post: \(id)"
        }
        
    }
    
    
    router.post("polls", "vote", UUID.parameter, Int.parameter) { req -> Future<Poll> in
        let id = try req.parameters.next(UUID.self)
        let vote = try req.parameters.next(Int.self)
        
        return try Poll.find(id, on: req).flatMap(to: Poll.self) { poll in
            guard var poll = poll else {
                throw Abort(.notFound)
            }
            
            if vote == 1 {
                poll.votes1 += 1
            } else {
                poll.votes2 += 1
            }
            
            return poll.save(on: req)
        }
        
    }
    
}


// map transforms Future<String> to Future<Int>

// flatMap transforms Future<String> to String

/*
 
 Map(): When you use map() on a Future<A>, your closure will get called with the A
 so you can transofrm it to a B. When that gets returned it will automatically
 become a Future<B>.
 
 FlatMap(): When you use flatMap() on a Future<A>, your closure will get called with the A
 so you can transform it to a Future<B>. When that gets returned it _would_ have been a
 Future<Future<<B>>, but flatMap() flattens that into just Future<B>.
 
 Single run: 'If the thing you're returning from your closure is a future you should use
 flatMap(), otherwise use map().'
 
 Map transforms an array of values into an array of other values, and flatMap does the same thing
 but also flattens a result of nested collections into just a single array.
 
 FlatMap() is there to convert future futures into regular futures.
 
 */
