{-| 
Modulo : Main

Descrição : Módulo que executa um nível do jogo LightBot

Este programa recebe um ficheiro correspondente a um nível de LightBot e executa todos os seus comandos, imprimindo mensagens de acordo com os objetivos
do jogo.
-}

module Main where

import Data.Char
import Data.List

type Tabuleiro = [String]
-- ^ Tipo usado para representar tabuleiros. Cada linha do tabuleiro é composto por um conjunto de carateres.
type Posicao = String
-- ^ Tipo usado para representar a posição do Robot. Uma posição válida deverá apresentar a seguinte estrutura /@x y ori@/.
type Comandos = String
-- ^ Tipo usado para representar uma linha de comandos. Cada comando é associado a um carater.
type Lampada = (Int,Int)
-- ^ Tipo usado para representar uma lâmpada. A cada lâmpada está associada a sua posição (x,y) no tabuleiro.
type Nivel = Char
-- ^ Tipo usado para representar o nível de uma dada posição do tabuleiro.
type Jogadas = Int
-- ^ Tipo usado para reprensentar o número de comandos válidos executados.



-- | A função 'main' lê um ficheiro e inicializa a execução do jogo, imprimindo os resultados. 

main = do input <- getContents
          putStr (unlines (setUp (lines input)))


-- | 'setUp' prepara o ficheiro recebido e inicializa a execução do nível de LightBot. Esta função devolve o resultado da execução do nível.
setUp :: [String] -> [String]
setUp input = execCmds tab pos cmd lampList 0
              where tab = take (length input-2) input
                    pos = input !! (length input-2)
                    cmd = input !! (length input-1)
                    lampList = getLampadas (reverse tab) 0 0



{-|
'execCmds' recebe os dados necessários para a execução do jogo: 'Tabuleiro', 'Posicao', 'Comandos'; e os dados respetivos ao estado 
do jogo: ['Lampada'], 'Jogadas'.

Esta função executa os comandos recebidos e devolve uma String do tipo @\"(x,y)\"@  em que (x,y) corresponde à posição da lâmpada no tabuleiro,
 sempre que é acesa\/desligada uma lâmpada.

A função termina a sua execução quando se depara com um dos seguintes casos:

1. recebe uma ['Lampada'] vazia e devolve @\"FIM n\"@, em que @n@ corresponde ao número de "Jogadas".

2. a sequênia de comandos terminou e devolve \"INCOMPLETO\".

/Observação: os casos estão listados pela ordem verificada na função./
-}
execCmds :: Tabuleiro -> Posicao -> Comandos -> [Lampada] -> Jogadas -> [String]
execCmds _ _ _ [] nPlays = [("FIM "++(show nPlays))]
execCmds _ _ [] _ _    = ["INCOMPLETO"]

execCmds tab pos (cmd:xs) lampList nPlays | (elem cmd "EDAS") && (doCmd tab pos cmd /= [])  = execCmds tab (doCmd tab pos cmd) xs lampList (nPlays+1)
                                          | (cmd == 'L') && (isUpper posNivel)              = posLamp : execCmds tab pos xs (luz pos lampList) (nPlays+1)
                                          | otherwise                                       = execCmds tab pos xs lampList nPlays
                                            where posNivel = getPos tab pos
                                                  posLamp = unwords [(words pos !! 0),(words pos !! 1)]


{-|
'getLampadas' recebe um 'Tabuleiro' e dois @Int@ responsáveis por controlar a posição em que a função vai atuar. Esta função percorre o tabuleiro,
entrada a entrada, e reúne as posições de todos as lâmpadas presentes no tabuleiro, devolvendo uma ['Lampada'].
-}

getLampadas :: Tabuleiro -> Int -> Int -> [Lampada]
getLampadas [] _ _ = []
getLampadas (h:t) n m | (isUpper x) && (xs == [])    = (m,n):getLampadas t (n+1) 0   -- casos em que troca para
                      | not(isUpper x) && (xs == []) = getLampadas t (n+1) 0         -- a linha seguinte
                      | isUpper x                    = (m,n):getLampadas (xs:t) n (m+1)
                      | not(isUpper x)               = getLampadas (xs:t) n (m+1)
                       where (x:xs) = h



{-|
'luz' verifica se a lâmpada existente na 'Posicao' recebida se encontra na ['Lampada'], que conté a lista de lâmpadas apagadas. Esta função devolve 
uma ["Lampada"] em que:

*caso a lâmpada não pertença à lista é devolvido uma lista com a lâmpada.

*caso a lâmpada pertença à lista é devolvido uma lista sem a lâmpada.
-}
luz :: Posicao -> [Lampada] -> [Lampada]
luz pos lampList | lamp == [] = (x,y):resto -- se a lampada estiver acesa -> apaga a lampada
                 | otherwise  = resto       -- se a lampada estiver apagada -> Liga a lampada
                  where x = read ((words pos) !! 0) :: Int
                        y = read ((words pos) !! 1) :: Int
                        (lamp,resto) = partition (\ (xL,yL) -> (xL == x) && (yL == y)) lampList -- verifica se a lampada está apagada

{-|
'doCmd' recebe os dados necessários à execução do comando, 'Tabuleiro' e 'Posicao', o comando, e devolve a posição originada pela execução do comando 
 recebido.
-}

doCmd :: Tabuleiro -> Posicao -> Char -> Posicao
doCmd tab pos cmd | (cmd == 'A') = avancar tab pos
                  | (cmd == 'S') = saltar tab pos
                  | (cmd == 'E') = esq pos
                  | (cmd == 'D') = dir pos




{-| 
'esq' recebe uma 'Posicao' e devolve como resultado uma nova 'Posicao' na qual a orientação assumida pelo Robot é girada 90º para a esquerda 
de acordo com os pontos cardeais.
-}

esq :: Posicao -> Posicao                                            
esq pos | (ori == "N") = unwords (coords ++ ["O"])
        | (ori == "O") = unwords (coords ++ ["S"])
        | (ori == "S") = unwords (coords ++ ["E"])
        | (ori == "E") = unwords (coords ++ ["N"])
           where ori = (words pos) !! 2
                 coords = [(words pos) !! 0,(words pos)  !! 1]




{-| 
'dir' recebe uma "Posicao" e devolve uma nova "Posicao" na qual a orientação assumida pelo Robot é girada 90º para a direita 
de acordo com os pontos cardeais.
-}

dir :: Posicao -> Posicao                                            
dir pos | (ori == "N") = unwords (coords ++ ["E"])
        | (ori == "E") = unwords (coords ++ ["S"])
        | (ori == "S") = unwords (coords ++ ["O"])
        | (ori == "O") = unwords (coords ++ ["N"])
          where ori = (words pos) !! 2
                coords = [(words pos) !! 0,(words pos)  !! 1]





{-| 
'avancar' recebe um 'Tabuleiro' e uma 'Posicao' e devolve a nova 'Posicao' assumida pelo Robot após este avançar no tabuleiro de acordo com a sua
orientação.

Para que a execução do comando 'avancar' seja uma ação válida as seguintes condições devem ser cumpridas:

* a nova posição deve continuar dentro dos limites do tabuleiro;

* a posição dada e a nova posição devem estar no mesmo nível;

Caso uma destas condições não seja cumprida é devolvido @[]@.
-}

avancar :: Tabuleiro -> Posicao -> Posicao                               
avancar tab pos | (nivel == proxNivel) = unwords newPos
                | otherwise = []
                  
                where nivel = toLower (getPos tab pos)
                      (proxNivel, x, y) = getNext tab pos
                      newPos = [(show x),(show y),(words pos) !! 2]





{-|
'saltar' recebe um 'Tabuleiro' e uma 'Posicao' e devolve a nova 'Posicao' assumida pelo Robot após este saltar no tabuleiro de acordo com a sua
orientação.

Para que a execução do comando 'saltar' seja uma ação válida as seguintes condições devem ser cumpridas:

* a nova posição deve continuar dentro dos limites do tabuleiro;

* a nova posição deve ser um nível superior à posição dada OU a nova posição deve ser inferior à posição dada;

Caso uma destas condições não seja cumprida é devolvida @[]@.
-}

saltar :: Tabuleiro -> Posicao -> Posicao
saltar tab pos | (proxNivel < nivel) && (proxNivel >= 'a') = newPos 
               | (proxNivel == nivelUp) = newPos
               | otherwise = []
               
               where (proxNivel, x, y) = getNext tab pos
                     nivel = toLower (getPos tab pos)
                     nivelUp = chr (ord nivel + 1)
                     newPos = unwords [(show x),(show y),(words pos) !! 2]





-- | 'getPos' recebe um 'Tabuleiro' e uma 'Posicao' e devolve como resultado o 'Nivel' da posição em que o robot se encontra no tabuleiro.

getPos :: Tabuleiro -> Posicao -> Nivel
getPos tab pos = rTab !! y !! x
              
                 where rTab = reverse tab 
                       x = read ((words pos) !! 0) :: Int
                       y = read ((words pos) !! 1) :: Int


{-|
'getNext' recebe um 'Tabuleiro' e uma 'Posicao' e devolve todos os dados da posição seguinte, @('Nivel',Int,Int)@. Estes dados correspondem a:

* nível da posição seguinte;

* abcissa da posição seguinte;

* ordenada da posição seguinte.

Caso a posição seguinte não esteja dentro dos limites do tabuleiro é devolvido como resultado (' ',-1,-1).

/Observação: A posição seguinte é calculada de acordo com a orientação do Robot./ 
-}

getNext :: Tabuleiro -> Posicao -> (Nivel, Int,Int)
getNext tab pos | (ori == "N") && (y+1 < n)   = (toLower(rMap !! (y+1) !! x), x, y+1)
                | (ori == "S") && (y-1 >= 0)  = (toLower(rMap !! (y-1) !! x), x, y-1)
                | (ori == "O") && (x-1 >= 0)  = (toLower(rMap !! y !! (x-1)), x-1, y)
                | (ori == "E") && (x+1 < m)   = (toLower(rMap !! y !! (x+1)), x+1, y)
                | otherwise = (' ', -1, -1) 
                
                where rMap = reverse tab
                      x = read ((words pos) !! 0) :: Int
                      y = read ((words pos) !! 1) :: Int
                      ori = (words pos) !! 2
                      n = length tab
                      m = length (head (tab))