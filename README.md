Snap Extension for HDBC
=======================

This package provides an HDBC connection that can be used as part
of the state in a Snap application.

This API is currently a work in progress, and should not be considered stable.

In order to use an HDBC connection, you may want to use one of the following
packages which simply export the appropriate initializers:

* [snap-extension-hdbc-odbc](https://github.com/zenzike/snap-extension-hdbc-odbc)
* [snap-extension-hdbc-postgresql](https://github.com/zenzike/snap-extension-hdbc-postgresql)
* [snap-extension-hdbc-sqlite3](https://github.com/zenzike/snap-extension-hdbc-sqlite3)

Example
-------

If you want to use this as part of your Snap application, you should
change your 'ApplicationState' to contain the 'HDBCState', the following
will be typically placed in the 'Application.hs' file:

~~~~
type Application = SnapExtend ApplicationState


data ApplicationState = ApplicationState
    { hdbcState     :: HDBCState
    }
~~~~

In addition, you should provide an instance of HasHDBCState for your
application:

~~~~
instance HasHDBCState ApplicationState where
  getHDBCState     = hdbcState
  setHDBCState s a = a { hdbcState = s }
~~~~

Finally, you should tell Snap how to initialize your state. This part is
specific to the backend implementation you are using, where
the type of 'hdbcInitializer' depends on the package you have imported.
For example, iff you have imported 'Snap.Extension.HDBC.Sqlite3' then
you could set things up with the following code:

~~~~
applicationInitializer :: Initializer ApplicationState
applicationInitializer = do
    hdbc <- hdbcInitializer "resources/test1.db"
    return $ ApplicationState hdbc
~~~~

The following code shows how you can access a connection to your
database using the 'connWrapper' function that is exported from
this package:

~~~~
type Application = SnapExtend ApplicationState

indexR :: Application ()
indexR = ifTop $ do
  conn <- connWrapper
  as <- liftIO $ liftM (map fst) $ describeTable conn "users"
  ts <- liftIO $ liftM (map (map fromSql)) $ quickQuery' conn "SELECT * FROM users" []
  ...
~~~~
