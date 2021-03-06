{-| 
Modulo : Main

Descrição : Módulo que gera a animação da resolução de um nível do jogo Lightbot numa página XHTML.

Este módulo recebe as informações correspodentes à resolução de um nível de LightBot, nomeadamente o tabuleiro, a posição inicial e os comandos
e gera uma represantação gráfica do tabuleiro. Para além disso é ainda representada a execução dos comandos através da animação do Robot.
-}

module Main where 

import Data.Char
import Data.List


type Tabuleiro = [String]
-- ^ Tipo usado para representar tabuleiros. Cada linha do tabuleiro é composto por um conjunto de carateres.
type Orientacao = Char
-- ^ Tipo usado para representar a orientação do Robot, à qual corresponde um ponto cardeal.
type Rotation = Float
{- ^ Tipo usado para representar a orientação do Robot num ficheiro XHTML. A cada ponto cardeal corresponde os seguintes valores:

* Norte -> 0

* Sul   -> 3.14

* Este  -> -1.57

* Oeste -> 1.57
-}
type Posicao = (Int,Int,Int,Orientacao)
{- ^ Tipo usado para representar a posição do Robot num tabuleiro. Para determinar a posição do Robot num dado tabuleiro
são usadas as coordenadas (x,y,z) tal como a orientação. -}
type Comando = Char
-- ^ Tipo usado para representar um dado comando.
type Lampada = (Int,Int)
-- ^ Tipo usado para representar a posição de uma lâmpada num tabuleiro. Para tal é usado o par ordenado (x,y).
type Coords = String
-- ^ Tipo usado para representar, no formato de uma String, as coordenadas (x,y,z) de um dado objeto.
type Cubo = String
-- ^ Tipo usado para a representação de um cubo em X3DOM.


-- | 'main' recebe o input e gera um ficheiro XHTML com a animação do input
main = do input <- getContents
          putStrLn (unlines (createFile (lines (input))))

-- ##################################################### FICHEIRO XHTML #######################################################################


{- | 'createFile' recebe o input (tabuleiro, posição inicial e comandos) e constrói o ficheiro XHTML com as seguintes carateristicas:

1. conjunto de cubos que formam a representação gráfica do tabuleiro;

2. temporizador que controla o ciclo da animação;

3. dados relativos às posições do Robot durante a animação;

4. dados relativos às orientações do Robot durante a animação;

5. dados relativos às mudançãs de cor durante a animação (uso do comando \"Luz\").
-}

createFile :: [String] -> [String]
createFile input = let -- obtenção dos dados através do input
                       tab = take (length input-2) input
                       (x,y,z,ori) = getPos tab (input !! (length input-2))
                       cmds = input !! (length input-1)
                       lamps = getLamps (reverse tab) 0
                       
                       -- dados obtidos a partir da execução dos comandos 
                       sequence = (toCoords (x,y,z,ori),'_'):(execCmds tab (x,y,z,ori) cmds lamps)
                       seqCmd = map (snd) sequence

                       -- construção do tabuleiro
                       lights3 = map (fst) (filter (\ (pos,cmd) -> cmd == '3') sequence) -- posições em que o jogador usou, incorretamente, o comando "Luz"
                       cells = transformTab (reverse tab) lights3 0 -- tabuleiro X3DOM
                       
                       -- controlo do tempo da animação
                       nCMD = length cmds
                       seconds = nCMD + 2 -- o Robot fica para durante aproximadamente 2 segundos antes da animação recomeçar
                       duration = (fromIntegral nCMD) / (fromIntegral seconds)
                       intervalo = duration / (fromIntegral nCMD)
                       
                       timer = "<timeSensor DEF=\"time\" cycleInterval=\""++(show seconds)++"\" loop=\"true\"> </timeSensor>"
                      
                       -- dados relativos às posições do Robot durante a animação
                       posKeys = unwords (getPosKeys seqCmd 0 intervalo)
                       posValues = unwords (getPosValues sequence)
                       posInterpolator = "<PositionInterpolator DEF=\"move\" key=\""++posKeys++"\" keyValue=\""++posValues++"\"> </PositionInterpolator>"
                      
                       -- dados relativos às orientações do Robot durante a animação
                       oriKeys = unwords (getOriKeys seqCmd 0 intervalo)
                       oriValues = unwords (getOriValues seqCmd (toRotation ori))
                       oriInterpolator = "<OrientationInterpolator DEF=\"virar\" key=\""++oriKeys++"\" keyValue=\""++oriValues++"\"> </OrientationInterpolator>"
                      
                       -- dados relativos à animação de todas as posições em que foi usado o comando "Luz"
                       lamps' = nub (map (fst) (filter (\ (_,cmd) -> cmd == 'L') sequence)) ++ lights3
                       lampsInterpolators = lampsIP lamps' sequence intervalo
                       lampsRoutes = lampsRoute lamps'

                       -- inicio do ficheiro XHTML
                       beginFile = ["<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"","\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">","<html xmlns=\"http://www.w3.org/1999/xhtml\">","<head>","<meta http-equiv=\"X-UA-Compatible\" content=\"chrome=1\" />", "<meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\" />","<title>Tarefa 2</title>","<script src=\"http://www.x3dom.org/release/x3dom.js\"></script>","<link rel=\"stylesheet\" href=\"http://www.x3dom.org/release/x3dom.css\"/>","</head>","<body>","<h1>SnowBot</h1>","<p class=\"case\">","<X3D xmlns=\"http://www.web3d.org/specifications/x3d-namespace\" id=\"boxes\"","showStat=\"false\" showLog=\"false\" x=\"0px\" y=\"0px\" width=\"400px\" height=\"400px\">","<Scene>","<Background skyColor=\".83 1 1\" />", "<Shape DEF=\"tile\">","<Box size=\".98 .98 .98\"/>","<Appearance>","<Material diffuseColor=\".96 .96 1\"/>","</Appearance>","</Shape>","<Transform DEF=\"RobotT\">","<Transform DEF=\"cabeca\" translation=\"0 0 .5\">","<Shape>","<Appearance>","<Material diffuseColor=\"0.96 0.96 0.96\" specularColor=\".5 .5 .5\" />","</Appearance>","<Sphere radius=\"0.28\" />","</Shape>","</Transform>","<Transform DEF=\"corpo\" translation=\"0 0 0\">","<Shape>","<Appearance>","<Material diffuseColor=\"0.96 0.96 0.96\" specularColor=\".5 .5 .5\" />","</Appearance>","<Sphere radius=\"0.4\" />","</Shape>","</Transform>","<Transform DEF=\"chapeu\" translation=\"0 0 .75\" rotation=\"1 0 0 1.57\">", "<Shape>","<Appearance>","<Material diffuseColor=\"0.129 0.129 0.129\" specularColor=\".5 .5 .5\" />","</Appearance>","<Cylinder height=\"0.07\" radius=\"0.3\"/>","</Shape>","</Transform>","<Transform DEF=\"chapeu2\" translation=\"0 0 .75\" rotation=\"1 0 0 1.57\">", "<Shape>","<Appearance>","<Material diffuseColor=\"0.129 0.129 0.129\" specularColor=\".5 .5 .5\" />","</Appearance>","<Cylinder height=\"0.5\" radius= \"0.2\"/>","</Shape>","</Transform>","<Transform DEF=\"nariz\" translation=\"0 .35 .55\" rotation=\"0 0 0 45\">","<Shape>","<Appearance>","<Material diffuseColor=\"1 0.7 0\" specularColor=\".5 .5 .5\"/>","</Appearance>","<Cone height=\"0.2\" bottomRadius=\"0.07\"/>","</Shape>","</Transform>","<Transform DEF=\"olho1\" translation=\"0.13 .2 .63\" rotation=\"1 0 0 1.57\">","<Shape>","<Appearance>","<Material diffuseColor=\"0 0 0\" specularColor=\".5 .5 .5\"/>","</Appearance>","<Sphere radius=\"0.04\"/>","</Shape>","</Transform>","<Transform DEF=\"olho1meio\" translation=\"0.13 0.225 0.63\" rotation=\"1 0 0 1.57\">","<Shape>","<Appearance>","<Material diffuseColor=\"1 1 1\" specularColor=\".5 .5 .5\"/>","</Appearance>","<Sphere radius=\"0.02\"/>","</Shape>","</Transform>","<Transform DEF=\"olho2meio\" translation=\"-0.13 0.225 0.63\" rotation=\"1 0 0 1.57\">","<Shape>","<Appearance>","<Material diffuseColor=\"1 1 1\" specularColor=\".5 .5 .5\"/>","</Appearance>","<Sphere radius=\"0.02\"/>","</Shape>","</Transform>","<Transform DEF=\"olho2\" translation=\"-0.13 0.2 0.63\" rotation=\"1 0 0 1.57\">","<Shape>","<Appearance>","<Material diffuseColor=\"0 0 0\" specularColor=\".5 .5 .5\"/>","</Appearance>","<Sphere radius=\"0.04\"/>","</Shape>","</Transform>","<Transform DEF=\"bola1\" translation=\"0 0.35 0.05\" rotation=\"1 0 0 1.57\">","<Shape>","<Appearance>","<Material diffuseColor=\"0 0 0\" specularColor=\".5 .5 .5\"/>","</Appearance>","<Sphere radius=\"0.06\"/>","</Shape>","</Transform>","<Transform DEF=\"bola2\" translation=\"0 .32 .2\" rotation=\"1 0 0 1.57\">","<Shape>","<Appearance>","<Material diffuseColor=\"0 0 0\" specularColor=\".5 .5 .5\"/>","</Appearance>","<Sphere radius=\"0.04\"/>","</Shape>","</Transform>","<Transform DEF=\"bola3\" translation=\"0 .34 -0.1\" rotation=\"1 0 0 1.57\">","<Shape>","<Appearance>","<Material diffuseColor=\"0 0 0\" specularColor=\".5 .5 .5\"/>","</Appearance>","<Sphere radius=\"0.065\"/>","</Shape>","</Transform>","</Transform>"]
                       -- fim do ficheiro XHTML
                       endFile = ["<Route fromNode=\"time\" fromField =\"fraction_changed\" toNode=\"move\" toField=\"set_fraction\"> </Route>","<Route fromNode=\"move\" fromField =\"value_changed\" toNode=\"RobotT\" toField=\"set_translation\"> </Route>","<Route fromNode=\"time\" fromField =\"fraction_changed\" toNode=\"virar\" toField=\"set_fraction\"> </Route>","<Route fromNode=\"virar\" fromField =\"value_changed\" toNode=\"RobotT\" toField=\"set_rotation\"> </Route>","<Sound>","<AudioClip loop=\'true\' enabled=\"true\" url=\"musica.mp3\"/>","</Sound>","</Scene>","</X3D>","</p>","<p> &nbsp; </p>","</body>","</html>"]

                       -- construção do ficheiro XHTML
                    in beginFile ++ cells ++ [timer] ++ [posInterpolator] ++ [oriInterpolator] ++ lampsInterpolators ++ lampsRoutes ++ endFile


-- ########################################################### TABULEIRO #################################################################################

{- |
'transformTab' recebe o tabuleiro, a lista de posições onde é usado o comando \"Luz\" incorretamente, e o número da linha em que a função vai a atuar. Esta 
função é a aplicação da função 'transformLn' a todas as linhas do tabuleiro, gerando assim a representação gráfica de todo o tabuleiro.
-}

transformTab :: Tabuleiro -> [String] -> Int -> [Cubo]
transformTab [] _ _ = []
transformTab (l:ls) lights3 n = transformLn l lights3 (n,0)  ++ transformTab ls lights3 (n+1)

{- |
'transformLn' recebe o tabuleiro, a lista de posições onde é usado o comando \"Luz\" incorretamente tal como o par ordenado (x,y) correspondente à posição do
tabuleiro em que a função vai atuar. Esta função é responsável por gerar a representação gráfica de uma única linha do tabuleiro e faz uso da função 'lowerCubes'
para gerar as camadas inferiores do tabuleiro.
Na geração de um cubo são tidos três aspetos em conta:

1. cubos em que são usados o comando \"Luz\" de forma incorreta, necessitando por isso de dados adicionais para o decorrer da animação;

2. cubos que possuem uma lâmpada, apresentando por isso caraterísticas diferentes;

3. cubos normais.

>>> transformLn "aab" ["0 1 0"] (0,0)

\[\"\<Transform translation\=\'0 0 0\'\> \<Shape USE\=\"tile\"\/\> \<\/Transform\>\"

\<Transform translation\=\"1 0 0\"\> \<Shape\> \<Appearance\> \<Material DEF\=\"1 0\" diffuseColor\=\"0 0 1\"\/\> \<\/Appearance\>\<box size\=\".98 .98 .98\"\/\>\<\/Shape\>\<\/Transform\>

\<Transform translation\=\"4 2 0\"\> \<Shape\> \<Appearance\> \<Material DEF\=\"4 2\" diffuseColor\=\"0 .5 1\"\/\> \<\/Appearance\>\<box size\=\".98 .98 .98\"\/\>\<\/Shape\>\<\/Transform\>

\"\<Transform translation\=\'2 0 0\'\> \<Shape USE\=\"tile\"\/\> \<\/Transform\>\"\]
-}

transformLn :: String -> [String] -> (Int,Int) -> [Cubo]
transformLn [] _ _ = []
transformLn (c:cs) lights3 (n,m) | elem (coords (m,n,succ c)) lights3 = ("<Transform translation=\"" ++ (coords (m,n,c)) ++ "\"> <Shape> <Appearance> <Material DEF=\"" ++ (unwords [show m, show n]) ++ "\" diffuseColor=\"0 0 1\"/> </Appearance><box size=\".98 .98 .98\"/></Shape></Transform>") : (lowerCubes (m,n,pred (toLower c))) ++ transformLn cs lights3 (n,m+1)
                                 | isUpper c = ("<Transform translation=\"" ++ (coords (m,n,toLower c)) ++ "\"> <Shape> <Appearance> <Material DEF=\"" ++ (unwords [show m, show n]) ++ "\" diffuseColor=\"0 1 1\"/> </Appearance><box size=\".98 .98 .98\"/></Shape></Transform>") : (lowerCubes (m,n,pred (toLower c))) ++ transformLn cs lights3 (n,m+1)
                                 | otherwise = (getCube (m,n,c)) : (lowerCubes (m,n,pred c)) ++ transformLn cs lights3 (n,m+1)

{- |
'lowerCubes' recebe o par ordenado (x,y) e o carater correspondente à altura. Esta função é responsável por gerar cubos na posição (x,y) nos níveis inferiores
à do carater dado até atingir o nível mais baixo, correspondente ao carater \'a\'. Os cubos gerados por esta função são sempre cubos simples pois o Robot nunca
irá interagir com os cubos em questão, não sendo por isso necessária informação adicional.

>>> lowerCubes (0,0,'c')

\[\"\<Transform translation\=\'0 0 2\'\> \<Shape USE\=\"tile\"\/\> \<\/Transform\>\"

\"\<Transform translation\=\'0 0 1\'\> \<Shape USE\=\"tile\"\/\> \<\/Transform\>\"

\"\<Transform translation\=\'0 0 0\'\> \<Shape USE\=\"tile\"\/\> \<\/Transform\>\"\]


-}
lowerCubes :: (Int,Int,Char) -> [Cubo]
lowerCubes (_,_,'`') = []
lowerCubes (m,n,c) = [getCube (m,n,c)] ++ lowerCubes (m,n,pred c)





{- | 'getCube' é responsável por gerar um cubo simples em XHTML na posição dada.

>>> getCube (2,2,'b')

\"\<Transform translation\=\'2 2 1\'\> \<Shape USE\=\"tile\"\/\> \<\/Transform\>\"
-}
getCube :: (Int,Int,Char) -> Cubo
getCube (m,n,c) = "<Transform translation=\'" ++ (coords (m,n,c)) ++ "\'> <Shape USE=\"tile\"/> </Transform>"



{- | 
'coords' transforma o tuplo (Int,Int,Char), que contém a informação relativa à posição de um dado cubo, e transforma-o numa String com a mesma informação.

>>> coords (2,2,\'b\')

\"2 2 1\"

>>> coords (3,1,\'a\')

\"3 1 0\"
-}
coords :: (Int,Int,Char) -> Coords
coords (m,n,c) = unwords [show m, show n, show (ord c - ord 'a')]



-- ############################################################ POSIÇÕES ###########################################################################

{- |
'getPosKeys' usa os dados acerca dos comandos, obtidos através da execução dos comandos dados no input, para gerar os valores dos tempos usados para animar 
a mudança de posições do Robot. A função age de acordo com os seguintes parâmetros:

* cada mudança de posição demora 1 segundo

* '1', correspondente a um comando \"Avançar\" inválido) é dividido em duas fases;

* '2', correspondente a um comando \"Saltar\" é dividido em duas fases;

* \'S\', correspondente a um comando \"Saltar\" válido é dividido em três fases;

* todos os outros comandos possuem apenas uma única fase.
-}
getPosKeys :: [Comando] -> Float -> Float -> [String]
getPosKeys [] _ _ = []
getPosKeys (cmd:t) time intervalo | cmd == '1' || cmd == '2' = show (time+intervalo/2) : (show (time+intervalo)) : getPosKeys t (time+intervalo) intervalo
                                  | cmd == '_' = show time: getPosKeys t time intervalo
                                  | cmd == 'S' = show (time+intervalo/3) : (show (time+2*intervalo/3)) : (show (time+intervalo)): getPosKeys t (time+intervalo) intervalo 
                                  | otherwise = show (time+intervalo) : getPosKeys t (time+intervalo) intervalo

{- |
'getPosValues' usa os dados da sequência de posições e respetivos comandos, para gerar as posições usadas na animação do movimento do Robot. A função age de acordo
com os seguintes parâmetros: 

* '1', correspondente ao comando \"Avançar\" inválido) possui duas fases:

    1. o Robot move-se em direção à posição inválida;
  
    2. o Robot volta para a posição inicial.


* '2', correspondente ao comando \"Saltar\" inválido possui duas fases:

    1. o Robot salta, sem alterar a sua posição nos eixos x e y; 

    2. o Robot volta à sua posição inicial.


* \'S\', correspondente ao comando \"Saltar\" válido possui três fases:

    1. o Robot começa por se elevar, ultrapassando a altura da posição 2;

    2. o Robot começa a deslocar-se em direção à nova posição, ainda subindo ligeiramente;

    3. o Robot desce, continuando a deslocar-se em direção à nova posição até a alcançar.

* todos os outros comandos possuem apenas uma única fase.
-}
    
getPosValues :: [(Coords,Comando)] -> [String]
getPosValues [_] = []
getPosValues ((pos1,'_'):(pos2,cmd2):t) =  pos1 : getPosValues ((pos1,' '):(pos2,cmd2):t)
getPosValues ((pos1,cmd1):(pos2,'1'):t) = let [x1,y1,z1] = map (\ n -> read n :: Float) (words pos1)
                                              [x2,y2,z2] = map (\ n -> read n :: Float) (words pos2)
                                              
                                              [vx,vy,vz] = [x2-x1, y2-y1, z2-z1] -- vetor associado à translação
       
                                          in unwords [show (x1+0.15*vx), show (y1+0.15*vy), show z1] : pos1 : getPosValues ((pos1,cmd1):t)

getPosValues ((pos1,cmd1):(pos2,'2'):t) = let [x,y,z] = map (\ n -> read n :: Float) (words pos1)
                                           in unwords [show x, show y, show (z+1)] : pos1 : getPosValues ((pos1,cmd1):t)

getPosValues ((pos1,_):(pos2,'S'):t) | signum vz == 1 = salto1 : salto2 : pos2 : getPosValues ((pos2,'S'):t)
                                     | otherwise = salto1' : salto2' : pos2 : getPosValues ((pos2,'S'):t)
                                     where [x1,y1,z1] = map (\ n -> read n :: Float) (words pos1)
                                           [x2,y2,z2] = map (\ n -> read n :: Float) (words pos2)
                                           
                                           [vx,vy,vz] = [x2-x1, y2-y1, z2-z1] -- vetor associado à translação
                                           -- pontos usados caso o Robot salte para cima
                                           salto1 = unwords [show (x1+vx*0.1), show (y1+vy*0.1), show (z1+vz*1.1)]
                                           salto2 = unwords [show (x1+vx*0.6), show (y1+vy*0.6), show (z1+vz*1.3)]
                                           -- pontos usados caso o Robot salte para baixo
                                           salto1' = unwords [show (x1+vx*0.1), show (y1+vy*0.1), show (z1-vz*0.2)]
                                           salto2' = unwords [show (x1+vx*0.6), show (y1+vy*0.6), show (z1-vz*0.4)]

getPosValues ((pos1,_):(pos2,cmd2):t) = pos2 : getPosValues ((pos2,cmd2):t)
                                   
                                   
-- ########################################################### ORIENTAÇÃO ###############################################################################

{- |
'getOriKeys' usa os comandos para gerar os tempos usados para animar a mudança de orientação do Robot. Cada mudança de orientação demora 1 segundo.

>>> getOriKeys ['_','A','E','A','L'] 0 0.1666

\[\"0.0\",\"0.1666\",\"0.3332\"\]
-}
getOriKeys :: [Comando] -> Float -> Float -> [String]
getOriKeys [cmd1,cmd2] time intervalo = if cmd1 == '_' || cmd1 == 'E' || cmd1 == 'D' || cmd2 == 'E' || cmd2 == 'D' then [show time] else []
getOriKeys (cmd1:cmd2:t) time intervalo = if cmd1 == '_' || cmd1 == 'E' || cmd1 == 'D' || cmd2 == 'E' || cmd2 == 'D' then show time : getOriKeys (cmd2:t) (time+intervalo) intervalo
                                          else getOriKeys (cmd2:t) (time+intervalo) intervalo

{- | 'getOriValues' recebe a lista de comandos e calcura a orientação do Robot sempre que esta sofre uma mudança, devolvendo uma lista de valores, correspondentes
a rotações XHTML. 

>>> getOriValues ['_','A','E','A','L'] -1.57

\[\"0 0 1 -1.57\",\"0 0 1 -1.57\",\"0 0 1 0.0\"\]

-}

getOriValues :: [Comando] -> Rotation -> [String]
getOriValues (_:[]) _ = []
getOriValues ('E':t) ori = ("0 0 1 "++(show (ori+1.57))) : getOriValues t (ori+1.57)
getOriValues ('D':t) ori = ("0 0 1 "++(show (ori-1.57))) : getOriValues t (ori-1.57)
getOriValues (cmd1:cmd2:t) ori = if cmd1 == '_' || cmd2 == 'E' || cmd2 == 'D' then ("0 0 1 "++(show ori)) : getOriValues (cmd2:t) ori
                                                                              else getOriValues (cmd2:t) ori


-- ########################################################### LAMPADAS ##########################################################################

{- | 
'lampsIP' gera os dados relativos à mudança de cor de cada uma das lampâdas.


>>> lampsIP ["0 0 1","0 1 1"] [("0 0 1",'_'),("0 0 1",'L'),("0 1 1",'A'),("0 1 1",'L')] 0.1666

\[\"\<ColorInterpolator DEF\=\"cor0 0\" key\=\"0.0 0.1666\" keyValue\=\"1 0 0 1 1 0\"\> \<\/ColorInterpolator\>\",

\"\<ColorInterpolator DEF\=\"cor0 1\" key\=\"0.3332 0.49980003\" keyValue\=\"1 0 0 1 1 0\"\> \<\/ColorInterpolator\>\"\]

-}
lampsIP :: [Coords] -> [(Coords,Comando)] -> Float -> [String]
lampsIP [] _ _ = []
lampsIP (h:t) sequence intervalo = let [x,y,z] = words h
                                       def = unwords [x,y]
                                       lampKeys = unwords (getColorKeys sequence h 0 intervalo)
                                       lampValues = unwords (getColorValues sequence h True)
                                    in ("<ColorInterpolator DEF=\"cor"++def++"\" key=\""++lampKeys++"\" keyValue=\""++lampValues++"\"> </ColorInterpolator>") : lampsIP t sequence intervalo

{- | 'lampsRoute' associa cada ColorInterpolator ao timer e ao respetivo cubo.

>>> lampsRoute ["4 2 3"]

\[\"\<Route fromNode\=\"time\" fromField \=\"fraction_changed\" toNode\=\"cor4 2\" toField\=\"set_fraction\"\> \<\/Route\>\"

\"\<Route fromNode\=\"cor4 2\" fromField \=\"value_changed\" toNode\=\"4 2\" toField\=\"set_diffuseColor\"\> \<\/Route\>\"\]
-}
lampsRoute :: [String] -> [String]
lampsRoute [] = []
lampsRoute (h:t) = let [x,y,z] = words h
                       lampNode = unwords [x,y]
                       interpolator = "cor" ++ lampNode
                    in ["<Route fromNode=\"time\" fromField =\"fraction_changed\" toNode=\""++interpolator++"\" toField=\"set_fraction\"> </Route>",
                        "<Route fromNode=\""++interpolator++"\" fromField =\"value_changed\" toNode=\""++lampNode++"\" toField=\"set_diffuseColor\"> </Route>"]
                        ++ lampsRoute t



{- |
'getColorKeys' gera os tempos respetivos à mudança de cor de uma dada lampâda (ou posição em que tenha sido usado o comando \"Luz\" incorretamente).

>>> getColorKeys [("0 0 1",'_'),("0 1 1",'A'),("0 1 1",'L')] "0 1 1"

\[\"0.25\",\"0.5\"\]
-}
getColorKeys :: [(Coords,Comando)] -> Coords -> Float -> Float -> [String]
getColorKeys [(pos,cmd)] posL time interval | pos == posL && cmd == 'L' = [show time]
                                            | pos == posL && cmd == '3' = [show time, show (time+interval/2)]
                                            | otherwise = []
getColorKeys ((pos1,cmd1):(pos2,cmd2):t) posL time interval | pos1 == posL && cmd1 == 'L' = (show time) : getColorKeys ((pos2,cmd2):t) posL (time+interval) interval
                                                            | pos2 == posL && cmd2 == 'L' = (show time) : getColorKeys ((pos2,cmd2):t) posL (time+interval) interval
                                                            | pos1 == posL && cmd1 == '3' = (show time) : (show (time+interval/2)) : getColorKeys ((pos2,cmd2):t) posL (time+interval) interval
                                                            | pos2 == posL && cmd2 == '3' = (show time) : getColorKeys ((pos2,cmd2):t) posL (time+interval) interval
                                                            | otherwise = getColorKeys ((pos2,cmd2):t) posL (time+interval) interval

{- | 'getColorValues' recebe uma sequência de comandos e posições e calcura a cor da lampâda sempre que esta sofre uma mudança, devolvendo uma lista de valores (formato RGB)
, correspondentes às mudanças de cor.

>>> getColorValues [("0 0 1",'_'),("0 1 1",'A'),("0 1 1",'L')] "0 1 1"

\"1 1 0\"
-}
getColorValues :: [(Coords,Comando)] -> Coords -> Bool -> [String]                                              
getColorValues (_:[]) _ _ = []
getColorValues ((_,cmd1):(pos2,cmd2):t) posL lampOFF | pos2 == posL && cmd1 == 'L' && cmd2 == 'L' && lampOFF = "0 1 1" : getColorValues ((pos2,cmd2):t) posL False                                       
                                                     | pos2 == posL && cmd1 == 'L' && cmd2 == 'L' = ".1 0 1" : getColorValues ((pos2,cmd2):t) posL True
                                                     | pos2 == posL && cmd2 == 'L' && lampOFF = ".1 0 1" : "0 1 1" : getColorValues ((pos2,cmd2):t) posL False
                                                     | pos2 == posL && cmd2 == 'L' = "0 1 1" : ".1 0 1" : getColorValues ((pos2,cmd2):t) posL True
                                                     | pos2 == posL && cmd1 == '3' && cmd2 == '3' = "0 1 1" : ".96 .96 1" : getColorValues ((pos2,cmd2):t) posL False
                                                     | pos2 == posL && cmd2 == '3' = ".96 .96 1" : "0 1 1" : ".96 .96 1" : getColorValues ((pos2,cmd2):t) posL False
                                                     | otherwise = getColorValues ((pos2,cmd2):t) posL lampOFF


-- ############################################################### TAREFA 3 (ALTERADA) ###############################################################


{-|
'execCmds' recebe os dados necessários para a execução do jogo: tabuleiro, posição, comandos, lampâdas]. Esta função executa os comandos recebidos e 
devolve uma sequência de comandos, associados à respetiva posição. A função termina a sua execução quando se depara com um dos seguintes casos:

* a lista de lâmpadas encontra-se vazia;

* a sequênia de comandos terminou.

>>> execCmds ["Aba","abA"] (0,0,1,'E') "SSLEAEASLSL" [(0,1),(2,0)]

\[\(\"1 0 2\",\'S\'\),\(\"2 0 1\",\'S\'\),\(\"2 0 1\",\'L\'\),\(\"2 0 1\",\'E\'\),\(\"2 1 1\",\'A\'\),\(\"2 1 1\",\'E\'\),\(\"1 1 1\",\'1\'\),\(\"1 1 2\",\'S\'\),\(\"1 1 2\",\'3\'),(\"0 1 1\",\'S\'\),\(\"0 1 1\",\'L\'\)\]

-}

execCmds :: Tabuleiro -> Posicao -> [Comando] -> [Lampada] -> [(String,Char)]
execCmds _ _ _ [] = []
execCmds _ _ [] _ = []
execCmds tab pos@(x,y,z,ori) ('A':xs) lamps  | valid = (toCoords (x',y',z',ori),'A') : execCmds tab (x',y',z',ori) xs lamps
                                             | otherwise = (toCoords (x',y',z',ori),'1') : execCmds tab pos xs lamps
                                             where (x',y',z',valid) = avancar tab pos
                                                   
execCmds tab pos@(x,y,z,ori) ('L':xs) lamps  | isUpper (reverse tab !! y !! x) = (toCoords pos,'L') : execCmds tab pos xs (luz pos lamps)
                                             | otherwise = (toCoords pos,'3') : execCmds tab pos xs lamps
                                                 
execCmds tab pos ('S':xs) lamps  | newPos /= (-1,-1,-1,'!') = (toCoords newPos,'S') : execCmds tab newPos xs lamps
                                 | otherwise = (toCoords pos,'2') : execCmds tab pos xs lamps
                                   where newPos = saltar tab pos

execCmds tab pos (cmd:xs) lamps  = (toCoords pos,cmd) : execCmds tab (turn pos cmd) xs lamps
                      
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


{-|
'luz' verifica se a lampâda existente na posição dada se encontra na lista de lampâdas e atua de acordo com o resultado.

>>> luz (3,1,2,'E') [(1,4),(2,1),(3,1)]

[(1,4),(2,1)]

>>> luz (3,1,2,'E') [(1,4),(2,1)]

[(1,4),(2,1),(3,1)]

-}
luz :: Posicao -> [Lampada] -> [Lampada]
luz (x,y,_,_) lamps | lamp == [] = (x,y):resto -- se a lampada estiver acesa -> apaga a lampada
                    | otherwise  = resto -- se a lampada estiver apagada -> Liga a lampada
                      where (lamp,resto) = partition (\ (xL,yL) -> (xL == x) && (yL == y)) lamps -- verifica se a lampada está apagada


{- | 'turn' recebe um comando \"Esquerda\" ou \"Direita\" e altera a orientação do boneco de acordo com o comando recebido.

>>> turn (2,1,3,'N') 'D'
(2,1,3,'E')
-}
turn :: Posicao -> Comando -> Posicao
turn (x,y,z,'N') 'D' = (x,y,z,'E')
turn (x,y,z,'E') 'D' = (x,y,z,'S')
turn (x,y,z,'S') 'D' = (x,y,z,'O')
turn (x,y,z,'O') 'D' = (x,y,z,'N')
turn (x,y,z,'N') 'E' = (x,y,z,'O')
turn (x,y,z,'O') 'E' = (x,y,z,'S')
turn (x,y,z,'S') 'E' = (x,y,z,'E')
turn (x,y,z,'E') 'E' = (x,y,z,'N')




{-|
'saltar' recebe um tabuleiro e uma posição e devolve a nova posição assumida pelo Robot após este saltar no tabuleiro de acordo com a sua orientação. Para 
que a execução do comando 'saltar' seja uma ação válida as seguintes condições devem ser cumpridas:

* a nova posição deve continuar dentro dos limites do tabuleiro;

* a nova posição deve ser um nível superior à posição dada OU a nova posição deve ser inferior à posição dada;

Caso uma destas condições não seja cumprida é devolvida @(-1,-1,-1,-1)@.

>>> saltar ["aaaaa","aaaaA"] (0,0,1,'E')

(-1,-1,-1,\' \')

>>> saltar ["abcd","dcbA"] (0,0,4,'E')

(1,0,3,\'E\')
-}
saltar :: Tabuleiro -> Posicao -> Posicao
saltar tab (x,y,z,ori) | ((z' < z) && (z' >= 1)) || (z' == z+1) = (x',y',z',ori) 
                       | otherwise = (-1,-1,-1,'!')
                       where (x',y',z') = getNextS tab (x,y,z,ori)

{-|
'getNextS' recebe um tabuleiro e uma posição e devolve um tuplo (x,y,z) com as coordenadas da posição seguinte, se existir. Caso a posição seguinte não 
esteja dentro dos limites do tabuleiro é devolvido como resultado (-1,-1,-1).

>>> getNextS ["aaaaa","aaaaA"] (0,0,1,'E')

(1,0,1)

>>> getNextS ["aaaaa","aaaAa"] (0,1,1,'N')

(-1,-1,-1)
-}
getNextS :: Tabuleiro -> Posicao -> (Int,Int,Int)
getNextS tab (x,y,z,ori) | (ori == 'N') && (y+1 < n)   = (x, y+1, ord (toLower (reverse tab !! (y+1) !! x)) - ord 'a' + 1)
                         | (ori == 'S') && (y-1 >= 0)  = (x, y-1, ord (toLower (reverse tab !! (y-1) !! x)) - ord 'a' + 1)
                         | (ori == 'O') && (x-1 >= 0)  = (x-1, y, ord (toLower (reverse tab !! y !! (x-1))) - ord 'a' + 1)
                         | (ori == 'E') && (x+1 < m)   = (x+1, y, ord (toLower (reverse tab !! y !! (x+1))) - ord 'a' + 1)
                         | otherwise = (-1, -1, -1) 
                         where n = length tab
                               m = length (head (tab))



{-| 
'avancar' recebe um tabuleiro' e uma posição e devolve a nova posição assumida pelo Robot após este avançar no tabuleiro de acordo com a sua orientação.
Para que a execução do comando \"Avancar\" seja uma ação válida as seguintes condições devem ser cumpridas:

* a nova posição deve continuar dentro dos limites do tabuleiro;

* a posição dada e a nova posição devem estar no mesmo nível;

Caso uma destas condições não seja cumprida é devolvido a nova posição, marcada como posição inválida.


>>> avancar ["aabC","aabb"] (0,0,1,'N')

(0,1,1,True)

>>> avancar ["aabC","cabb"] (2,1,2,'E')

(2,2,2,False)
-}
avancar :: Tabuleiro -> Posicao -> (Int,Int,Int,Bool) 
avancar tab (x,y,z,ori) | validPos tab (x',y',z') && getZ tab (x',y') == z = (x',y',z',True)
                        | validPos tab (x',y',z') = (x',y',z',False)
                        | otherwise = (x',y',z,False)
                         
                         where (x',y',z') = getNextA tab (x,y,z,ori)


{- | 
'getNextA' recebe um tabuleiro e uma posição e devolve um tuplo (x,y,z) com as coordenadas da posição seguinte.

>>> getNextA ["aabC","cabb"] (0,0,0,'E')

(1,0,1)

>>> getNextA ["aabC","cabb"] (0,0,0,'N')

(0,1,1) 
-}
getNextA :: Tabuleiro -> Posicao -> (Int,Int,Int)
getNextA tab (x,y,z,ori) | ori == 'N' = (x, y+1, z)
                         | ori == 'S' = (x, y-1, z)
                         | ori == 'O' = (x-1, y, z)
                         | ori == 'E' = (x+1, y, z)





{- | 
'getZ' recebe o tabuleiro e uma posição e devolve como resultado o a altura da posição em que o robot se encontra no tabuleiro.

>>> getZ ["ddde","eedD"] (2,1)

4
-}
getZ :: Tabuleiro -> (Int,Int) -> Int
getZ tab (x,y) = ord (toLower (reverse tab !! y !! x)) - (ord 'a') + 1


{- | 'validPos' verifica se a posição dada é uma posição válida.

>>> validPos ["aabc","aabC"] (2,3,1)

False

>>> validPos ["aabc","aabC"] (1,1,1)

True
-}
validPos :: Tabuleiro -> (Int,Int,Int) -> Bool
validPos tab (x,y,_) = let n = length tab
                           m = length (head tab)
                        in (y < n) && (y >= 0) && (x >= 0) && (x < m)

{- | 
'getPos' transforma a String dada numa 'Posicao' com a mesma informação.

>>> getPos ["aAa","baa"] "0 0 E"

(0,0,2,\'E\')

>>> getPos ["Abc","aaD"] "1 0 O"

(1,1,1,\'O\')
-}
getPos :: Tabuleiro -> String -> Posicao
getPos tab strPos = let [strX,strY,[ori]] = words strPos
                        x = read strX :: Int
                        y = read strY :: Int
                        z = getZ tab (x,y)
                     in (x,y,z,ori)

{- | 'toRotation' transforma um valor do tipo 'Orientacao' num valor do tipo 'Rotation' com a mesma informação.

>>> toRotation 'E'

\-1.57

>>> toRotation 'S'

3.14
-}
toRotation :: Orientacao -> Rotation
toRotation 'N' = 0
toRotation 'S' = 3.14
toRotation 'E' = -1.57
toRotation 'O' = 1.57

{- | 'toCoords' transforma um valor do tipo 'Posicao' num valor do tipo 'Coords' com a mesma informação.

>>> toCoords (2,2,1,'E')

\"2 2 1\"
-}
toCoords :: Posicao -> Coords
toCoords (x,y,z,_) = unwords [show x,show y, show z]