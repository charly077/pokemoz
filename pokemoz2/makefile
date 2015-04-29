CHEMIN2 = /Applications/Mozart2.app/Contents/Resources/bin/ 
CHEMIN = /Applications/Mozart2.app/Contents/Resources/bin/

all : Graphic.ozf Pokemoz.ozf Trainer.ozf Game.ozf

exemple : all 
	$(CHEMIN)ozengine Game.ozf --mapFile 'map2.txt' --probability 35 --speed 4 --autofight true --auto true

Graphic.ozf : Graphic.oz
	$(CHEMIN)ozc -c Graphic.oz

Pokemoz.ozf : Pokemoz.oz
	$(CHEMIN)ozc -c Pokemoz.oz

Trainer.ozf : Trainer.oz
	$(CHEMIN)ozc -c Trainer.oz
	
Game.ozf : Game.oz
	$(CHEMIN)ozc -c Game.oz

clear : 
	rm *.ozf
