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
    public let tryGet: (Whole) -> Part?
    public let set: (Whole, Part) -> Whole

    public init(
        tryGet: @escaping (Whole) -> Part?,
        set: @escaping (Whole, Part) -> Whole
    )
    {
        self.tryGet = tryGet
        self.set = set
    }

    public init(lens: Lens<Whole, Part>)
    {
        self.init(tryGet: lens.get, set: lens.set)
    }

    public init(prism: Prism<Whole, Part>)
    {
        self.init(tryGet: prism.tryGet, set: { prism.inject($1) })
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
            set: { whole, part2 -> Whole in
                if let part = l.tryGet(whole) {
                    return l.set(whole, r.set(part, part2))
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

// MARK: - Enum-property to AffineTraversal

extension AffineTraversal
{
    /// Makes `AffineTraversal` from enum-property (enum case's computed get-set property).
    ///
    /// ## Example
    ///
    /// ```
    /// struct EnumState {
    ///     case pattern1(Int)
    ///     ...
    ///
    ///     var pattern1: Int? { // Enum computed get-set property.
    ///         get {
    ///             guard case let .pattern1(value) = self else { return nil }
    ///             return value
    ///         }
    ///         set {
    ///             guard case .pattern1 = self, let newValue = newValue else { return }
    ///             self = .pattern1(newValue)
    ///         }
    ///     }
    /// }
    ///
    /// let affineTraversal: AffineTraversal<EnumState, Int> = fromEnumProperty(\EnumState.pattern1)
    /// ```
    ///
    /// - SeeAlso: https://github.com/pointfreeco/swift-enum-properties
    ///
    /// - Note: This is a workaround of Swift that is not able to create `Prism` from KeyPath syntax.
    public static func fromEnum(_ keyPath: WritableKeyPath<Whole, Part?>) -> AffineTraversal<Whole, Part>
    {
        .init(
            tryGet: { $0[keyPath: keyPath] },
            set: { whole, part in
                var whole = whole
                whole[keyPath: keyPath] = part
                return whole
            }
        )
    }
}

@available(*, deprecated, renamed: "AffineTraversal.fromEnum(_:)")
public func fromEnumProperty<Whole, Part>(
    _ keyPath: WritableKeyPath<Whole, Part?>
) -> AffineTraversal<Whole, Part>
{
    .fromEnum(keyPath)
}
