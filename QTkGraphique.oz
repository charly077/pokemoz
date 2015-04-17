declare
%Declaration QTk
[QTk] = {Module.link ['x-oz://system/wp/QTk.ozf']}

% Création des images pour l'herbe et la route avec leur Tag (je ne sais pas si ça va être utile par la suite :) )
GrassImage = {QTk.newImage photo(file:'/Users/charles/Desktop/pokemoz/herbe.gif')}
RoadImage = {QTk.newImage photo(file:'/Users/charles/Desktop/pokemoz/chemin.gif')}

% Création des images des pokémons
Bulbasoz = {QTk.newImage photo(file:'/Users/charles/Desktop/pokemoz/Bulbasoz.gif')}
Oztirtle = {QTk.newImage photo(file:'/Users/charles/Desktop/pokemoz/Oztirtle.gif')}
Charmandoz = {QTk.newImage photo(file:'/Users/charles/Desktop/pokemoz/Charmandoz.gif')}


% Création des images des Dresseurs
PersoPrincipalImage = {QTk.newImage photo(file:'/Users/charles/Desktop/pokemoz/persoPrincipal.gif')}
PersoPrincipalImageGrand = {QTk.newImage photo(file:'/Users/charles/Desktop/pokemoz/persoPrincipalGrand.gif')}
PersoSauvageImage = {QTk.newImage photo(file:'/Users/charles/Desktop/pokemoz/persoSauvage.gif')}
PersoSauvageImageGrand = {QTk.newImage photo(file:'/Users/charles/Desktop/pokemoz/persoSauvageGrand.gif')}


% Création des variables utililes pour la gestion de la fenêtre
HeightWidth=60
AddXY=HeightWidth div 2
WidthBetween= HeightWidth + HeightWidth div 6
N=7

%declaration des fonctions pour créer la map :)
proc{CreateMap Map Canvas}
   %premièrement pour faire une fonction récursif je préfère travailler en liste
   MapList
   %Fonction pour créer une ligne :)
   proc{CreateLine Line Canvas X Y}
      %Pour le moment j'ai un tuple r :)
      LineList
      %Création de la proc récursive pour dessiner les carrés :)
      proc {ProcRecursLine Line X Y}
	 case Line of nil then skip
	 [] T|H then
	    %dessiner le carré
	    if (T==1) then
	       {Canvas create(image X Y image:GrassImage)}
	    else
	       {Canvas create(image X Y image:RoadImage)}
	    end
	    %rappeler la fonction
	    {ProcRecursLine H X+WidthBetween Y}
	 end
      end
   in
      {Record.toList Line LineList}
      {ProcRecursLine LineList X Y}
   end
   %Création d'une fonction récursive pour créer la map
   proc{Create MapList Canvas X Y}
      case MapList of nil then skip
      [] T|H then
	 {CreateLine T Canvas X Y}
	 {Create H Canvas X Y+WidthBetween}
      end
   end
in
   {Record.toList Map MapList}
   {Create MapList Canvas 50 50}
end

%fonction pour Gérer tous les mouvements pour un personnage grave au atome moveUp moveDown moveLeft moveRight
proc{Move Perso Movement}
   CanvasPerso
in
   CanvasPerso = Perso.handle
   case Movement of nil then skip
   []moveUp then {CanvasPerso move(0 ~70)}
   []moveDown then {CanvasPerso move(0 70)}
   []moveLeft then {CanvasPerso move(~70 0)}
   []moveRight then {CanvasPerso move(70 0)}
   else
      {Show Movement}
   end
end



%Création de la map en QTk       (START THE GAME !!!) et retourne le canvas de la map !!! (important) % lui donner les fonctions correspondantes!
fun {StartGame Map MoveUpPrincipal MoveLeftPrincipal MoveDownPrincipal MoveRightPrincipal}
   CanvasMap
   WindowMap
   Desc
in
   Desc = td(title:"Pokemoz, the beginning of the end :) "
	     canvas(handle:CanvasMap width:(N-1)*WidthBetween+100 height:(N-1)*WidthBetween+100)
	     button(text:"Close" action:toplevel#close width:10))
   
   WindowMap = {QTk.build Desc}
   %C'est ici qu'on peut dessiner la map :)
   {CreateMap Map CanvasMap}
   {WindowMap show}

   % Affectation des touches au personnage principal
   {WindowMap bind(event:"<Up>" action:MoveUpPrincipal)}
   {WindowMap bind(event:"<Left>" action:MoveLeftPrincipal)}
   {WindowMap bind(event:"<Down>" action:MoveDownPrincipal)}
   {WindowMap bind(event:"<Right>" action:MoveRightPrincipal)}

   CanvasMap
end


%renvoie un nouveau Trainer
fun {CreatePerso Canvas Trainer}
   Photo
   Handle
   Perso
   X=Trainer.x
   Y=Trainer.y
in
   if (Trainer.type == wild ) then Photo = PersoSauvageImage
   elseif(Trainer.type == persoPrincipal) then Photo = PersoPrincipalImage
   else
      {Browse errorTypeNotRecognizedCreatePerso}
      {Browse Trainer}
      Photo = nil 
   end
   {Canvas create(image 50+(X-1)*WidthBetween 50+(Y-1)*WidthBetween image:Photo handle:Handle)}

   %Recreer le perso pour le retourner
   {Record.adjoin Trainer t(handle:Handle) Perso}
   Perso
end

%Fonction qui renvoie la photo du pokemoz portant le nom Name
fun {ChoosePhotoPokemoz Name}
   case Name of "Bulbasoz" then  Bulbasoz
   [] "Oztirtle" then  Oztirtle
   [] "Charmandoz" then Charmandoz
   else
      {Show "error, This pokemoz doens't exist"}
      nil
   end
end


% GESTION DES COMBATS

% Perso principale >< pokémon sauvage : 
declare
proc {AttackWildPokemoz  WindowCombat CanvasAttaquant CanvasPersoPrincipal Attaque Attaquant}
   PokemozAttaquantName
   PokemozPersoPrincipalName
   ImageCanvasPersoPrincipal
in
   case Attaquant of p(name:X) then PokemozAttaquantName = X end
   case Attaque of t(p:p(name:X)) then PokemozPersoPrincipalName=X end 
   % On peut mettre directement le pokemoz
   {CanvasAttaquant create(image 550 150 image:{ChoosePhotoPokemoz PokemozAttaquantName})}
   % Mettre l'image du dresseur pendant une seconde
   {CanvasPersoPrincipal create(image 150 150 image:PersoPrincipalImageGrand handle:ImageCanvasPersoPrincipal)}
   {Delay 3000}
   {ImageCanvasPersoPrincipal delete}
   {CanvasPersoPrincipal create(image 150 150 image:{ChoosePhotoPokemoz PokemozPersoPrincipalName})}
end

% Perso Principale >< autre dresseur
proc {AttackTrainer  WindowCombat CanvasAttaquant CanvasPersoPrincipal Attaque Attaquant}
   PokemozAttaquantName
   PokemozPersoPrincipalName
   ImageCanvasPersoPrincipal
   ImageCanvasPersoSauvage
in
   {CanvasPersoPrincipal create(image 150 150 image:PersoPrincipalImageGrand handle:ImageCanvasPersoPrincipal)}
   {CanvasAttaquant create(image 550 150 image:PersoSauvageImageGrand handle:ImageCanvasPersoSauvage)}
   {Delay 3000}
   case Attaquant of  t(p:p(name:X)) then PokemozAttaquantName = X end
   case Attaque of t(p:p(name:X)) then PokemozPersoPrincipalName=X end
   {CanvasPersoPrincipal create(image 150 150 image:{ChoosePhotoPokemoz PokemozPersoPrincipalName})}
   {CanvasAttaquant create(image 550 150 image:{ChoosePhotoPokemoz PokemozAttaquantName})}
   {ImageCanvasPersoPrincipal delete}
   {ImageCanvasPersoSauvage delete}
end

%fonctions générales
%Attaquant doit être soit un pokémon sauvage soit un dresseur !!
fun {StartCombat Attaque Attaquant}
   WindowCombat
   CanvasAttaquant
   CanvasPersoPrincipal
   PlaceHolder
   Combat = td(title:"Pokemoz, the fight can begin !"
	       canvas(handle:CanvasAttaquant width:700 height:300 bg:white)
	       canvas(handle:CanvasPersoPrincipal width:700 height:300 bg:white)
	       button(text:"Close" action:toplevel#close width:10 glue:we bg:white)
	      placeholder(handle:PlaceHolder))
   Label
in
   WindowCombat = {QTk.build Combat}
   {WindowCombat show(modal:true)}
   {Record.label Attaquant Label}
   case Label of p then {AttackWildPokemoz WindowCombat CanvasAttaquant CanvasPersoPrincipal Attaque Attaquant} 
   [] t then {AttackTrainer WindowCombat CanvasAttaquant CanvasPersoPrincipal Attaque Attaquant}
   else
      {Show "error StartCombat"}
   end
   thread
      {Delay 1000}
         %TODO tout est lancé il faut gérer le bouton attaquer !! (donc double attaque)
      {PlaceHolder set(lr(button(text:"Attack" action:proc{$} {Browse "Gérer le bouton attaquer"} end width:10)))}
   end
   combat(canvasAttaquant:CanvasAttaquant canvasPersoPrincipal:CanvasPersoPrincipal)
end


% Allow the user to choose his pokémon /TODO Modifier selon le functor renvoie un record start()
fun{Choose}
   Window
   %variable pour chaque pokémon et chacun aura un tag --> quand un est choisi on change son tag et on supprime tous ceux qui on l'autre tag
   BulbasozHandle
   BulbasozImage
   OztirtleHandle
   OztirtleImage
   CharmandozHandle
   CharmandozImage
   P S
   Select
   Choose = td(
	       lr(canvas(handle:BulbasozHandle width:300 height:300)
		  canvas(handle:OztirtleHandle width:300 height:300)
		  canvas(handle:CharmandozHandle width:300 height:300)))
in
   Window = {QTk.build Choose}
   {Window show}
   P={NewPort S}
   {BulbasozHandle create(image 150 150 image:Bulbasoz handle:BulbasozImage)}
   {BulbasozHandle bind(event:"<1>" action:proc{$} {OztirtleImage delete} {CharmandozImage delete} {Send P bulbasoz} end)}
   
   {OztirtleHandle create(image 150 150 image:Oztirtle handle:OztirtleImage)}
   {OztirtleHandle bind(event:"<1>" action:proc{$} {BulbasozImage delete} {CharmandozImage delete} {Send P oztirtle} end)}
   
   {CharmandozHandle create(image 150 150 image:Charmandoz handle:CharmandozImage)}
   {CharmandozHandle bind(event:"<1>" action:proc{$} {OztirtleImage delete} {BulbasozImage delete} {Send P charmandoz} end)}

   case S of X|T then
      {Delay 1000}
      {Window close}
      X
   end
end




% LET THE GAME START des variables des personnages
proc {Demo}
   PersoPrincipal
   CanvasMap
   Combat1
   Combat2

   %declarartion de la map et gestion du graphisme
   Map = map(r(1 1 1 0 0 0 0)
	     r(1 1 1 0 0 1 1)
	     r(1 1 1 0 0 1 1)
	     r(0 0 0 0 0 1 1)
	     r(0 0 0 1 1 1 1)
	     r(0 0 0 1 1 0 0)
	     r(0 0 0 0 0 0 0))
   % Fonction pour les mouvements du personnage principal !!Attention à modifier avec les fonctions de Jérôme :)
   proc {MoveUpPrincipal}
      {Show appelMoveUp}
      {Move PersoPrincipal moveUp}
   end
   proc {MoveDownPrincipal}
      {Move PersoPrincipal moveDown}
   end
   proc {MoveLeftPrincipal}
      {Move PersoPrincipal moveLeft}
   end
   proc {MoveRightPrincipal}
      {Move PersoPrincipal moveRight}
   end
in
   %La création de la map doit toujours se faire avant les perso
   CanvasMap = {StartGame Map MoveUpPrincipal MoveLeftPrincipal MoveDownPrincipal MoveRightPrincipal}
   {Delay 1000}
   PersoPrincipal={CreatePerso CanvasMap t(name:"I m the best :p" type:persoPrincipal x:7 y:7)} %Perso principal doit commencer en 7 7
   PersoSecondaire={CreatePerso CanvasMap t(name:"I m the second but as wild as the worst:p" type:wild x:2 y:6)}

   %exemple de début de combat contre un pokémon sauvage
   Combat1 = {StartCombat t(p:(p(name:"Bulbasoz"))) p(name:"Oztirtle")}

   %exemple de combat contre un personnage
   Combat2 = {StartCombat t(p:p(name:"Bulbasoz")) t(p:p(name:"Charmandoz"))}
end





%tuto
declare
[Prototyper] = {Module.link ["x-oz://system/wp/Prototyper.ozf"]}
{Prototyper.run}
