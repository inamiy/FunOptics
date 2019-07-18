/// infixr 9
precedencegroup ForwardCompositionPrecedence
{
    associativity: right
    higherThan: MultiplicationPrecedence
}

infix operator >>> : ForwardCompositionPrecedence
