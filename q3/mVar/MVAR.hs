import Control.Concurrent
import Control.Monad
import Data.Maybe
import Control.Concurrent.MVar
import Control.Concurrent (threadDelay)

data Vaga = PCD | Comum deriving (Show, Eq)
data Carro = CarroPCD Int | CarroComum Int deriving (Show, Eq)


waitThreads :: MVar Int -> IO ()
waitThreads fim = 
  do f <- takeMVar fim
     if (f > 0) then
         do putMVar fim f
            waitThreads fim
       else 
           return ()

pegarVaga :: Vaga -> [Vaga] -> (Maybe Vaga, [Vaga])
pegarVaga _ [] = (Nothing, [])
pegarVaga vaga (x:xs)
    | (vaga == PCD) || (vaga == x) = (Just x, xs)
    | otherwise = let (v, ys) = pegarVaga vaga xs in (v, x : ys)


processarCarro :: MVar [Vaga] -> Carro -> IO ()
processarCarro vagasMVar carro = do
    vagas <- takeMVar vagasMVar 

    case carro of
        CarroPCD i -> do
            putStrLn "Carro PCD: Realizar processamento específico para PCD"
            putMVar vagasMVar vagas

        CarroComum i -> do
            (vaga, vagasAtualizadas) <- pegarVaga Comum vagas
            case vaga of
                Just vaga -> do
                    putMVar vagasMVar vagasAtualizadas
                    putStrLn $ "Carro comum " ++ show i ++ " pegou vaga " ++ show vaga
                    threadDelay 1000
                    putStrLn $ "Carro comum " ++ show i ++ " liberou vaga " ++ show vaga
                    vagas <- takeMVar vagasMVar
                    putMVar vagasMVar (vaga:vagas)
                Nothing -> do
                    putMVar vagasMVar vagas
                    threadDelay 1000
                    processarCarro vagasMVar carro
           








main :: IO ()
main = do

    putStrLn "Digite o número N de carros:"
    n <- readLn

    putStrLn "Digite o número K de vagas:"
    k <- readLn
    
    vagas <- newMVar (replicate (k `div` 10) PCD ++ replicate (9 * k `div` 10) Comum)

    fim <- newMVar n

    forM_ [1..n] $ \i ->
        if i <= n `div` 5 then
            forkIO (monitorarCarro (CarroPCD i) vagas)
        else
            forkIO (monitorarCarro (CarroComum i) vagas)

    waitThreads fim
    