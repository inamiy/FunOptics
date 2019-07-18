/// An optic used to select part of a sum-type.
public struct Prism<Whole, Part>
{
    public let tryGet: (Whole) -> Part?
    public let inject: (Part) -> Whole

    public init(
        tryGet: @escaping (Whole) -> Part?,
        inject: @escaping (Part) -> Whole
    )
    {
        self.tryGet = tryGet
        self.inject = inject
    }

    public static func >>> <Part2>(l: Prism<Whole, Part>, r: Prism<Part, Part2>) -> Prism<Whole, Part2>
    {
        return Prism<Whole, Part2>(
            tryGet: { a in l.tryGet(a).flatMap(r.tryGet) },
            inject: { a in l.inject(r.inject(a)) }
        )
    }
}

public func some<A>() -> Prism<A?, A>
{
    return Prism<A?, A>.init(tryGet: { $0 }, inject: { $0 })
}

public func none<A>() -> Prism<A?, ()>
{
    return Prism<A?, ()>.init(
        tryGet: {
            switch $0 {
            case .none: return ()
            case .some: return .none
            }
        },
        inject: { .none }
    )
}
