all : Graphic.ozf Pokemoz.ozf Trainer.ozf Game.ozf

exec : all 
	/Applications/Mozart2.app/Contents/Resources/bin/ozengine  Game.ozf

Graphic.ozf : Graphic.oz
	/Applications/Mozart2.app/Contents/Resources/bin/ozc -c Graphic.oz

Pokemoz.ozf : Pokemoz.oz
	/Applications/Mozart2.app/Contents/Resources/bin/ozc -c Pokemoz.oz

Trainer.ozf : Trainer.oz
	/Applications/Mozart2.app/Contents/Resources/bin/ozc -c Trainer.oz
	
Game.ozf : Game.oz
	/Applications/Mozart2.app/Contents/Resources/bin/ozc -c Game.oz

clear : 
	rm *.ozf
