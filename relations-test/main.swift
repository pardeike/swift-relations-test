import Foundation

let u0 = ChatUser(name: "Sarah").save()
let u1 = ChatUser(name: "Andreas").save()
let u2 = ChatUser(name: "Daniel").save()
let u3 = ChatUser(name: "MISSING") // lets not save this user
var group = ChatGroup(name: "Test", owner: u0).save()
group.users = [u1, u2].ref
group.users.append(u3.ref)

var encoder = JSONEncoder()
encoder.outputFormatting = .prettyPrinted

let result = String(data: try! encoder.encode(group), encoding: .utf8)!
print(result)

var decoder = JSONDecoder()
let newGroup = try! decoder.decode(ChatGroup.self, from: result.data(using: .utf8)!)
if let owner = newGroup.owner.deref {
	print("owner: \(owner.name)")
}
newGroup.users.compactMap({ $0.deref }).forEach { user in
	print("user: \(user.name)")
}
