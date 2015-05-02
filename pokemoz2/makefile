OZENGINE = $(shell locate /bin/ozengine | grep Mozart2)
OZC = $(shell locate /bin/ozc | grep Mozart2) 

all : Graphic.ozf Pokemoz.ozf Trainer.ozf Game.ozf

exemple : all 
	$(OZENGINE) Game.ozf --mapFile 'map.txt' --probability 35 --speed 4 --autofight fight  --auto 

Graphic.ozf : Graphic.oz
	$(OZC) -c Graphic.oz

Pokemoz.ozf : Pokemoz.oz
	$(OZC) -c Pokemoz.oz

Trainer.ozf : Trainer.oz
	$(OZC) -c Trainer.oz
	
Game.ozf : Game.oz
	$(OZC) -c Game.oz

clear : 
	rm *.ozf
