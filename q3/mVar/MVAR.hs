-- Importando módulos necessários para concorrência e funções utilitárias
import Control.Concurrent
import Control.Monad
import Data.Maybe

-- Definindo um tipo `Vaga` que pode ser PCD ou Comum
data Vaga = PCD | Comum deriving (Show, Eq)

-- Definindo um tipo `Carro` que pode ser um CarroPCD com um identificador ou um CarroComum com um identificador
data Carro = CarroPCD Int | CarroComum Int deriving (Show, Eq)

-- Função principal do programa
main :: IO ()
main = do
    -- Solicita ao usuário o número de carros e lê o input
    putStrLn "Digite o número N de carros:"
    n <- readLn
    
    -- Solicita ao usuário o número de vagas e lê o input
    putStrLn "Digite o número K de vagas:"
    k <- readLn
    
    -- Cria um MVar (variável mutável) contendo a lista de vagas, sendo 10% PCD e o resto Comum
    vagas <- newMVar (replicate (k `div` 10) PCD ++ replicate (9 * k `div` 10) Comum)
    
    threadCounter <- newMVar n 
    
    -- Para cada carro, se for PCD (20% primeiros carros), inicia uma thread para monitorar esse carro em uma vaga PCD.
    -- Senão, inicia uma thread para monitorar esse carro em uma vaga comum.
    forM_ [1..n] $ \i -> do
        _ <- forkIO $ do
            if i <= n `div` 5 then
                monitorarCarro (CarroPCD i) vagas
            else
                monitorarCarro (CarroComum i) vagas
            modifyMVar_ threadCounter (return . subtract 1)
        return ()

    waitForThreads threadCounter

-- Espera até que todas as threads tenham concluído
waitForThreads :: MVar Int -> IO ()
waitForThreads threadCounter = do
    remaining <- takeMVar threadCounter
    if remaining > 0 then do
        putMVar threadCounter remaining
        threadDelay 1000 -- espera 0,1 segundo antes de verificar novamente
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
                    
-- Função auxiliar para pegar uma vaga da lista e retornar essa vaga junto com a lista restante
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