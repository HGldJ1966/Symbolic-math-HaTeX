-- |
-- Module      : Math.LaTeX.VoidCalc
-- Copyright   : (c) Justus Sagemüller 2013
-- License     : GPL v3
-- 
-- Maintainer  : (@) sagemuej $ smail.uni-koeln.de
-- Stability   : experimental
-- Portability : requires GHC>6 extensions
-- 
{-# LANGUAGE OverloadedStrings                #-}
{-# LANGUAGE GADTs                            #-}
{-# LANGUAGE ScopedTypeVariables              #-}
{-# LANGUAGE MultiParamTypeClasses            #-}
{-# LANGUAGE FlexibleInstances                #-}
{-# LANGUAGE UndecidableInstances             #-}
{-# LANGUAGE OverlappingInstances             #-}
{-# LANGUAGE PatternGuards                    #-}
{-# LANGUAGE TypeFamilies                     #-}
{-# LANGUAGE RecordWildCards                  #-}


module Math.LaTeX.VoidCalc where


import Math.LaTeX.Prelude
import Math.LaTeX.Internal.MathExpr
import Math.LaTeX.Internal.RendMonad


import Text.LaTeX.Base
import Text.LaTeX.Base.Class
import Text.LaTeX.Base.Syntax
import qualified Text.LaTeX.Packages.AMSMath as AMS
import qualified Data.Text as T

import Control.Applicative
import Control.Monad
import Control.Monad.Reader
import Control.Monad.Identity

import Data.Void

import Data.List
import Data.HList
import Data.Foldable
import Data.Function
import Data.Functor.FixedLength
import Data.Ratio
import Data.Functor.Contravariant
import Data.String

import Data.Complex(Complex(..))



-- | Base type for mathematical expressions that cannot be calculated
-- by this library, but can still be typeset via LaTeX. Note that
-- the expression's result type is still well-defined, the 'Void'
-- represents the unobtainable arguments that would be required
-- to calculate it.
type MathHard a = MathLaTeXEval a Void


class IsVoid v where
  absurdV :: v -> a
  absurdV l = l `seq` undefined
-- Overlapping instances are safe here since all possible implementations
-- of this function are equivalent anyway, provided the type does
-- indeed not have any constructors.

instance IsVoid Void where
  absurdV = absurd

instance IsVoid (HCons Void l)

instance (IsVoid l) => IsVoid (HCons e l)


-- | A variable nothing is known about, safe for its supposed return type.
unknown :: IsVoid arg => MathPrimtvId -> MathLaTeXEval r arg
unknown = mathDepPrimitiv absurdV

muteFunction :: IsVoid arg
     => (LaTeX -> LaTeX) -> MathLaTeXEval r arg -> MathEvaluation r arg
muteFunction fn e = MathEnvd ( \(Identity _) -> absurdV )
                             ( fn . runIdentity )
                             ( Identity $ contramap hHead e )
 
muteFn :: IsVoid arg => LaTeX -> MathLaTeXEval r arg -> MathLaTeXEval r arg
muteFn fn e@(MathLaTeXEval _ fxty)
   = mathCompound_wFixity (muteFunction funnamer e) $ Infix 9
 where funnamer incl
         | isotropFixity fxty <= 9   = fn <> braces (AMS.autoParens incl)
         | otherwise                 = fn <> commS":" <> braces incl


type NaiveInfReal = Double
type PseudoReal = Double
type PseudoComplex = Complex Double

class InfReal r where
  infty :: r

instance InfReal NaiveInfReal where
  infty = 1/0

instance (InfReal r) => InfReal(MathLaTeXEval r arg) where
  infty = mathPrimitiv infty AMS.infty
  

inline :: Monad m => MathHard b -> MathematicalLaTeXT m ()
inline = liftM (const ()) . inlineMathExpr

display :: Monad m => MathHard b -> MathematicalLaTeXT m ()
display = liftM (const ()) . displayMathExpr

inlinePrTypeAs, displayPrTypeAs :: Monad m => b -> MathHard b -> MathematicalLaTeXT m ()
inlinePrTypeAs = const inline; displayPrTypeAs = const display

inlineIntegerExpr, displayIntegerExpr :: Monad m => MathHard Integer -> MathematicalLaTeXT m ()
displayIntegerExpr = display; inlineIntegerExpr = inline

inlineRealExpr, displayRealExpr :: Monad m => MathHard PseudoReal -> MathematicalLaTeXT m ()
displayRealExpr = display; inlineRealExpr = inline

inlineComplexExpr, displayComplexExpr :: Monad m => MathHard PseudoComplex -> MathematicalLaTeXT m ()
displayComplexExpr = display; inlineComplexExpr = inline
