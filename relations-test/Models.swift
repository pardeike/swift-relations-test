import Foundation

struct ChatGroup: DelaType, Hashable {
    
    let id: String
	var name: String
    var admin: ChatUser
	var owner: DelaRef<ChatUser>
	var users: [DelaRef<ChatUser>]
    var props1: [String: DelaRef<ChatProp>]
	
	init(name: String, owner: ChatUser) {
		id = UUID().uuidString
		self.name = name
        self.admin = ChatUser(name: "ADMIN")
		self.owner = owner.ref
		users = []
        props1 = [
            "foo": ChatProp(name: "foo").save().ref,
            "bar": ChatProp(name: "bar").save().ref
        ]
	}
    
    mutating func addUser(_ user: ChatUser) {
        users.append(user.ref)
    }
}

struct ChatUser: DelaType {
	let id: String
	var name: String
	
	init(name: String) {
		id = UUID().uuidString
		self.name = name
	}
}

struct ChatProp: DelaType {
    let id: String
    var name: String
    
    init(name: String) {
        id = UUID().uuidString
        self.name = name
    }
}
