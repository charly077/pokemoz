%Declaration QTk
declare
[QTk] = {Module.link ['x-oz://system/wp/QTk.ozf']}

% Création des images pour l'herbe et la route avec leur Tag (je ne sais pas si ça va être utile par la suite :) )
GrassImage = {QTk.newImage photo(file:'/Users/charles/Desktop/pokemoz/herbe.gif')}
GrassTag
RoadImage = {QTk.newImage photo(file:'/Users/charles/Desktop/pokemoz/chemin.gif')}
RoadTag

% Création des images des pokémons (TODO Ajouter les pokémons et les mettre à la bonne taille !! pk pas orientation)
Bulbasoz = {QTk.newImage photo(file:'/Users/charles/Desktop/pokemoz/Bulbasoz.gif')}
Oztirtle = {QTk.newImage photo(file:'/Users/charles/Desktop/pokemoz/Oztirtle.gif')}
Charmandoz = {QTk.newImage photo(file:'/Users/charles/Desktop/pokemoz/Charmandoz.gif')}


% Création des images des Dresseurs (Todo Ajouter les dresseurs Grande image 300/300 pour perso principal)
PersoPrincipalImage = {QTk.newImage photo(file:'/Users/charles/Desktop/pokemoz/persoPrincipal.gif')}
PersoPrincipalImageGrand = {QTk.newImage photo(file:'/Users/charles/Desktop/pokemoz/persoPrincipalGrand.gif')}
PersoSauvage = {QTk.newImage photo(file:'/Users/charles/Desktop/pokemoz/persoSauvage.gif')}
PersoSauvageGrand = {QTk.newImage photo(file:'/Users/charles/Desktop/pokemoz/persoSauvageGrand.gif')}


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
	  canvas(handle:CanvasMap width:(N-1)*WidthBetween+100 height:(N-1)*WidthBetween+100)
	  button(text:"Close" action:toplevel#close))

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
   Photo = PersoPrincipalImage
   Perso
in
   {Canvas create(image 50+6*70 50+6*70 image:Photo handle:Perso)}
   Perso
end

%Fonction qui renvoie la photo du pokémoz portant le nom Name
declare
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

% Perso principale >< pokémon sauvage : TODO implémeneter
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
   {CanvasAttaquant create(image 550 150 image:PersoSauvageGrand handle:ImageCanvasPersoSauvage)}
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
declare
proc {StartCombat Attaque Attaquant}
   WindowCombat
   CanvasAttaquant
   CanvasPersoPrincipal
   Combat = td(title:"Pokemoz, the fight can begin !"
	       canvas(handle:CanvasAttaquant width:700 height:300)
	       canvas(handle:CanvasPersoPrincipal width:700 height:300)
	       button(text:"Close" action:toplevel#close))
   Label
in
   WindowCombat = {QTk.build Combat}
   {WindowCombat show} %show(wait:true modal:true)}
   {Record.label Attaquant Label}
   case Label of p then {AttackWildPokemoz WindowCombat CanvasAttaquant CanvasPersoPrincipal Attaque Attaquant} 
   [] t then {AttackTrainer WindowCombat CanvasAttaquant CanvasPersoPrincipal Attaque Attaquant}
   else
      {Show "error StartCombat"}
   end

   %TODO tout est lancé il faut gérer le bouton attaquer !! (donc double attaque)
end








% LET THE GAME START
{StartGame}
{Delay 1000}
PersoPrincipal={CreatePersoPrincipal CanvasMap}

{StartCombat t(p:(p(name:"Bulbasoz"))) p(name:"Oztirtle")}

{StartCombat t(p:p(name:"Bulbasoz")) t(p:p(name:"Charmandoz"))}







%tuto
declare
[Prototyper] = {Module.link ["x-oz://system/wp/Prototyper.ozf"]}
{Prototyper.run}
