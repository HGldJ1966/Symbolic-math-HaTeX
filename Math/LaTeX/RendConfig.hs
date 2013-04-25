-- |
-- Module      : Math.LaTeX.RendConfig
-- Copyright   : (c) Justus Sagemüller 2013
-- License     : GPL v3
-- 
-- Maintainer  : (@) sagemuej $ smail.uni-koeln.de
-- Stability   : experimental
-- Portability : requires GHC>6 extensions
-- 



module Math.LaTeX.RendConfig where



import Control.Applicative
import Control.Monad.Reader
import Control.Monad.Identity

import Data.List
import Data.Function
import Data.String

type TeXMathConfiguration = ()