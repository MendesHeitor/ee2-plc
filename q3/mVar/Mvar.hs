import Control.Concurrent
import Control.Monad
import Data.Maybe

data Vaga = PCD | Comum deriving (Show, Eq)

data Carro = CarroPCD Int | CarroComum Int deriving (Show, Eq)

main :: IO ()
main = do
    putStrLn "Digite o número N de carros:"
    n <- readLn
    
    putStrLn "Digite o número K de vagas:"
    k <- readLn
    
    vagas <- newMVar (replicate (k `div` 10) PCD ++ replicate (9 * k `div` 10) Comum)
    
    threadCounter <- newMVar n 
    
    forM_ [1..n] $ \i -> do
        _ <- forkIO $ do
            if i <= n `div` 5 then
                monitorarCarro (CarroPCD i) vagas
            else
                monitorarCarro (CarroComum i) vagas
            modifyMVar_ threadCounter (return . subtract 1)
        return ()

    waitForThreads threadCounter

waitForThreads :: MVar Int -> IO ()
waitForThreads threadCounter = do
    remaining <- takeMVar threadCounter
    if remaining > 0 then do
        putMVar threadCounter remaining
        threadDelay 1000 
        waitForThreads threadCounter
    else
        return ()



monitorarCarro :: Carro -> MVar [Vaga] -> IO ()
monitorarCarro carro vagasMVar = do
    vagas <- takeMVar vagasMVar
    case carro of
        CarroPCD i -> do
            let (vagaOcupada, restante) = pegarVaga PCD vagas
            case vagaOcupada of
                Just vaga -> do
                    putMVar vagasMVar restante
                    putStrLn $ "Carro PCD " ++ show i ++ " pegou vaga " ++ show vaga
                    threadDelay 1500
                    putStrLn $ "Carro PCD " ++ show i ++ " liberou vaga " ++ show vaga
                    putMVar vagasMVar (vaga:restante)
                Nothing -> do
                    let (vagaOcupadaComum, restanteComum) = pegarVaga Comum vagas
                    case vagaOcupadaComum of
                        Just vagaComum -> do
                            putMVar vagasMVar restanteComum
                            putStrLn $ "Carro PCD " ++ show i ++ " pegou vaga " ++ show vagaComum
                            threadDelay 1500
                            putStrLn $ "Carro PCD " ++ show i ++ " liberou vaga " ++ show vagaComum
                            putMVar vagasMVar (vagaComum:restanteComum)
                        Nothing -> do
                            putMVar vagasMVar vagas
                            threadDelay 5000
                            monitorarCarro carro vagasMVar

        CarroComum i -> do
            let (vagaOcupada, restante) = pegarVaga Comum vagas
            case vagaOcupada of
                Just vaga -> do
                    putMVar vagasMVar restante
                    putStrLn $ "Carro comum " ++ show i ++ " pegou vaga " ++ show vaga
                    threadDelay 1000
                    putStrLn $ "Carro comum " ++ show i ++ " liberou vaga " ++ show vaga
                    putMVar vagasMVar (vaga:restante)
                Nothing -> do
                    putMVar vagasMVar vagas
                    threadDelay 5000
                    monitorarCarro carro vagasMVar
                    
pegarVaga :: Vaga -> [Vaga] -> (Maybe Vaga, [Vaga])
pegarVaga _ [] = (Nothing, [])
pegarVaga vaga (x:xs)
    | vaga == x = (Just x, xs)
    | otherwise = let (v, ys) = pegarVaga vaga xs in (v, x : ys)


printVar :: [Vaga] -> IO ()
printVar [] = return ()
printVar (x:xs) = do
    print x
    printVar xs