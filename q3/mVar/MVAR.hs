import Control.Concurrent
import Control.Monad
import Data.Maybe
import Control.Concurrent.MVar
import Control.Concurrent (threadDelay)

data Vaga = PCD | Comum deriving (Show, Eq)
data Carro = CarroPCD Int | CarroComum Int deriving (Show, Eq)

pegarVaga :: Vaga -> [Vaga] -> (Maybe Vaga, [Vaga])
pegarVaga _ [] = (Nothing, [])
pegarVaga vaga (x:xs)
    | (vaga == PCD) || (vaga == x) = (Just x, xs)
    | otherwise = let (v, ys) = pegarVaga vaga xs in (v, x : ys)


monitorarCarro :: MVar [Vaga] -> Carro -> IO ()
monitorarCarro vagasMVar carro = do
    vagas <- takeMVar vagasMVar 

    case carro of
        CarroPCD i -> do
            let (mVaga, vagasAtualizadas) = pegarVaga PCD vagas
            case mVaga of
                Just obtainedVaga -> do
                    case obtainedVaga of
                        PCD -> do
                            putMVar vagasMVar vagasAtualizadas
                            putStrLn $ "Carro PCD " ++ show i ++ " pegou vaga " ++ show obtainedVaga
                            threadDelay 1000
                            putStrLn $ "Carro PCD " ++ show i ++ " liberou vaga " ++ show obtainedVaga
                            vagas <- takeMVar vagasMVar
                            putMVar vagasMVar (obtainedVaga:vagas)
                        Comum -> do
                            putMVar vagasMVar vagasAtualizadas
                            putStrLn $ "Carro PCD " ++ show i ++ " pegou vaga " ++ show obtainedVaga
                            threadDelay 1500
                            putStrLn $ "Carro PCD " ++ show i ++ " liberou vaga " ++ show obtainedVaga
                            vagas <- takeMVar vagasMVar
                            putMVar vagasMVar (obtainedVaga:vagas)
                Nothing -> do
                    putMVar vagasMVar vagas
                    monitorarCarro vagasMVar carro

        CarroComum i -> do
            let (mVaga, vagasAtualizadas) = pegarVaga Comum vagas
            case mVaga of
                Just obtainedVaga -> do
                    putMVar vagasMVar vagasAtualizadas
                    putStrLn $ "Carro comum " ++ show i ++ " pegou vaga " ++ show obtainedVaga
                    threadDelay 1000
                    putStrLn $ "Carro comum " ++ show i ++ " liberou vaga " ++ show obtainedVaga
                    vagas <- takeMVar vagasMVar
                    putMVar vagasMVar (obtainedVaga:vagas)
                Nothing -> do
                    putMVar vagasMVar vagas
                    monitorarCarro vagasMVar carro

           
main :: IO ()
main = do

    putStrLn "Digite o número N de carros:"
    n <- readLn

    putStrLn "Digite o número K de vagas:"
    k <- readLn

    let vagasPCD = k `div` 10
    let vagasComum = k - vagasPCD
    
    vagas <- newMVar (replicate vagasPCD PCD ++ replicate vagasComum Comum)

    forM_ [1..n] $ \i ->
        if i <= n `div` 5 then
            forkIO (monitorarCarro vagas (CarroPCD i))
        else
            forkIO (monitorarCarro vagas (CarroComum i))

    threadDelay (n * 1000000)