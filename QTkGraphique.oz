%Declaration QTk
declare
[QTk] = {Module.link ['x-oz://system/wp/QTk.ozf']}

% Création des images pour l'herbe et la route avec leur Tag (je ne sais pas si ça va être utile par la suite :) )
GrassImage = {QTk.newImage photo(file:'/Users/charles/Desktop/pokemoz/herbe.gif')}
GrassTag
RoadImage = {QTk.newImage photo(file:'/Users/charles/Desktop/pokemoz/chemin.gif')}
RoadTag

% Création des images des pokémons (TODO Ajouter les pokémons)
Bulbasoz = {QTk.newImage photo(file:'/Users/charles/Desktop/pokemoz/Bulbasoz.gif')}
Oztirtle = {QTk.newImage photo(file:'/Users/charles/Desktop/pokemoz/Oztirtle.gif')}
Charmandoz = {QTk.newImage photo(file:'/Users/charles/Desktop/pokemoz/Charmandoz.gif')}


% Création des images des Dresseurs (Todo Ajouter les dresseurs sauvages)


% Création des variables des personnages 
PersoPrincipal


% Création des variables utilile pour la gestion de la fenêtre
HeightWidth=60
AddXY=HeightWidth div 2
WidthBetween= HeightWidth + HeightWidth div 6
N=7

%declarartion de la map et gestion du graphisme
declare
Map = map(r(1 1 1 0 0 0 0)
	  r(1 1 1 0 0 1 1)
	  r(1 1 1 0 0 1 1)
	  r(0 0 0 0 0 1 1)
	  r(0 0 0 1 1 1 1)
	  r(0 0 0 1 1 0 0)
	  r(0 0 0 0 0 0 0))

CanvasMap
WindowMap
Desc = td(title:"Pokemoz, the beginning of the end :) "
	  canvas(handle:CanvasMap width:(N-1)*WidthBetween+100 height:(N-1)*WidthBetween+100 glue:nswe))

%declaration des fonctions pour créer la map :)
declare
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
	       {Canvas create(image X Y image:GrassImage tag:grassTag)}
	    else
	       {Canvas create(image X Y image:RoadImage tag:roadTag)}
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
declare  
proc{Move Perso Movement}
   case Movement of nil then skip
   []moveUp then {Perso move(0 ~70)}
   []moveDown then {Perso move(0 70)}
   []moveLeft then {Perso move(~70 0)}
   []moveRight then {Perso move(70 0)}
   else
      {Show Movement}
   end
end


% Fonction pour les mouvements du personnage principal !!Attention à modifier avec les fonctions de Jérôme :)
proc {MoveUpPrincipal}
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


%Création de la map en QTk       (START THE GAME !!!)
declare
proc {StartGame}
   WindowMap = {QTk.build Desc}
   %C'est ici qu'on peut dessiner la map :)
   {CreateMap Map CanvasMap}
   %Création de Tag pour l'herbe et la route
   GrassTag={CanvasMap newTag($)}
   RoadTag={CanvasMap newTag($)}
   {WindowMap show}

   %TODO Implémenter les options ! (CheckBox + quitter)

   % Affectation des touches au personnage principal
   {WindowMap bind(event:"<Up>" action:MoveUpPrincipal)}
   {WindowMap bind(event:"<Left>" action:MoveLeftPrincipal)}
   {WindowMap bind(event:"<Down>" action:MoveDownPrincipal)}
   {WindowMap bind(event:"<Right>" action:MoveRightPrincipal)}
end



%creation du perso principal le nom du fichier doit correspondre au nom du perso
declare
fun {CreatePersoPrincipal Canvas}
   Photo = {QTk.newImage photo(file:'/Users/charles/Desktop/pokemoz/persoPrincipal.gif')}
   Perso
in
   {Canvas create(image 50+6*70 50+6*70 image:Photo handle:Perso)}
   Perso
end






% GESTION DES COMBATS, fonctions générales
%Attaquant doit être soit un pokémon sauvage soit un dresseur !!
declare
proc {StartCombat Attaquant}
   WindowCombat
   CanvasCombat
   Combat = td(title:"Pokemoz, the fight can begin !"
	       canvas(handle:CanvasCombat width:500 height:500))
in
   WindowCombat = {QTk.build Combat}
   {WindowCombat show} 
end

% Perso principale >< pokémon sauvage : TODO implémeneter

% Perso Principale >< autre dresseur







% LET THE GAME START
{StartGame}
{Delay 1000}
PersoPrincipal={CreatePersoPrincipal CanvasMap}

{StartCombat nil}







%tuto
declare
[Prototyper] = {Module.link ["x-oz://system/wp/Prototyper.ozf"]}
{Prototyper.run}
