import Control.Concurrent
import Text.Printf

-- Máquina de refrigerante
maquina :: MVar Int -> Int -> String -> MVar Int -> MVar Bool -> IO ()
maquina idCliente totalClientes idRefri refri disponivel
  = do
    ocupado <- takeMVar disponivel
    novoCliente <- takeMVar idCliente
    if novoCliente <= totalClientes then
      do
        novoRefri <- takeMVar refri
        threadDelay 1000000 -- Tempo necessário para encher um copo
        putMVar refri (novoRefri - 300) -- Reduz o volume total do refrigerante no volume do copo tirado
        printf "O cliente %d do refrigerante %s está enchendo seu copo!\n" novoCliente idRefri
        putMVar disponivel ocupado
        putMVar idCliente (novoCliente + 1)
        maquina idCliente totalClientes idRefri refri disponivel
    else
      do
        putMVar disponivel ocupado
        putMVar idCliente novoCliente

-- Reabastecimento da máquina
refill :: String -> MVar Int -> MVar Bool -> IO ()
refill idRefri refri disponivel
  = do
    ocupado <- takeMVar disponivel
    novoRefri <- takeMVar refri
    if novoRefri < 1000 then -- Verifica se é necessário realizar o reabastecimento
      do
        threadDelay 1500000 -- Tempo necessário para fazer o reabastecimento
        putMVar refri (novoRefri + 1000) -- Realiza o reabastecimento e atualiza o volume do refrigerante
        novoRefri <- takeMVar refri
        printf "Pausa para abastecer!\n"
        printf "O refrigerante %s foi reabastecido com 1000 ml, e agora possui %d ml!\n" idRefri novoRefri
        putMVar refri novoRefri
    else
      do
        putMVar refri novoRefri
    putMVar disponivel ocupado
    refill idRefri refri disponivel

main :: IO ()
main
  = do
    refriCola <- newMVar 2000
    refriPolo <- newMVar 2000
    refriQuate <- newMVar 2000

    idCliente <- newMVar 1

    -- mantive uma quantidade fixa mesmo
    let totalClientes = 30

    disponivel <- newMVar True


    forkIO (maquina idCliente totalClientes "Refri Cola" refriCola disponivel)
    forkIO (refill "Refri Cola" refriCola disponivel)

    forkIO (maquina idCliente totalClientes "Guaraná Polo Norte" refriPolo disponivel)
    forkIO (refill "Guaraná Polo Norte" refriPolo disponivel)

    forkIO (maquina idCliente totalClientes "Guaraná Quate" refriQuate disponivel)
    forkIO (refill "Guaraná Quate" refriQuate disponivel)
    
    return ()