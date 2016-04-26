import Distribution.Simple
import Distribution.PackageDescription
import qualified System.Process as P

hooks =
  simpleUserHooks { buildHook = b, preInst=i }
 where
  b _ _ _ _ = P.callCommand "make"
  i _ _ = do
    P.callCommand "make pre-install"
    return emptyHookedBuildInfo

main = defaultMainWithHooks hooks
