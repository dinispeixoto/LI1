{-| 
Modulo : Main

Descrição : Módulo que testa a execução do primeiro comando 

Este programa verifica se a execução do primeiro comando num dado nível de /LigthBot/ devolve o resultado esperado. Se a ação testada for válida
o programa imprime a mensagem \<ERRO\>
-}

module Main where

import Data.Char

type Tabuleiro = [String]
-- ^ Tipo usado para representar tabuleiros. Cada linha do tabuleiro é composto por um conjunto de carateres.
type Posicao = String
-- ^ Tipo usado para representar a posição do Robot. Uma posição válida deverá apresentar a seguinte estrutura \"x y ori\".
type Nivel = Char
-- ^ Tipo usado para representar o nível de uma dada posição do tabuleiro.



-- | 'main' lê um ficheiro e verifica se a execução do primeiro comando é válida, imprimindo o resultado final.
main = do file <- getContents
          if (checkCMD file == []) then putStrLn "ERRO"
          else putStrLn (checkCMD file)



{-| 
'checkCmd' recebe um nível de /LightBot/ e executa o primeiro comando. Caso a execução deste comando seja uma ação válida é devolvido a posição assumida
pelo Robot. Nos casos em que a execução do comando resulta numa ação inválida a função devolve @[]@.
-}
checkCMD :: String -> Posicao
checkCMD file | (cmd == 'A') = avancar tab pos
              | (cmd == 'S') = saltar tab pos
              | (cmd == 'E') = esq pos
              | (cmd == 'D') = dir pos
              | (cmd == 'L') = luz tab pos
                 where 
                      input = lines file
                      tab = take (length input-2) input
                      pos = input !! (length input-2)
                      cmd = head (last input)



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




{-|
'luz' recebe um 'Tabuleiro' e uma 'Posicao' e caso exista uma lâmpada na 'Posicao' dada devolve como resultado esta mesma 'Posicao'. 
Caso não exista lâmpada é devolvido @[]@.

/Observação: As lâmpadas estão assinaladas no tabuleiro com letras maiúsculas./
-}
luz :: Tabuleiro -> Posicao -> Posicao                  
luz tab pos | isUpper posNivel = pos 
            | otherwise = []
            where posNivel = getPos tab pos



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