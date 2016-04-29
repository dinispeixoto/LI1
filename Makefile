all: tarefa test doc relatorio

tarefa: tarefa1 tarefa2 tarefa3 tarefa4 tarefa5

tarefa1: src/tarefa1.hs
	ghc src/tarefa1.hs
tarefa2: src/tarefa2.hs
	ghc src/tarefa2.hs
tarefa3: src/tarefa3.hs
	ghc src/tarefa3.hs
tarefa4: src/tarefa4.hs
	ghc src/tarefa4.hs
tarefa5: src/tarefa5.hs
	ghc src/tarefa5.hs


test: test1 test2 test3 test4 test5

test1: src/tarefa1
	cd tests/tarefa_1; bash runtests.sh tab ../../src/tarefa1
test2: src/tarefa2
	cd tests/tarefa_2; bash runtests.sh tab ../../src/tarefa2
test3: src/tarefa3
	cd tests/tarefa_3; bash runtests.sh tab ../../src/tarefa3
test4: src/tarefa4
	cd tests/tarefa_4; bash runtests.sh tab ../../src/tarefa4
test5: src/tarefa5
	cd tests/tarefa_5; bash runtests.sh tab ../../src/tarefa5


doc: doc1 doc2 doc3 doc4 doc5

doc1: src/tarefa1.hs
	haddock -h -o doc/tarefa_1 src/tarefa1.hs
doc2: src/tarefa2.hs
	haddock -h -o doc/tarefa_2 src/tarefa2.hs
doc3: src/tarefa3.hs
	haddock -h -o doc/tarefa_3 src/tarefa3.hs
doc4: src/tarefa4.hs
	haddock -h -o doc/tarefa_4 src/tarefa4.hs
doc5: src/tarefa5.hs
	haddock -h -o doc/tarefa_5 src/tarefa5.hs

relatorio: ./tex/relatorio.tex
	pdflatex tex/relatorio.tex

clean:
	rm -f src/tarefa1.hi src/tarefa1.o src/tarefa2.hi src/tarefa2.o src/tarefa3.hi src/tarefa3.o src/tarefa4.hi src/tarefa4.o src/tarefa5.hi src/tarefa5.o
	rm -f tex/relatorio.aux tex/relatorio.log tex/relatorio.out tex/relatorio.toc tex/relatorio.lof

realclean: clean
	rm -rf doc/tarefa_1 doc/tarefa_2 doc/tarefa_3 src/tarefa1 src/tarefa2 src/tarefa3 src/tarefa4 src/tarefa5
	rm -f tex/relatorio.pdf