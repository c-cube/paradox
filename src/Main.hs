module Main where

{-
Paradox/Equinox -- Copyright (c) 2003-2007, Koen Claessen, Niklas Sorensson

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
-}

import Form
import Control.Concurrent
import Control.Exception
import System.Exit
import Flags
import ParseProblem
import Clausify
import System.IO( hSetBuffering, stdout, BufferMode(..) )

import Output

---------------------------------------------------------------------------
-- main

mainGen :: Tool -> (Flags -> [Clause] -> [Clause] -> IO ClauseAnswer) -> IO ()
mainGen tool solveProblem =
  do hSetBuffering stdout LineBuffering
     flags <- getFlags tool

     problems <- (case filelist flags of
       Nothing      -> return []
       Just flist   -> do
        s <- readFile flist
        return $ lines s)

     let flags' = flags{ files = files flags ++ problems }

     case time flags' of
       Just n ->
         do timeoutVar <- newEmptyMVar

            pid1 <- forkIO $
              do try (main' flags solveProblem) :: IO (Either IOError ())
                 putMVar timeoutVar False

            pid2 <- forkIO $
              do threadDelay (1000000 * n)
                 putMVar timeoutVar True

            timeout <- takeMVar timeoutVar
            if timeout
              then do killThread pid1
                      putInfo ""
                      putWarning ("TIMEOUT (" ++ show n ++ " seconds)")
                      let flags'' = flags'{ thisFile = unwords (files flags') }
                      putResult flags'' (show Timeout)
              else do killThread pid2

       Nothing ->
         do main' flags' solveProblem

main' :: Flags -> (Flags -> [Clause] -> [Clause] -> IO ClauseAnswer) -> IO ()
main' flags solveProblem =
  do require (not (null (files flags))) $
       putWarning "No input files specified! Try --help."

     sequence_
       [ do putOfficial ("PROBLEM: " ++ file)
            ins <- readProblemWithRoots ("" : map (++"/") (roots flags)) file
            --putStrLn "--> inputs"
            --print (length ins, ins == ins)
            --sequence_ [ print inp | inp <- ins ]
            let (theory,obligs) = clausify flags ins
                n               = length obligs
            let flags'          = flags{ thisFile = file }
            --sequence_ [ print t | t <- theory ]

            putOfficial ("SOLVING: " ++ file)
            case obligs of
              -- Satisfiable/Unsatisfiable
              [] ->
                do ans <- solveProblem flags' theory []
                   putResult flags' (show ans)

              -- CounterSatisfiable/Theorem
              [oblig] ->
                do ans <- solveProblem flags' theory oblig
                   putResult flags' (show (toConjectureAnswer ans))

              -- Unknown/Theorem
              obligs ->
                do let solveAll i [] =
                         do return Theorem

                       solveAll i (oblig:obligs) =
                         do putSubHeader ("Part " ++ show i ++ "/" ++ show n)
                            ans <- solveProblem flags' theory oblig
                            putOfficial ("PARTIAL (" ++ show i ++ "/" ++ show n ++ "): " ++ show (toConjectureAnswer ans))
                            case ans of
                              Unsatisfiable -> solveAll (i+1) obligs
                              _             -> return (NoAnswerConjecture GaveUp)

                   ans <- solveAll 1 obligs
                   putResult flags' (show ans)
       | file <- files flags
       ]

require :: Bool -> IO () -> IO ()
require False m = do m; exitWith (ExitFailure 1)
require True  m = do return ()

---------------------------------------------------------------------------
-- the end.




