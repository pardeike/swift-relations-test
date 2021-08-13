import Foundation
import Combine

var database: [String: Data] = [:]

protocol DelaType: Codable, Hashable {
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
    static func ==<T: DelaType>(lhs: T, rhs: Self) -> Bool {
        if T.self != Self.self { return false }
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Array where Element: DelaType {
	var ref: [DelaRef<Element>] {
		return self.map(Element.toRef)
	}
}

extension Array {
    func deref<T>() -> [T?] where Element == DelaRef<T> {
        return map { $0.deref }
    }
    // add ALL methods on Array here, not only append
    mutating func append<T>(_ val: T) where Element == DelaRef<T> {
        append(val.ref)
    }
    func publisher<T>() -> RefArrayPublisher<T> where Element == DelaRef<T> {
        return RefArrayPublisher<T>(compactMap { $0.deref?.id })
    }
}

class RefPublisher<T: DelaType>: Publisher {
    typealias Output = T
    typealias Failure = Never
    
    let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, T == S.Input {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            guard let data = database[self.id] else { return }
            let decoder = JSONDecoder()
            if let item = try? decoder.decode(T.self, from: data) {
                _ = subscriber.receive(item)
            }
        }
    }
}

class RefArrayPublisher<T: DelaType>: Publisher {
    typealias Output = [T]
    typealias Failure = Never
    
    let ids: [String]
    
    init(_ ids: [String]) {
        self.ids = ids
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, [T] == S.Input {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let decoder = JSONDecoder()
            let items: [T] = self.ids.map { id in
                let data = database[id]!
                return try! decoder.decode(T.self, from: data)
            }
            _ = subscriber.receive(items)
        }
    }
}

struct DelaRef<T: DelaType>: Codable {
	private var id: String?
	private var _value: T?
	
	var deref: T? {
		if _value != nil { return _value }
		guard let ref = id else { return nil }
		guard let data = database[ref] else { return nil }
		let decoder = JSONDecoder()
		return try? decoder.decode(T.self, from: data)
	}
    
    var publisher: RefPublisher<T> {
        return RefPublisher<T>(id!)
    }
	
	init(_ value: T) {
		self.id = value.id
		self._value = value
	}
	
	init(id: String) {
        self.id = id
	}
	
	enum CodingKeys: String, CodingKey {
		case value = "id"
	}
	
    init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		id = try container.decode(String.self)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(id ?? deref?.id ?? "")
	}
}
