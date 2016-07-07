Laboratórios de Informática I - LightBot em Haskell
===================================================

Projeto desenvolvido no período 2014/1025 no âmbito da unidade curricular *Laboratórios de Informática I* na Universidade do Minho.

O projeto consiste numa série de pequenas aplicações desenvolvias em **Haskell** e baseia-se no puzzle *LightBot* onde se controla um *robot* num tabuleiro de blocos por intermédio de comandos simples com o objetivo de acender todas as lâmpadas disponíveis.

Formato do *input*
-------

O *input* consiste num tabuleiro onde o robot se move, a posição e orientação inicial do robot, e a lista de comandos a ser executado.

O tabuleiro, de dimensões *m x n* é representado por *n* linhas, cada um contendo um sequência de *m* carateres alfabéticos, em que cada carater está associado a uma dada altura: carater *a* ou *A* à altura 0; carater *b* ou *B* à altura 1; e assim sucessivamente. A utilização de uma letra maiúscula indica que existe uma *lâmpada* naquela posição. A posição de coordenadas (0,0) corresponde ao canto inferior esquerdo do tabuleiro.

O estado inicial do robot é representado por uma única linha do tipo *xpos ypos orient* onde *xpos* e *ypos* devem corresponder a uma posição do tabuleiro, a qual será a posição inicial do *robot*. A orientação inicial é dada por *orient* e deve corresponde a um dos seguintes carareteres: N, E, S, O.

A lista de comandos é um sequência não vazia formado pelos seguintes carateres: *A* (avançar), *S* (saltar), *E* (esquerda), *D* (direita) e *L* (luz).

Tarefa 1
-----------
Valida se o *input* cumpre os requisitos impostos. Quando os requisitos não são cumpridos é imprimida a primeira linha em que foram violados.

```Markdown
./tarefa1
aabaa
aabac
aabac
1 0 E
AASLEEAL

OK
```

```Markdown
./tarefa1
aabaa
Aabac
a.bac
1 0 E 
AASLEEAL

3
```

Tarefa 2
-----------
Determina a posição do *robot* após a execução do primeiro comando fornecido. Assume-so que o *input* cumpre os requisitos da tarefa 1.

```Markdown
./tarefa2
aaabc
aaabb
aaaba
4 0 N
SAAAAAA

4 1 N
```

Tarefa 3
-----------
Realiza a sequência de comandos dada até que todas as lâmpadas sejam acendidas. Também nesta tarefa se assume que o *input* cumpre os requisitos da tarefa 1.

```Markdown
./tarefa3
abA
aba
aaa
0 2 S
AAEAAEAAL

2 2
FIM 9
```
```Markdown
./taref3
aaA
0 0 E 
LLLLLLLLLL

INCOMPLETO
```

Tarefa 4
-----------
Sintetiza uma sequência de comandos para que, quando possível, o *robot* acenda todas as lâmpadas a partir da sua posição inicial. O *input* é fornecido seguindo o formato usado na tarefa 1, excluindo apenas a linha com a sequência de comandos.

```Markdown
./tarefa4
aaaa
acAc
aaaa
0 0 N

DAAEAL
```

Tarefa 5
----------
Gera uma página *xhtml* onde se pode vizualizar, com recurso ao formato **X3DOM**, uma animação tridimensional do *input* dado que, como anteriormente, deve cumprir os requisitos da tarefa 1.

```Markdown
./tarefa5
aadddda
aaCbaaa
aadddda
aaaaaaa
0 0 E
AAAAAAEAAEAASSL

```
[Output](https://github.com/dinispeixoto/LI1/blob/master/tests/tarefa_5/tab15.xhtml)
