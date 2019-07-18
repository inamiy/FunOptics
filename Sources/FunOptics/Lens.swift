/// Functional getter & seter.
/// An optic used to zoom inside a product-type.
public struct Lens<Whole, Part>
{
    public let get: (Whole) -> Part
    public let set: (Whole, Part) -> Whole

    public init(
        get: @escaping (Whole) -> Part,
        set: @escaping (Whole, Part) -> Whole
    )
    {
        self.get = get
        self.set = set
    }

    public static func >>> <Part2>(l: Lens<Whole, Part>, r: Lens<Part, Part2>) -> Lens<Whole, Part2>
    {
        return Lens<Whole, Part2>(
            get: { r.get(l.get($0)) },
            set: { a, c in l.set(a, r.set(l.get(a), c)) }
        )
    }
}
