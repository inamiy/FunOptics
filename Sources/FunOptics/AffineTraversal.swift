/// An optic focused on zero or one target.
///
/// - Note: This type is equivalent to Scala Monocle's `Optional`.
///
/// - SeeAlso:
///   - https://broomburgo.github.io/fun-ios/post/lenses-and-prisms-in-swift-a-pragmatic-approach/
///   - http://oleg.fi/gists/posts/2017-03-20-affine-traversal.html
///   - https://julien-truffaut.github.io/Monocle/optics/optional.html
public struct AffineTraversal<Whole, Part>
{
    let tryGet: (Whole) -> Part?
    let setter: (Whole, Part) -> Whole

    init(tryGet: @escaping (Whole) -> Part?, setter: @escaping (Whole, Part) -> Whole)
    {
        self.tryGet = tryGet
        self.setter = setter
    }

    init(lens: Lens<Whole, Part>)
    {
        self.init(tryGet: lens.get, setter: lens.set)
    }

    init(prism: Prism<Whole, Part>)
    {
        self.init(tryGet: prism.tryGet, setter: { prism.inject($1) })
    }
}

extension AffineTraversal
{
    public static func >>> <Part2>(l: AffineTraversal<Whole, Part>, r: AffineTraversal<Part, Part2>) -> AffineTraversal<Whole, Part2>
    {
        return AffineTraversal<Whole, Part2>(
            tryGet: { whole -> Part2? in
                l.tryGet(whole).flatMap { r.tryGet($0) }
            },
            setter: { whole, part2 -> Whole in
                if let part = l.tryGet(whole) {
                    return l.setter(whole, r.setter(part, part2))
                }
                else {
                    return whole
                }
            }
        )
    }
}

public func >>> <Whole, Part, Part2>(l: Lens<Whole, Part>, r: Prism<Part, Part2>) -> AffineTraversal<Whole, Part2>
{
    return .init(lens: l) >>> .init(prism: r)
}

public func >>> <Whole, Part, Part2>(l: Prism<Whole, Part>, r: Lens<Part, Part2>) -> AffineTraversal<Whole, Part2>
{
    return .init(prism: l) >>> .init(lens: r)
}

public func >>> <Whole, Part, Part2>(l: Lens<Whole, Part>, r: AffineTraversal<Part, Part2>) -> AffineTraversal<Whole, Part2>
{
    return .init(lens: l) >>> r
}

public func >>> <Whole, Part, Part2>(l: AffineTraversal<Whole, Part>, r: Lens<Part, Part2>) -> AffineTraversal<Whole, Part2>
{
    return l >>> .init(lens: r)
}

public func >>> <Whole, Part, Part2>(l: Prism<Whole, Part>, r: AffineTraversal<Part, Part2>) -> AffineTraversal<Whole, Part2>
{
    return .init(prism: l) >>> r
}

public func >>> <Whole, Part, Part2>(l: AffineTraversal<Whole, Part>, r: Prism<Part, Part2>) -> AffineTraversal<Whole, Part2>
{
    return l >>> .init(prism: r)
}
