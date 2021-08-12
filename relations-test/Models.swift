import Foundation

struct ChatGroup: DelaType {
	let id: String
	var name: String
	var owner: DelaRef<ChatUser>
	var users: [DelaRef<ChatUser>]
	
	init(name: String, owner: ChatUser) {
		id = UUID().uuidString
		self.name = name
		self.owner = owner.ref
		users = []
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
