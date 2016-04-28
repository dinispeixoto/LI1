{-| 
Modulo : Main

Descrição : Módulo que gera a resolução de um nível de LigthBot a partir de um dado tabuleiro de uma posição inicial.

Este módulo recebe um tabuleiro e uma posição inicial e gera uma solução onde o Robot acende todas as lampâdas, quando possível.
-}

module Main where

import Data.Char
import Data.List
import Data.Maybe

type Tabuleiro = [String]
-- ^ Tipo usado para representar tabuleiros. Cada linha do tabuleiro é composto por um conjunto de carateres.
type Posicao = (Int,Int)
{- ^ Tipo usado para representar a posição do Robot num tabuleiro. Para determinar a posição do Robot num dado tabuleiro
são usadas as coordenadas (x,y) -}
type Orientacao = Char
-- ^ Tipo usado para representar a orientação do Robot.
type Lampada = (Int,Int)
-- ^ Tipo usado para representar a posição de uma lampâda. Para determinar a posição do Robot num dado tabuleiro são usadas as coordenadas (x,y).
type Cmd = Char
-- ^ Tipo usado para representar um dado comando.


-- | 'main' e gera uma possível solução para o input dado
main = do input <- getContents
          putStrLn (setUp (lines input))



-- |'setUp' recebe o input e inicia o cálculo da resolução do nível, devolvendo a solução, caso exista.

setUp :: [String] -> String
setUp input = checkResult result lamps

              where tab = init input
                    (pos, ori) = extractPos (words (last input))
                    lamps = getLamps (reverse tab) 0
                    (others,wells) = splitLamps tab lamps

                    route = getRoute tab pos ori others wells
                    result = getResult ori route


-- ######################################################## EM BUSCA DAS LAMPADAS ###############################################################

{- |
'getRoute' calcula a rota usada para acender todas as lampâdas, aplicando a função 'findRoute' para achar o caminho de lampâda para lampâda, até que todas
as lampâdas estejam ligadas, estando então o tabuleiro resolvido.

As lampâdas são acesas de acordo com o seguinte parâmetro:

* é possível chegar desta lampâda a todas as outras?

Seguindo este parâmetro permite que o Robot ligue todas as lampâdas sem que vá em direção a uma outra lampâda que não permita retorno.
-}
getRoute :: Tabuleiro -> Posicao -> Orientacao -> [Lampada] -> [Lampada] -> [(Posicao,Orientacao,Cmd)]
getRoute _ _ _ [] [] = []
getRoute tab pos ori [] wells = let (lamps, newWells) = splitLamps tab wells
                                in getRoute tab pos ori lamps newWells

getRoute tab pos ori lamps wells | elem pos lamps = (pos,ori,'L') : getRoute tab pos ori (delete pos lamps) wells
                                 | route == [] = []
                                 | otherwise = route ++ (getRoute tab posL oriL (delete posL lamps) wells)

                                   where route = concat (findRoute tab [[(pos,ori,'_')]] [pos] lamps)
                                         (posL,oriL,_) = last route                              

{- |
'findRoute' calcula, a partir de uma lista de caminhos possiveis e de uma lista de posições já percorridas, uma possível rota para uma lampâda do tabuleiro,
 partido da posição dada.

>>> findRoute ["caacA","bcaaa","acacc"] [[((0,0),'N','_')]] [(0,0)] [(4,2)]

\[\[((0,0),\'N\',\'_\'),((0,1),\'N\',\'S\'),((1,1),\'E\',\'S\'),((2,1),\'E\',\'S\'),((3,1),\'E\',\'A\'),((4,1),\'E\',\'A\'),((4,2),\'N\',\'A\'),((4,2),\'N\',\'L\')\]\]
-}

findRoute :: Tabuleiro -> [[(Posicao,Orientacao,Cmd)]] -> [Posicao] -> [Lampada] -> [[(Posicao,Orientacao,Cmd)]]
findRoute _ [] _ _ = []
findRoute tab (h:t) checked lamps | elem pos lamps = [h++[(pos,ori,'L')]]
                                  | paths == [] = findRoute tab t checked lamps -- o caminho não tem saída ou as proximas posições já foram percorridas; esta rota é descartada.
                                  | otherwise = findRoute tab (t++routes) (cells++checked) lamps
                   
                                             where (pos,ori,cmd) = last h
                                                   paths = getPaths tab  pos ori checked
                                                   routes = map (\ position -> h++[position]) paths -- cria novas rotas a partir da posição atual
                                                   cells = map (\ (position,_,_) -> position) paths -- posições verificadas nesta iteração


-- ####################################################### PROXIMAS POSIÇOES ##########################################################################

{- |
'getPaths' calcula as posições válidas, ainda não verificadas, que o Robot poderá seguir a partir da sua posição atual e associa-as ao comando necessário
 para chegar à posição calculada.

>>> getPaths ["caacA","bcaaa","acacc"] (0,0) 'N' []

\[((0,1),\'N\',\'S\')\]

>>> getPaths ["caacA","bcaaa","acacc"] (0,1) 'N' [(0,0)]

[((1,1),'E','S'),((0,2),'N','S')]
-}

getPaths :: Tabuleiro -> Posicao -> Orientacao -> [Posicao] -> [(Posicao,Orientacao,Cmd)]
getPaths tab (x,y) ori checked = let options = [((x+1,y),'E'),((x-1,y),'O'),((x,y+1),'N'),((x,y-1),'S')]
                                    
                                     linhas = length tab
                                     colunas = length (head tab)
                                     onTab = filter (\ ((xT,yT),_) -> xT >= 0 && yT >= 0 && xT < colunas && yT < linhas) options
                                     
                                     withCmd = map (\ (newPos,newOri) -> (newPos,newOri,getCmd tab (x,y) newPos)) onTab

                                 in  filter (\ (newPos,_,cmd) -> cmd /= '!' && not (elem newPos checked)) withCmd


{- |
'getCmd' calcula o comando usado para chegar de uma dada posição1 a uma dada posição2. Caso não seja possível chegar de uma posição à outra é devolvido o carater
 \'!\', permitindo que esta posição seja descartada posteriormente.

>>> getCmd ["caacA","bcaaa","acacc"] (0,0) (0,1)

\'S\'

>>> getCmd ["caacA","bcaaa","acacc"] (0,0) (1,0)

\'!\'
-}

getCmd :: Tabuleiro -> Posicao -> Posicao -> Cmd
getCmd tab (x1,y1) (x2,y2) | cell1 > cell2 || succ cell1 == cell2 = 'S'
                           | cell1 == cell2 = 'A'
                           | otherwise = '!'
                            where cell1 = toLower ((reverse tab) !! y1 !! x1)
                                  cell2 = toLower ((reverse tab) !! y2 !! x2)



-- ############################################################## LAMPADAS ###########################################################################

{-|
'getLamps' recebe um tabuleiro e o número da linha em que a função vai atuar. Esta função percorre o tabuleiro, linha a linha, e reúne as posições de todos as 
lâmpadas presentes no tabuleiro, devolvendo uma lista de lampâdas.

>>> getLamps ["aaA"] 0

[(2,0)]

>>> getLamps ["aabC","Aaaa"] 0 

[(0,0),(3,1)]
-}

getLamps :: Tabuleiro -> Int -> [Lampada]
getLamps [] _ = []
getLamps (h:t) n = checkLine h (n,0) ++ getLamps t (n+1)

         where checkLine [] _ = []
               checkLine (h:t) (n,m) | isUpper h = (m,n) : checkLine t (n,m+1)
                                     | otherwise = checkLine t (n,m+1)

{- | 
'splitLamps' aplica a função 'checkWell' a todas as lâmpadas para dividi-las de acordo com o seguinte parâmetro:

* é possível chegar desta lampâda a todas as outras?

Esta divisão vai permitir que o Robot ligue todas as lampâdas sem que vá em direção a uma outra lampâda que não permita retorno.

>>> splitLamps ["caacA","bcaaa","acAcc"] [(4,2),(2,0)]

(\[(4,2),(2,0)\],\[\])

>>> splitLamps ["ccccc","ccaaC","ccaAc"] [(4,1),(3,0)]

(\[(4,1)\],\[(3,0)\])
-}

splitLamps :: Tabuleiro -> [Lampada] -> ([Lampada],[Lampada])
splitLamps tab lamps = partition (\ lamp -> checkWell tab lamp (delete lamp lamps)) lamps


checkWell :: Tabuleiro -> Posicao -> [Lampada] -> Bool
checkWell _ _ [] = True
checkWell tab pos (lamp:ls) = (findRoute tab [[(pos,'!','_')]] [pos] [lamp] /= []) && checkWell tab pos ls

                      
-- ######################################################### RESULTADO FINAL ##########################################################################

{- |
'getResult' recebe a sequência de posições, associadas aos respetivos comandos, usadas para resolver o nível de LightBot e extrai todos os comandos,
adicionando os comandos necessários para igualar as orientações.

>>> getResult 'E' [[((0,0),'N','_'),((0,1),'N','S'),((1,1),'E','S'),((2,1),'E','S'),((3,1),'E','A'),((4,1),'E','A'),((4,2),'N','A'),((4,2),'N','L')]]

\"ESDSSAAEAL\"
-}

getResult :: Orientacao -> [(Posicao, Orientacao, Cmd)] -> String
getResult _ [] = []
getResult oriI ((_,oriF,cmd):t) | cmd == '_' = (changeDir oriI oriF) ++ getResult oriF t
                                | otherwise = (changeDir oriI oriF) ++ [cmd] ++ getResult oriF t

{- |
'changeDir' recebe duas orientações e devolve a lista de comandos necessários para que, partindo da primeira orientação, possamos chegar à segunda. 
Caso as orientações sejam iguais é devolvida uma lista vazia.

>>> changeDir 'N' 'E'

\"D\"

>>> changeDir 'E' 'O'

\"DD\"

>>> changeDir 'S' 'S'

\[\]
-}

changeDir :: Orientacao -> Orientacao -> [Cmd]
changeDir o o2 | o == o2 = [] 
               | o == 'S' && o2 == 'N' || o == 'N' && o2 == 'S' || o == 'E' && o2 == 'O' || o == 'O' && o2 == 'E' = "DD"
               | o == 'N' && o2 == 'E' || o == 'E' && o2 == 'S' || o == 'S' && o2 == 'O' || o == 'O' && o2 == 'N' = "D"
               | o == 'N' && o2 == 'O' || o == 'O' && o2 == 'S' || o == 'S' && o2 == 'E' || o == 'E' && o2 == 'N' = "E"

{- |
'checkResult' verifica se o número de comandos \"Luz\" corresponde ao número de lampâdas existentes, devolvendo a rota calculado caso seja, ou "IMPOSSIVEL"
caso o número não coincida.

>>> checkResult "AASAL" [(0,2),(1,3)]

\"IMPOSSIVEL\"

>>> checkResult "SSAL" [(0,3)]

\"SSAL\"
-}

checkResult :: String -> [Lampada] -> String
checkResult result lamps = let nLamps = length lamps
                               nAcesas = length (filter (=='L') result)
                           in if nLamps == nAcesas then result else "IMPOSSIVEL"

-- ####################################################### CONVERSÃO #################################################################################

{- |
'extractPos' transforma uma lista de Strings com informações acerca da posição do Robot num par (Posição,Orientacao) com a mesma informação.
-}

extractPos :: [String] -> (Posicao,Orientacao)
extractPos [x,y,[o]] = ((read x :: Int, read y :: Int), o)