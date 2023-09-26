import Control.Concurrent
import Control.Concurrent.Chan
import Control.Monad

sender :: Chan String -> Int -> IO ()
sender channel n = replicateM_ n $ do
    writeChan channel "Ping"
    putStrLn "Sent: Ping"

receiver :: Chan String -> Int -> IO ()
receiver channel n = replicateM_ n $ do
    msg <- readChan channel
    putStrLn ("Received: " ++ msg)

main :: IO ()
main = do
    putStrLn "Digite valor de N:"
    n <- readLn

    channel <- newChan

    forkIO (sender channel n)
    forkIO (receiver channel n)
    
    threadDelay (n * 100000)
