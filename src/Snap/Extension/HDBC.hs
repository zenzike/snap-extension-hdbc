{-|

'Snap.Extension.HDBC' exports the 'MonadHDBC' interface which allows you to
integerate HDBC connections with your Snap application.
The different implementations of this interface are used for specific
HDBC backends, such as Sqlite3, PostgreSQL, ODBC, and MySQL.
Each of these has a different 'hdbcInitializer'.

-}

module Snap.Extension.HDBC
  ( MonadHDBC ( .. )
  , HDBCState ( HDBCState )
  , HasHDBCState ( .. )
  ) where

import Control.Monad.Trans.Reader ( ReaderT )
import Control.Monad.Reader       ( asks )

import Database.HDBC ( ConnWrapper (..), disconnect )

import Snap.Types     ( MonadSnap )
import Snap.Extension ( SnapExtend, InitializerState(..), Initializer, mkInitializer )

------------------------------------------------------------------------------
-- | The 'MonadHDBC' type class.
-- This provides a 'ConnWrapper' which can be used for database querying.
class (MonadSnap m) => MonadHDBC m where
  -- | The database connection that was established when your application was
  -- started.
  connWrapper :: m ConnWrapper

-----------------------------------------------------------------------------
newtype HDBCState = HDBCState
  { _connWrapper :: ConnWrapper
  }

-- | An application that 'HasHDBCState' is a 'MonadHDBC' whose state
-- supports a connection supplied by HDBC.
class HasHDBCState s where
  getHDBCState :: s -> HDBCState
  setHDBCState :: HDBCState-> s -> s

instance HasHDBCState s => MonadHDBC (SnapExtend s) where
  connWrapper = fmap _connWrapper $ asks getHDBCState

instance (MonadSnap m, HasHDBCState s) => MonadHDBC (ReaderT s m) where
  connWrapper = fmap _connWrapper $ asks getHDBCState

instance InitializerState HDBCState where
  extensionId = const "HDBC/HDBC"
  mkCleanup   = disconnect . _connWrapper
  mkReload    = const $ return ()
