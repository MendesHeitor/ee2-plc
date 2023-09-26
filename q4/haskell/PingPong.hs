import Control.Concurrent.MVar
import Control.Concurrent
import Control.Monad
import System.IO


sender :: MVar String -> Int -> IO ()
sender queue n =
    forM_ [1..n] $ \i -> do
        putMVar queue " Pong!"
        putStrLn "Ping!"
        threadDelay 2

receiver :: MVar String -> Int -> IO ()
receiver queue n =
    forM_ [1..n] $ \i -> do
        msg <- takeMVar queue
        putStrLn (msg)
        threadDelay 2

main :: IO ()
main = do
    queue <- newEmptyMVar

    putStrLn "Digite valor de N:"
    n <- readLn

    senderDone <- newEmptyMVar
    receiverDone <- newEmptyMVar

    forkIO (sender queue n)
    forkIO (receiver queue n)

    threadDelay (n * 100000)
