{-| 
Modulo : Main

Descrição : Módulo que testa a validade de um dado ficheiro 

Este programa verifica se um ficheiro é válido para representar um nível de LightBot. Como resultado desta verificação o programa devolve os valores @\<OK\>@
quando o ficheiro é válido; @\<num\>@ em que @num@ é a primeira linha em que o ficheiro diverge das normas especificadas. 
-}

module Main where

import Data.Char

type Tabuleiro = [String] 
-- ^ Tipo usado para representar tabuleiros. Cada linha do tabuleiro é composto por um conjunto de carateres.
type Comandos = String    
-- ^ Tipo usado para representar uma linha de comandos. Cada comando é associado a um carater.
type Posicao = String     
-- ^ Tipo usado para representar a posição do Robot. Uma posição válida deverá apresentar a seguinte estrutura /@x y ori@/.



-- | 'main' lê um ficheiro e inicializa a sua verificação, imprimindo o resultado final.
main = do file <- getContents
          if (checkContent (lines file) == -1) then putStrLn "OK"
          else print (checkContent (lines file))




{- | 'checkContent' recebe um ficheiro, e verifica se a sua estrutura é válida para um nível de LightBot. Uma estrutura válida obdece às seguintes 
normas:

* tem pelo menos 3 linhas;

* pode ser dividida em três partes (cada uma delas válida) de acordo com o seu conteúdo: tabuleiro; posição; comandos;

* não ter linhas após a secção que define os comandos;

Como resultado é devolvido um @Int@ cujo valor varia entre @-1@ caso o ficheiro seja válido e @erro@ em que @erro@ é a primeira linha
em que o ficheiro não cumpre as normas.
-}

checkContent :: [String] -> Int
checkContent input 
                  | (length input < 3)                                                = 1                         -- listas menores que três elementos apresentam erro na linha 1
                  | checkTab tab (1,m) /= -1                                          = deepCheck tab (n,m) input -- verifica se existem mais linhas que o suposto
                  | (checkTab [pos] (1,m) == -1) && (checkTab [cmds] (n,m) == -1)     = length input + 1          -- caso não existam linhas a definir posição inicial e solução
                  | checkTab [pos] (1,m) == -1                                        = length input              -- caso não exista linha a definir posição inicial
                  | checkPos pos (n,m) == False                                       = length input - 1          -- verifica se posição inicial é válida
                  | checkCmd cmds  == False                                           = length input              -- verifica se a solução é válida
                  | otherwise                                                         = -1                        -- mapa válido
                    where 
                          tab = take (length input-2) input
                          n  = length tab
                          m  = length (head (tab))
                          pos = input !! (length input -2)
                          cmds = last input




{-| 'checkTab' verifica se a estrutura do 'Tabuleiro' recebido está dentro das normas. Para isso faz uso de @(Int,Int)@ que contém informação sobre as linhase 
e as colunas.
O tabuleiro deve conter a seguinte estrutura:

* o comprimento de todas as linhas é igual;

* apenas contém letras.

Como resultado é devolvido um @Int@ cujo valor varia entre @-1@ caso o tabuleiro esteja devidamente construido e @n@ em que @n@ é a primeira linha
em que o tabuleiro não cumpre as normas.
-}

checkTab :: Tabuleiro -> (Int,Int) -> Int
checkTab [] _ = -1
checkTab (h:t) (n,m) | (length h == m) && (all (\ c -> isAlpha c) h) = checkTab t (n+1,m)
                     | otherwise = n



{-| 'checkCmd' verifica se os 'Comandos' recebidos são válidos. Uma sequência de comandos válida deve conter apenas as seguinte os carateres \'A\' (Avançar), 
\'S\' (Saltar), \'E\' (Esquerda), \'D\' (Direita), \'L\' (Luz).

Como resultado é devolvido um @Bool@ cujo valor varia entre @True@ se a sequência de comandos for válida; @False@ se a sequência de comandos for inválida.-}

checkCmd :: Comandos -> Bool
checkCmd [] = True                                                                                
checkCmd (x:xs) | elem x "EDASL" = checkCmd xs
                | otherwise = False




{-| 'checkPos' recebe os limites do tabuleiro e verifica se a 'Posicao' recebida está dentro do seguinte formato \"x y ori\", em que:

* @x@ corresponde à posição do Robot no eixo das abcissas num dado tabuleiro. O seu valor deve ser inteiro e variar entre  @0@ e o @número de colunas do 
tabuleiro@ (exclusive);
                              
* @y@ corresponde à posição do Robot no eixo das ordenadas num dado tabuleiro. O seu valor deve ser inteiro e variar entre o @0@ e o @número de linhas do 
tabuleiro@ (exclusive);
                               
* @ori@ corresponde à orientação do Robot. Pode apenas variar nos seguintes valores: @N@ (Norte), @S@ (Sul), @E@ (Este), @O@ (Oeste). 

Como resultado é devolvido um @Bool@ cujo valor varia entre @True@ se a posição for válida; @False@ se a posição for inválida.
-}

checkPos :: Posicao -> (Int,Int) -> Bool
checkPos pos (n,m) = tamOk && coordsOk && oriOk
                    
                    where [x,y, ori] = words pos
                          tamOk = length (words pos) == 3
                          coordsOk = ((read x  :: Int) >= 0) && ((read x :: Int) < m) && ((read y :: Int) >= 0) && ((read y :: Int) < n)
                          oriOk = ori == "N" || ori == "S" || ori == "E" || ori == "S"




{- | 'deepCheck' recebe um 'Tabuleiro' inválido, as dimensões do tabuleiro, e o ficheiro que se encontra atualmente em teste.

Esta função reavalia qual a primeira linha em que o ficheiro divergiu das normas. Esta ação é necessária pois ficheiros com linhas após a 
sequência de comandos são divididos de forma incorreta.

Como resultado é devolvido um @Int@ com o valor real da primeira linha onde o ficheiro diverge das normas especificadas.
-}

deepCheck :: Tabuleiro -> (Int,Int) ->  [String] -> Int
deepCheck tab (n,m) input | not(checkPos l1 (n,m)) = linha -- implica que a linha de erro pertence, efetivamente, ao tabuleiro
                          | (checkPos l1 (n,m)) && not(checkCmd l2) = (linha + 1) 
                          | (checkPos l1 (n,m)) && (checkCmd l2)    = (linha + 2)
                          
                            where linha = checkTab tab (1,m)
                                  l1 = input !! (linha-1) -- linha do erro
                                  l2 = input !! linha  -- linha a seguir ao erro