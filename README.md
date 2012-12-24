This is an attempt to get convenient math syntax in [HaTeX](https://github.com/Daniel-Diaz/HaTeX).

The idea is to combine these features:

- Full access to the math-typesetting power of LaTeX. It should be possible to express any formula that might be found in a typical mathematics or physics journal article. This should also include expression which are not quite well-defined from a programming point of view, but are clear to the intended audience.
- Idiomatic Haskell syntax. Who wants to bother with unreadable expressions involving either hundreds of double-backslashes or extra syntax overhead in wrapping them explicitly into HaTeX?
Ideally, one would write expressions as if only meaning Haskell to _calculate_ them, but get the result back as a full pretty-printing LaTeX math string. _And the actual calculated result as well_, if possible!

For very simple expressions (plain number arithmetic with either literals or predefined variables) this already works quite nicely, see the example given (result in `shorttest0/shorttest0.pdf`).
Where it gets interesting is when there are actual variables around, like an integral `∫ dx f(x)`. There is a bit of a conflict here: in Haskell, one would like to see such a thing as a (in principle point-free) operation on a lambda function, whereas most mathematicians and particularly physicists rather think of the `f(x)` as some kind of _term_ that happens to include the `x` symbol.

The solution I propose works thus:

- A mathematical expression `e` which depends on a variable of type `Arg` so the result represents a value of type `Res`, has type `MathEvaluation Res Arg` (notice the different order of the type arguments, compared to Haskell functions (or categories, arrows...) `(->) Arg Res`).
- In the simplest case, such an expression does indeed just represent a Haskell function `f :: Arg -> Res` that a mathematician would simply denote `f(x)`.
- _In general_, the symbolic term that `e` displays in the LaTeX output will not be an exact description of the function `f`. It will rather be _some way to write the result of 'f'_, given some kind of transformation from `Arg` to a number of variables that appear in the expression. To keep to the integral example: in physics, one very often writes things such as `∫ dr f(φ) ⋅ g(z)`, meaning in fact an integral over the `ℝ³` space `∫ dr f(atan₂(r₁,r₂)) ⋅ g(r₃)`, but assuming this transformation is obvious to the reader.

This ability to map over the _input_ makes `MathEvaluation Res` a [contravariant functor](http://hackage.haskell.org/packages/archive/contravariant/0.2.0.2/doc/html/Data-Functor-Contravariant.html), and indeed it has been made an instance of that class.
Of course, this means there is no guarantee that the Haskell function will actually be equivalent to the "obvious" interpretation of the LaTeX output, but I doubt it's possible to achieve this while still giving enough freedom to write expressions that won't look overly clumsy.

Whether this appoach actually works as desired for real maths and physics applications has yet to be shown.
