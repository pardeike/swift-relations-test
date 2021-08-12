import Foundation

var database: [String: Data] = [:]

protocol DelaType: Codable {
	var id: String { get }
}

extension DelaType {
	func save() -> Self {
		let encoder = JSONEncoder()
		database[id] = try! encoder.encode(self)
		return self
	}
	var ref: DelaRef<Self> {
		return DelaRef(self)
	}
	static func toRef<T>(_ item: T) -> DelaRef<T> {
		return item.ref
	}
}

extension Array where Element: DelaType {
	var ref: [DelaRef<Element>] {
		return self.map(Element.toRef)
	}
}

struct DelaRef<T: DelaType>: Codable {
	private var ref: String?
	private var _value: T?
	
	var deref: T? {
		if _value != nil { return _value }
		guard let ref = ref else { return nil }
		guard let data = database[ref] else { return nil }
		let decoder = JSONDecoder()
		return try? decoder.decode(T.self, from: data)
	}
	
	init(_ value: T) {
		self.ref = value.id
		self._value = value
	}
	
	init(id: String) {
		ref = id
	}
	
	enum CodingKeys: String, CodingKey {
		case value = "id"
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		ref = try container.decode(String.self)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(ref ?? deref?.id ?? "")
	}
}
