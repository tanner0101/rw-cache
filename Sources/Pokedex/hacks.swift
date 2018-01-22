import Vapor

/// HACKS

extension Future {
    public func map(_ callback: @escaping (Expectation) throws -> Expectation) -> Future<Expectation> {
        return map(to: Expectation.self, callback)
    }

    public func flatMap(_ callback: @escaping (Expectation) throws -> Future<Expectation>) -> Future<Expectation> {
        return flatMap(to: Expectation.self, callback)
    }
}

extension Request {
    public func make<Interface>(_ interface: Interface.Type = Interface.self) throws -> Interface {
        return try self.make(Interface.self, for: Request.self)
    }
}

