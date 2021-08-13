import Foundation
import Combine

let test = Test()
test.run()
test.group.users = [ChatUser(name: "NEW1").save(), ChatUser(name: "NEW2").save()].ref
test.group.admin = ChatUser(name: "NEW-ADMIN")
RunLoop.current.run()

class Test {
    
    @Published
    public var group: ChatGroup
    
    var u0: ChatUser
    var u1: ChatUser
    var u2: ChatUser
    var u3: ChatUser
    
    var subs: [AnyCancellable] = []
    
    init() {
        u0 = ChatUser(name: "Sarah").save()
        u1 = ChatUser(name: "Andreas").save()
        u2 = ChatUser(name: "Daniel").save()
        u3 = ChatUser(name: "MISSING") // lets not save this user
        group = ChatGroup(name: "Test", owner: u0).save()
    }
    
    public func run() {
        
        group.users = [u1, u2].ref
        group.users.append(u3)

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        let result = String(data: try! encoder.encode(group), encoding: .utf8)!
        print(result)

        let decoder = JSONDecoder()
        let newGroup = try! decoder.decode(ChatGroup.self, from: result.data(using: .utf8)!)
        if let owner = newGroup.owner.deref {
            print("owner: \(owner.name)")
        }

        group.owner.publisher
            .sink { owner in
                print("updated owner: \(owner.name)")
            }
            .store(in: &subs)

        newGroup.users.compactMap({ $0.deref }).forEach { user in
            print("user: \(user.name)")
        }

        newGroup.users.publisher()
            .sink { users in
                print("updated users: \(users.map({ $0.name }).joined(separator: ", "))")
            }
            .store(in: &subs)
        
        $group.sink() { g in
            print ("updated group: admin=\(g.admin.name) owner=\(g.owner.deref!.name) users=\(g.users.deref())")
        }
        .store(in: &subs)
        
        print("prop-foo: \(newGroup.props1["foo"]!.deref!.name)")
    }
}
