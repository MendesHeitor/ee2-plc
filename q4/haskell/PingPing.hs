import Control.Concurrent.MVar
import Control.Concurrent
import Control.Monad
import System.IO

-- Agora o waitThread irá esperar uma única thread terminar.
waitThread :: MVar () -> IO ()
waitThread = takeMVar

sender :: MVar String -> Int -> IO ()
sender queue n =
    forM_ [1..n] $ \i -> do
        putMVar queue "Ping"
        putStrLn "Sent: Ping"
        threadDelay 2

receiver :: MVar String -> Int -> IO ()
receiver queue n =
    forM_ [1..n] $ \i -> do
        msg <- takeMVar queue
        putStrLn ("Received: " ++ msg)
        threadDelay 2

main :: IO ()
main = do
    queue <- newEmptyMVar

    putStrLn "Digite valor de N:"
    n <- readLn

    -- Criamos as barreiras para sinalizar quando as threads terminam
    senderDone <- newEmptyMVar
    receiverDone <- newEmptyMVar

    forkIO (sender queue n >> putMVar senderDone ())    -- Quando a thread 'sender' terminar, ela sinaliza
    forkIO (receiver queue n >> putMVar receiverDone ()) -- Quando a thread 'receiver' terminar, ela sinaliza

    -- Espera ambas as threads terminarem
    waitThread senderDone
    waitThread receiverDone
