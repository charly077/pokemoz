%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% Pokemoz %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%% Explications générales %%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Premièrement, nous avons séparé notre code en trois grandes parties,
% La première comprend tout ce qui est en rapport avec l'interface
% graphique. Ensuite nous avons implémenté toutes les fonctions pour
% le jeux en lui même.
% Enfin, la dernière partie est le démarrage du jeux.
%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% PREMIERE PARTIE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Gestion de l'interface graphique
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% Déclaration des variables de base %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
declare
%Declaration QTk
[QTk] = {Module.link ['x-oz://system/wp/QTk.ozf']}

GrassImage = {QTk.newImage photo(file:'/Users/jeromelemaire/Desktop/EPL/Q6/OZ/Projet/pokemoz/herbe.gif')}
RoadImage = {QTk.newImage photo(file:'/Users/jeromelemaire/Desktop/EPL/Q6/OZ/Projet/pokemoz/chemin.gif')}

% Création des images des pokémons
Bulbasoz = {QTk.newImage photo(file:'/Users/jeromelemaire/Desktop/EPL/Q6/OZ/Projet/pokemoz/Bulbasoz.gif')}
Oztirtle = {QTk.newImage photo(file:'/Users/jeromelemaire/Desktop/EPL/Q6/OZ/Projet/pokemoz/Oztirtle.gif')}
Charmandoz = {QTk.newImage photo(file:'/Users/jeromelemaire/Desktop/EPL/Q6/OZ/Projet/pokemoz/Charmandoz.gif')}


% Création des images des Dresseurs
PersoPrincipalImage = {QTk.newImage photo(file:'/Users/jeromelemaire/Desktop/EPL/Q6/OZ/Projet/pokemoz/persoPrincipal.gif')}
PersoPrincipalImageGrand = {QTk.newImage photo(file:'/Users/jeromelemaire/Desktop/EPL/Q6/OZ/Projet/pokemoz/persoPrincipalGrand.gif')}
PersoSauvageImage = {QTk.newImage photo(file:'/Users/jeromelemaire/Desktop/EPL/Q6/OZ/Projet/pokemoz/persoSauvage.gif')}
PersoSauvageImageGrand = {QTk.newImage photo(file:'/Users/jeromelemaire/Desktop/EPL/Q6/OZ/Projet/pokemoz/persoSauvageGrand.gif')}



% % Création des images 
% GrassImage = {QTk.newImage photo(file:'/Users/charles/Desktop/pokemoz/herbe.gif')}
% RoadImage = {QTk.newImage photo(file:'/Users/charles/Desktop/pokemoz/chemin.gif')}

% % Création des images des pokémons
% Bulbasoz = {QTk.newImage photo(file:'/Users/charles/Desktop/pokemoz/Bulbasoz.gif')}
% Oztirtle = {QTk.newImage photo(file:'/Users/charles/Desktop/pokemoz/Oztirtle.gif')}
% Charmandoz = {QTk.newImage photo(file:'/Users/charles/Desktop/pokemoz/Charmandoz.gif')}


% % Création des images des Dresseurs
% PersoPrincipalImage = {QTk.newImage photo(file:'/Users/charles/Desktop/pokemoz/persoPrincipal.gif')}
% PersoPrincipalImageGrand = {QTk.newImage photo(file:'/Users/charles/Desktop/pokemoz/persoPrincipalGrand.gif')}
% PersoSauvageImage = {QTk.newImage photo(file:'/Users/charles/Desktop/pokemoz/persoSauvage.gif')}
% PersoSauvageImageGrand = {QTk.newImage photo(file:'/Users/charles/Desktop/pokemoz/persoSauvageGrand.gif')}

% Création des variables utililes pour la gestion de la fenêtre
HeightWidth=60
AddXY=HeightWidth div 2
WidthBetween= HeightWidth + HeightWidth div 6
N=7

Proba = 50


GrassCombat % car la fonction est utilisée avant d'être définie
MapTrainers Map % Pour gérer les map
%% Variables initiales
Names = names("Jean" "Sacha" "Ondine" "Pierre")
Pokemozs = pokemozs("Bulbasoz" "Oztirtle" "Charmandoz")

Types = types(fire water grass)
Wilds

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% Création graphique de la map %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
proc{CreateMapGraphique Map Canvas}
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% Gestion graphique des mouvements %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% Démarrage de la map et du jeux %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% C'est cette fonction qui doit être appellée pour démarrer le jeux
%
% Pre : - Map, un record de type map
%       - MoveUpPrincipal MoveLeftPrincipal MoveDownPrincipal
%         MoveRightPrincipal, les fonctions utilisée pour déplacer
%         un personnage
%
%Post : Renvoie le Canvas de la Map, il est utilile pour d'autres
%       Fonctions
fun {StartGame Map MoveUpPrincipal MoveLeftPrincipal MoveDownPrincipal MoveRightPrincipal}
   CanvasMap
   WindowMap
   Desc
in
   Desc = td(title:"Pokemoz, the beginning of the end :) "
	     canvas(handle:CanvasMap width:(N-1)*WidthBetween+100 height:(N-1)*WidthBetween+100)
	     button(text:"Close" action:toplevel#close width:10))
   
   WindowMap = {QTk.build Desc}

   % Appel de la fonction qui va dessiner la map
   {CreateMapGraphique Map CanvasMap}
   {WindowMap show}

   % Affectation des touches au mouvement du personnage principal
   {WindowMap bind(event:"<Up>" action:MoveUpPrincipal)}
   {WindowMap bind(event:"<Left>" action:MoveLeftPrincipal)}
   {WindowMap bind(event:"<Down>" action:MoveDownPrincipal)}
   {WindowMap bind(event:"<Right>" action:MoveRightPrincipal)}

   CanvasMap
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% Gestion des personnages %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Pre : - Canvas, le canva obtenu grâce à la fonction StartGame
%       - Trainer, un dresseur qui n'a pas encore été initialisé
%         graphiquement. Celui-ci doit obligatoirement avoir un type
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

% Petite fonction indépendante pour trouver la photo du pokemoz
fun {ChoosePhotoPokemoz Name}
   case Name of "Bulbasoz" then  Bulbasoz
   [] "Oztirtle" then  Oztirtle
   [] "Charmandoz" then Charmandoz
   else
      {Show "error, This pokemoz doens't exist"}
      nil
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% GESTION DES COMBATS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% On démarre avec la fonction StartCombat, qui renvoie un record
% combat(canvasAttaquant:CanvasAttaquant
%                          canvasPersoPrincipal:CanvasPersoPrincipal)
% Ce record permet, d'avoir accès aux variables, dans un cas préventif
% Cette fonction permet de gérer les combat
%
% Pre: - Attaque est un recorde de type t, et doit être le perso principal
%      - Attaquant, soit un record de type p, si l'attaquant est un
%                                             pokémoz
%                   soit un record de type t, si l'attaquant est un
%                                             dresseur
%

% Perso principal >< pokémoz sauvage
proc {AttackWildPokemoz  WindowCombat CanvasAttaquant CanvasPersoPrincipal Attaque Attaquant}
   PokemozAttaquantName
   PokemozPersoPrincipalName
   ImageCanvasPersoPrincipal
   X
in
   PokemozAttaquantName = Attaquant.name
   {Send Attaque.p getState(X)}
   PokemozPersoPrincipalName = X.name 
   % On peut mettre directement le pokemoz
   {CanvasAttaquant create(image 550 150 image:{ChoosePhotoPokemoz PokemozAttaquantName})}
   % Mettre l'image du dresseur pendant une seconde
   {CanvasPersoPrincipal create(image 150 150 image:PersoPrincipalImageGrand handle:ImageCanvasPersoPrincipal)}
   {Delay 3000}
   {ImageCanvasPersoPrincipal delete}
   {CanvasPersoPrincipal create(image 150 150 image:{ChoosePhotoPokemoz PokemozPersoPrincipalName})}
end

% Perso principal >< autre dresseur
proc {AttackTrainer  WindowCombat CanvasAttaquant CanvasPersoPrincipal Attaque Attaquant}
   PokemozAttaquantName
   PokemozPersoPrincipalName
   ImageCanvasPersoPrincipal
   ImageCanvasPersoSauvage
in
   {CanvasPersoPrincipal create(image 150 150 image:PersoPrincipalImageGrand handle:ImageCanvasPersoPrincipal)}
   {CanvasAttaquant create(image 550 150 image:PersoSauvageImageGrand handle:ImageCanvasPersoSauvage)}
   {Delay 3000} % Permet de laisser les perso 3 secondes
   case Attaquant of  t(p:Z) then X in {Send Z getState(X)} PokemozAttaquantName = X.name end
   case Attaque of t(p:Z) then X in {Send Z getState(X)} PokemozPersoPrincipalName=X.name end
   {CanvasPersoPrincipal create(image 150 150 image:{ChoosePhotoPokemoz PokemozPersoPrincipalName})}
   {CanvasAttaquant create(image 550 150 image:{ChoosePhotoPokemoz PokemozAttaquantName})}
   {ImageCanvasPersoPrincipal delete}
   {ImageCanvasPersoSauvage delete}
end

%P est un port qui permet de savoir que le bouton attack à été appuyé
fun {StartCombat Attaque AttaquantPort P}
   WindowCombat
   CanvasAttaquant
   CanvasPersoPrincipal
   PlaceHolder
   LabelAttaquant
   LabelPersoPrincipal
   %Attaque
   Attaquant
   Combat = td(title:"Pokemoz, the fight can begin !"
	       label(handle:LabelAttaquant glue:e)
	       canvas(handle:CanvasAttaquant width:700 height:300 bg:white)
	       canvas(handle:CanvasPersoPrincipal width:700 height:300 bg:white)
	       label(handle:LabelPersoPrincipal glue:w)
	       placeholder(handle:PlaceHolder))
   Label
in
   WindowCombat = {QTk.build Combat}
   {WindowCombat show(modal:true)}
   {Send AttaquantPort getState(Attaquant)}
   %{Send AttaquePort getState(Attaque)}
   {Record.label Attaquant Label}
   case Label of p then {AttackWildPokemoz WindowCombat CanvasAttaquant CanvasPersoPrincipal Attaque Attaquant} 
   [] t then {AttackTrainer WindowCombat CanvasAttaquant CanvasPersoPrincipal Attaque Attaquant}
   else
      {Show "error StartCombat"}
   end
   thread
      {Delay 1000}
         %TODO tout est lancé il faut gérer le bouton attaquer !! (donc double attaque)
      {PlaceHolder set(lr(button(text:"Attack" action:proc{$} {Send P attack} end width:10)  button(text:"Close" action:toplevel#close width:10 glue:we bg:white)))}
   end
   combat(canvasAttaquant:CanvasAttaquant labelAttaquant:LabelAttaquant canvasPersoPrincipal:CanvasPersoPrincipal labelPersoPrincipal:LabelPersoPrincipal)
end


proc {SetCombatState Combat StateAttaque StateAttaquant}
   fun{CreateString List}
      case List of nil then nil
      [] X|L then
	 case X of nil then {CreateString L}
	 [] T|H then T|{CreateString H|L}
	 end
      end
   end
   % Création du message de l'attaqué
   Xp1 MsgAttaquant Hp1
   Xp2 MsgAttaque Hp2
in
   {Int.toString StateAttaquant.xp  Xp1}
   {Int.toString StateAttaquant.hp  Hp1}
   
   MsgAttaquant = {CreateString [ "Name : " StateAttaquant.name " xp : " Xp1 " HP : " Hp1]}
   %Création du Message de l'attaquant
   {Int.toString StateAttaque.xp  Xp2}
   {Int.toString StateAttaque.hp  Hp2}
   
   MsgAttaque = {CreateString [ "Name : " StateAttaque.name " xp : " Xp2 " HP : " Hp2]}
   
   {Combat.labelAttaquant set(MsgAttaquant)}
   {Combat.labelPersoPrincipal set(MsgAttaque)}
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% Choisir un pokémon avant de commencer %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fun{Choose}
   Window
   BulbasozHandle
   BulbasozImage
   OztirtleHandle
   OztirtleImage
   CharmandozHandle
   CharmandozImage
   P S
   Select
   Choose = td(lr(canvas(handle:BulbasozHandle width:300 height:300)
		  canvas(handle:OztirtleHandle width:300 height:300)
		  canvas(handle:CharmandozHandle width:300 height:300)))
in
   Window = {QTk.build Choose}
   {Window show}
   P={NewPort S}
   {BulbasozHandle create(image 150 150 image:Bulbasoz handle:BulbasozImage)}
   {BulbasozHandle bind(event:"<1>" action:proc{$} {OztirtleImage delete} {CharmandozImage delete} {Send P "Bulbasoz"} end)}
   
   {OztirtleHandle create(image 150 150 image:Oztirtle handle:OztirtleImage)}
   {OztirtleHandle bind(event:"<1>" action:proc{$} {BulbasozImage delete} {CharmandozImage delete} {Send P "Oztirtle"} end)}
   
   {CharmandozHandle create(image 150 150 image:Charmandoz handle:CharmandozImage)}
   {CharmandozHandle bind(event:"<1>" action:proc{$} {OztirtleImage delete} {BulbasozImage delete} {Send P "Charmandoz"} end)}

   case S of X|T then
      {Delay 1000}
      {Window close}
      X
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% TEST ET DEMONSTRATION DE LA PREMIERE PARTIE %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
proc {Demo}
   PersoPrincipal
   PersoSecondaire
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

   %TODO Changer les deux exemple suivant car ça doit être des PokemozPort
   %exemple de début de combat contre un pokémon sauvage
%   Combat1 = {StartCombat t(p:(p(name:"Bulbasoz"))) p(name:"Oztirtle")}

   %exemple de combat contre un personnage
%   Combat2 = {StartCombat t(p:p(name:"Bulbasoz")) t(p:p(name:"Charmandoz"))}
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% DEUXIEME PARTIE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cette partie du projet est divise en trois grandes parties, "classes",
% grace a l'utilisation des NewPortObject.
%
% Les trois "classes" sont les suivantes : Trainers, Maps et Pokemoz 
%
%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% Fonctions de base %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Port object abstraction
% Init = initial state
% Func = function: (Msg x State) -> State

fun {NewPortObject Func Init}
   proc {Loop S State}
      case S of Msg|S2 then
	 {Loop S2 {Func Msg State}}
      end
   end
   S
in
   thread {Loop S Init} end % Port object is sequential internally
   {NewPort S}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% Gestion Map %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Il y a deux représentations de la map, une pour les hautes herbes
% et une pour localiser les dresseurs.
% Les maps sont represente sous forme de record
% La structure d'une map des hautes herbes est la suivante :
% MapH = map(r(1 1 1 0 0 0 0)
%	  r(1 1 1 0 0 1 1)
%	  r(1 1 1 0 0 1 1)
%	  r(0 0 0 0 0 1 1)
%	  r(0 0 0 1 1 1 1)
%	  r(0 0 0 1 1 0 0)
%	  r(0 0 0 0 0 0 0))
% où le chiffre 1 represente les cases avec des hautes herbes et
% le chiffre 0 represente le chemin
%
%La structure d'une map contenant la position des dresseurs :
%Map = map(r(1 1 1 0 0 0 0)
%	  r(1 1 1 0 0 1 1)
%	  r(1 1 1 0 0 1 1)
%	  r(0 0 0 0 0 1 1)
%	  r(0 0 0 1 1 1 1)
%	  r(0 0 0 1 1 0 0)
%	  r(0 0 0 0 0 0 0))
% où le chiffre 1 représente les cases où se situe les dresseurs et
% le chiffre 0 represente les cases vides
% Nous avons decide que les dresseurs pouvaient se trouver dans les hautes herbes.
%

% Fonction de creation d'un record map
fun{CreateEmptyMap}
   map(r(0 0 0 0 0 0 0)
       r(0 0 0 0 0 0 0)
       r(0 0 0 0 0 0 0)
       r(0 0 0 0 0 0 0)
       r(0 0 0 0 0 0 0)
       r(0 0 0 0 0 0 0)
       r(0 0 0 0 0 0 0))
end
fun{CreateMap}
   map(r(1 1 1 0 0 0 0)
       r(1 1 1 0 0 1 1)
       r(1 1 1 0 0 1 1)
       r(0 0 0 0 0 1 1)
       r(0 0 0 1 1 1 1)
       r(0 0 0 1 1 0 0)
       r(0 0 0 0 0 0 0))
end

% Verifie si la case de coordonnee (X,Y) appartient à la map

fun {Checkin X Y MapState}
    if {And (Y>0) (Y=<{Width MapState})} then {And (X>0) (X=<{Width MapState})}
    else false
    end
end

% Verifie si la case de coordonnee (X,Y) appartien à la map et est vide

fun {Check X Y MapState}
   if {Checkin X Y MapState} then MapState.Y.X==0
   else false
   end
end



% Fonction qui modifie les coordonnee (X,Y) de la Map Init
fun {SetMap X Y Init}
   if {Check X Y Init} then {AdjoinAt Init Y {AdjoinAt Init.Y X (Init.Y.X)+1}}
   else {AdjoinAt Init Y {AdjoinAt Init.Y X (Init.Y.X)-1}}
   end
end

% 

%%%%%%%%%%%%% fonction mere Map %%%%%%%%%%%%%%%%%%
fun {FMap Msg MapState}
   case Msg
   of  setMap(X Y) then {SetMap X Y MapState}
   [] check(X Y B) then B={Check X Y MapState} MapState
   [] checkin(X Y B) then B={Checkin X Y MapState} MapState
   [] get(X) then X=MapState MapState 
   end
end



MapTrainers={NewPortObject FMap {CreateEmptyMap}}
Map={NewPortObject FMap {CreateMap}}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% Gestion Pokemoz %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Le pokemoz represente l'etat du pokemon en temps réel avant,
% durant et apres un combat.
%
% Un Pokemoz est represente sous la forme de d'un record dont
% la structure est :
% Pokemoz = p(type:_ name:_ hp:_ lx:_ xp:_)

%%%%%%%%%%%%% Gestion création Pokemoz %%%%%%%%%%%%%%%

fun{CreatePokemoz Type Name Hp Lx}
   p(type:Type name:Name hp:Hp lx:Lx xp:0)
end


fun{CreatePokemoz5 Name}
   Type in
   case Name of "Bulbasoz" then Type=grass
   [] "Oztirtle" then Type=water
   [] "Charmandoz" then Type=fire
   end
   p(type:Type name:Name hp:20 lx:5 xp:0)
end

Wilds = pokemozs({NewPortObject FPokemoz {CreatePokemoz5 "Bulbasoz"}} {NewPortObject FPokemoz {CreatePokemoz5 "Oztirtle"}} {NewPortObject FPokemoz {CreatePokemoz5 "Charmandoz"}})


fun{CreateRandPokemoz}
   Type Name Hp Lx in
   Name=Pokemozs.(({OS.rand} mod {Width Pokemozs})+1)
   case Name of "Bulbasoz" then Type=grass
   [] "Oztirtle" then Type=water
   [] "Charmandoz" then Type=fire
   end
   Lx=5+ {OS.rand} mod 5
   Hp=20 +2*(Lx-5)
   p(type:Type name:Name hp:Hp lx:Lx xp:0)
end


fun{LevelRand Lx}
   case Lx of 5 then 5+({OS.rand} mod 2)
   [] 6 then 5+({OS.rand} mod 3)
   [] 7 then 5+({OS.rand} mod 5)
   else 5+({OS.rand} mod 6)
   end
end      


fun{CreatePokemozTrainer T}
   Type Name Hp Lx Trainer Pokemoz in
   {Send T get(Trainer)}
   {Send Trainer.p get(Pokemoz)}
   Name=Pokemozs.(({OS.rand} mod {Width Pokemozs})+1)
   case Name of "Bulbasoz" then Type=grass
   [] "Oztirtle" then Type=water
   [] "Charmandoz" then Type=fire
   end
   Lx={LevelRand Pokemoz.lx}
   Hp=20 +2*(Lx-5)
   p(type:Type name:Name hp:Hp lx:Lx xp:0)
end



   
	       


%%%%%%%%%%%%%%%% Gestion Xp et Level %%%%%%%%%%%%%%%%%


fun {SetLx Init X}
   {AdjoinAt Init lx (Init.lx)+X}
end


fun {SetXp Init X}
   {AdjoinAt Init xp (Init.xp)+X}
end


fun {SetHp Init X}
   {AdjoinAt Init hp (Init.hp)-X}
end



fun {LevelUp Init}
   case Init.lx of 5 then if Init.xp>5 then {AdjoinList Init [xp#(Init.xp mod 5) lx#6 hp#22]}  else Init end
   [] 6 then if Init.xp>12 then {AdjoinList Init [xp#(Init.xp mod 12) lx#7 hp#24]}  else Init end
   [] 7 then if Init.xp>20 then {AdjoinList Init [xp#(Init.xp mod 20) lx#8 hp#26]}  else Init end
   [] 8 then if Init.xp>30 then {AdjoinList Init [xp#(Init.xp mod 30) lx#9 hp#28]}  else Init end
   [] 9 then if Init.xp>50 then {AdjoinList Init [xp#(Init.xp mod 50) lx#10 hp#30]}  else Init end
   [] 10 then Init   end
   
end

fun {SetHpMax State}
   case State.lx of 5 then {Record.adjoin State p(hp:20) $}
   [] 6 then {Record.adjoin State p(hp:22) $}
   [] 7 then {Record.adjoin State p(hp:24) $}
   [] 8 then {Record.adjoin State p(hp:26) $}
   [] 9 then {Record.adjoin State p(hp:28) $}
   [] 10 then {Record.adjoin State p(hp:30) $}
   end
end


fun {AttackBy Y Init} Attaquant in {Send Y get(Attaquant)}
   case Init.type
   of fire then case Attaquant.type
		of fire then {AdjoinAt Init hp ((Init.hp)-2)}
		[] water then {AdjoinAt Init hp ((Init.hp)-3)}
		[] grass then {AdjoinAt Init hp ((Init.hp)-1)}
		end
   [] grass then  case Attaquant.type
		  of fire then {AdjoinAt Init hp ((Init.hp)-3)}
		  [] water then {AdjoinAt Init hp ((Init.hp)-1)}
		  [] grass then {AdjoinAt Init hp ((Init.hp)-2)}
		  end
   [] water then  case Attaquant.type
		  of fire then {AdjoinAt Init hp ((Init.hp)-1)}
		  [] water then {AdjoinAt Init hp ((Init.hp)-2)}
		  [] grass then {AdjoinAt Init hp ((Init.hp)-3)}
		  end	  
   end
end


fun{Attack Y Init}
   X in {Send Y get(X)}
   ((((6+X.lx-Init.lx)*9))>({OS.rand} mod 100))
end


fun{UpdateXp Perdant Status}
   {AdjoinAt Status xp ((Status.xp)+(Perdant.lx))}
end



fun{GagneContre Y Status}
   Perdant in {Send Y get(Perdant)}
   {LevelUp {UpdateXp Perdant Status}}
end

%%%% Fonction pour faire évoluer les wilds pokemoz %%%%%%
proc {WildsXpAdd Wilds DelayToApply}
   Width = {Record.width Wilds}
   proc {Recursion Wilds Width}
      {Delay DelayToApply}
      {Recurs Wilds Width}
      {Recursion Wilds Width}
   end
   proc {Recurs Wilds N}
      if (N>0) then Rand in 
	 %Une fois de temps en temps, ajouter des xp !
	 Rand = {OS.rand} mod 1000
	 if (Rand < 100 ) then
	    {Browse "Remise d'xp à"}
	    {Browse {Send Wilds.N getState($)}}
	    {Send Width.N addXp(1)}
	    {Send Width.N levelup}
	 end
      end
   end
in
   {Recurs Wilds Width}
end
   


%%%%%%%%%%%%% Fonction mere Pokemoz %%%%%%%%%%%%%%%%%%


fun{FPokemoz Msg State}
   case Msg
   of sethp(X) then {SetHp State X} 
   [] setlx(X) then {SetLx State X} 
   [] setxp(X) then {SetXp State X}
   [] addXp(X) then {SetXp State (State.xp + X)}
   [] setHpMax() then {SetHpMax State}
   [] levelup then {LevelUp State}
   [] get(X) then X=State State
   [] getState(StateR) then StateR=State State
   [] getHp(Hp) then Hp=State.hp State
   [] attack(Y Succeed) then Succeed={Attack Y State} State
   [] attackedBy(Y) then {AttackBy Y State}
   [] stillAlife(B) then B=(State.hp>0) State
   [] gagneContre(Y) then {GagneContre Y State}
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% Gestion Trainers %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Le trainer represente les dresseurs se situant sur la carte et 
% les actions qu'il peut effectuer en fonction d'ou il se trouve
% sur la map.
%
% Un trainer est represente sous la forme de d'un record dont
% la structure est :
% Trainer = t(p:_ speed:_ auto:_ x:X y:Y handle:_ type:wild/persoPrincipal name:Name)
%
%type : est un atom
%
%
%

%%%%%%%%%%%%%%%%% Fonctions de créations de Trainers %%%%%%%%%%%%%%%%

%Wilds = pokemozs({NewPortObject FPokemoz {CreatePokemoz5 "Bulbasoz"}} {NewPortObject FPokemoz {CreatePokemoz5 "Oztirtle"}} {NewPortObject FPokemoz {CreatePokemoz5 "Charmandoz"}})

%Creation d'un record trainer spécifique

fun {CreateTrainer Name Pokemoz X Y Speed Type Canvas}
   local B in {Send MapTrainers check(X Y B)} %% attention eviter les dresseurs en bas à droit et en haut à droite
      if B then {Send MapTrainers setMap(X Y)} {CreatePerso Canvas trainer(name:Name p:Pokemoz x:X y:Y speed:Speed auto:0 type:Type)}
      else {CreateTrainer Name Pokemoz ({OS.rand} mod 7)+1 ({OS.rand} mod 7)+1 Speed Type Canvas}
      end
   end
end


% Création d'un record trainer sauvage aleatoire
fun {CreateRandTrainer  Speed Number Canvas}
   local Name X Y Pokemoz Type in
      Name = Names.Number
      Pokemoz = {NewPortObject FPokemoz {CreatePokemoz5 Pokemozs.(({OS.rand} mod {Width Pokemozs})+1)}} 
      X=({OS.rand} mod 7)+1
      Y=({OS.rand} mod 7)+1
      Type= wild
      {CreateTrainer Name Pokemoz X Y Speed Type Canvas}
   end
end


%Creation d'un record trainers contenant des trainers aleatoires
fun{CreateOtherTrainer Number Speed Canvas}
   local R
      fun{CreateOtherTrainers Number Speed Trainers Canvas}
	 if Number>0 then {CreateOtherTrainers Number-1 Speed {AdjoinAt Trainers Number {CreateRandTrainer Number  Speed Canvas}} Canvas}
	 else Trainers
	 end
      end
      in {MakeRecord trainers [1] R}
	 {CreateOtherTrainers Number Speed R Canvas}	 
      end
end

%%%%%%%%%%%%%%%%%%%%%% Gestion de combat %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% X doit être le portObject perso principal
% Y doit être le portObject pokémoz sauvage
%

%TODO TEST DES DEUX FONCTIONS
proc{CombatWild StateX Y}
   % La les variable doivent être 2 pokemoz
   proc{CombatRec X Y S Combat}
      P1 P2 in
      case S of nil then skip
      [] attack|Sr then Succeed1 Succeed2 StillAlife1 StillAlife2 in
	 {Send X attack(Y Succeed1)}
	 if (Succeed1==true) then {Send Y attackedBy(X)} {Send Y stillAlife(StillAlife1)} else StillAlife1=true end
	 if (StillAlife1==true) then {Send Y attack(X Succeed2)}
	    if (Succeed2 == true) then {Send X attackedBy(Y)} {Send X stillAlife(StillAlife2)}
	       if(StillAlife2 == false) then {Send Y gagneContre(X)} end
	    else StillAlife2=true end
	 else
	    {Send X gagneContre(Y)}
	 end
	 % Remise à jour des valeurs
	 {Send X getState(P1)}
	 {Send Y getState(P2)}
	 {SetCombatState Combat P1 P2}
	 if ({And StillAlife1 StillAlife2}) then
	    {CombatRec X Y Sr Combat}
	 end
      end
   end
   P S StateY Combat StatePokemozX StateCombat
in
   P={NewPort S}
   {Browse newPort}
   if ({Send Y getHp($)}<1) then {Send  Y setHpMax} end
   {Send Y getState(StateY)}
   {Send StateX.p getState(StatePokemozX)}
   if ({And StatePokemozX.hp>0 StateY.hp>0}) then
      Combat = {StartCombat StateX Y P }
      {SetCombatState Combat StatePokemozX StateY}
      thread {CombatRec StateX.p Y S Combat} end
   end
end

%
% X doit être le perso principal
% Y doit être le perso adverse
%
proc{CombatPerso X Y}
   % La les variable doivent être 2 pokemoz
   proc{CombatRec X Y S Combat}
      P1 P2 in
      case S of nil then skip
      [] attack|Sr then Succeed1 Succeed2 StillAlife1 StillAlife2 in
	 {Send X attack(Y Succeed1)}
	 if (Succeed1==true) then {Send Y attackedBy(X StillAlife1)} else StillAlife1=true end
	 if (StillAlife1==true) then {Send Y attack( X Succeed2)}
	    if (Succeed2 == true) then {Send X attackedBy( Y StillAlife2)}
	       if(StillAlife2 == false) then
		  {Send Y gagneContre(X)} % Augmentation de niveau
		  {Combat.attaqueImage delete}%suppression de l'image du perdant
	       end
	    else StillAlife2=true end
	 else
	    {Send X gagneContre(Y)} % Augmentation du niveau
	    {Combat.attaquantImage delete}
	 end
	 % Remise à jour des valeurs
	 {Send X getState(P1)}
	 {Send Y getState(P2)}
	 {SetCombatState Combat P1 P2}
	 if ({And StillAlife1 StillAlife2}) then
	    {CombatRec X Y Sr Combat}
	 else
	    {Browse combatFini}
	 end
      end
   end
   P S StateX StateY StateCombat1 StateCombat2 Combat
in
   P={NewPort S}
   {Send X getState(StateX)}
   {Send Y getState(StateY)}
   {Send StateX.p getState(StateCombat1)}
   {Send StateY.p getState(StateCombat2)}
   if ({And StateCombat1.hp>0 StateCombat2.hp>0}) then
      Combat = {StartCombat StateX StateY P}
      {SetCombatState Combat StateCombat1 StateCombat2} 
      thread {CombatRec StateX.p StateY.p S Combat} end
   end
end



proc {GrassCombat PersoState}
   %Création d'un nombre aléatoire pour respecter la proba : génération d'un nombre entre 0 et 100 et regarder si le nombre est inférieur à la Proba definie tout en haut :)
   Rand
   RandomPokemoz
   Combat
   X
in
   Rand = {OS.rand $} mod 100
   if (Rand =< Proba-1) then
      % Choix d'un pokémoz Aléatoire
      RandomPokemoz = ({OS.rand $} mod ({Record.width Wilds}))+1
      {Browse grassCombat}
      {Browse PersoState}
      {CombatWild PersoState (Wilds.RandomPokemoz)}
   end
end


% fun {CheckDesseur Init}
   
% end

%%%%%%%%%%%%%%% Gestion des déplacements %%%%%%%%%%%%%%%%%%%


proc {MoveOther RecordPortTrainer DelayToApply}
   Width = {Record.width RecordPortTrainer}
   Move=move(moveUp moveDown moveRight moveLeft)
   Delai=DelayToApply
   Speed=4
   ProbMove=10
   proc {MoveTrainer RecordPortTrainer N}
      if N>0 then
	 if ProbMove>({OS.rand} mod 100)+1 then
	    {Send RecordPortTrainer.N Move.(({OS.rand} mod 4)+1)}
	    {MoveTrainer RecordPortTrainer N-1}
	 end
      end
   end
in
   {MoveTrainer RecordPortTrainer Width}
   {MoveOther RecordPortTrainer DelayToApply}
end

% fun{MoveOther RecordPortTrainer NumTrainer}
%    Move
%    Delai % parametre a remonter pas la suite 
%    Speed % idem
% in
%    Move=[moveUp moveDown moveRight moveLeft]
%    Delai=200
%    Speed=4
%    {Delay ((10-Speed)*Delai)}
%    if NumTrainer>0
%    then	 
%       {Send RecordPortTrainer.NumTrainer Move.(({OS.rand} mod 4)+1)}
%       {MoveOther RecordPortTrainer (NumTrainer-1)}
%    else
%       {MoveOther RecordPortTrainer {Width RecordPortTrainer}}
%    end  
% end


% fun {MoveOtherTrainer RecPortTrainers}
%    Move
%    Delai % parametre a remonter pas la suite 
%    Speed % idem
% in
%    Move=[moveUp moveDown moveRight moveLeft]
%    Delai=200
%    Speed=4
%    {Delay ((10-Speed)*Delai)}
%    {MoveOther RecPortTrainers s}
%    {MoveOtherTrainer RecPortTrainers}
% end

   
      

fun {MoveLeft Init}
   B Grass TypePerso in {Send MapTrainers check((Init.x)-1 Init.y B)}
   {Send Map check((Init.x)-1 Init.y Grass)}
   if B then  {Send MapTrainers setMap((Init.x) Init.y)}
      {Send MapTrainers setMap((Init.x)-1 Init.y)}
      {Move Init moveLeft}
      if {And (Grass==false) (Init.type==persoPrincipal)} then {GrassCombat Init} end %% Ajouter la condition que c'est le preso principal
      {AdjoinAt Init x (Init.x)-1}
      else Init
      end
end

fun {MoveRight Init}
   B Grass in {Send MapTrainers check((Init.x)+1 Init.y B)} {Send Map check((Init.x)+1 Init.y Grass)} 
   if B then {Send MapTrainers setMap((Init.x) Init.y)}
      {Send MapTrainers setMap((Init.x)+1 Init.y)}
      {Move Init moveRight}
      if {And (Grass==false) (Init.type==persoPrincipal)} then {GrassCombat Init} end
      {AdjoinAt Init x (Init.x)+1}
      else Init
   end
end


fun {MoveUp Init}
   B Grass in {Send MapTrainers check((Init.x) (Init.y)-1 B)} {Send Map check((Init.x) (Init.y)-1 Grass)}
   if B then  {Send MapTrainers setMap((Init.x) Init.y)}
      {Send MapTrainers setMap((Init.x) (Init.y)-1)}
      {Move Init moveUp}
      if {And (Grass==false) (Init.type==persoPrincipal)} then {GrassCombat Init} end
      {AdjoinAt Init y (Init.y)-1}
      else Init
   end
end


fun {MoveDown Init}
   B Grass in {Send MapTrainers check((Init.x) (Init.y)+1 B)} {Send Map check((Init.x) (Init.y)+1 Grass)}
   if B then {Send MapTrainers setMap((Init.x) Init.y)}
      {Send MapTrainers setMap((Init.x) (Init.y)+1)}
      {Move Init moveDown}
      if {And (Grass==false) (Init.type==persoPrincipal)} then  {GrassCombat Init} end
      {AdjoinAt Init y (Init.y)+1}
      else Init
   end
end

%%%%%%%%%%%%% Fonctions générales %%%%%%%%%%%%%%%%%%%%


fun {SetAuto Init}
   if Init.auto>0 then {AdjoinAt Init auto (Init.auto)-1}
   else {AdjoinAt Init auto (Init.auto)+1}
   end
end


%%%%%%%%%%%%% fonction mere trainer %%%%%%%%%%%%%%%%%%

fun {FTrainer Msg Init}
   case Msg
   of moveLeft then {MoveLeft Init} 
   [] moveRight then {MoveRight Init} 
   [] moveDown then {MoveDown Init} 
   [] moveUp then {MoveUp Init}
   [] setauto then {SetAuto Init}
   [] setPortObject(X) then {Record.adjoin Init t(portObject:X) $}
   [] getPortObject(R) then R = Init.portObject Init
   [] get(X) then X=Init Init
   [] getState(State) then State=Init Init
   end
end

fun {CreateOtherPortObjectTrainers Number Speed Canvas}
   Trainers = {CreateOtherTrainer Number Speed Canvas}
   {Browse Trainers}
   %% fonction pour permettre de créer des portObject des trainers
   fun {Recurs NumberLeft Trainers}
      if (NumberLeft == 0 ) then trainers()
      else
	 {Browse NumberLeft}
	 {Record.adjoin {Recurs NumberLeft-1 Trainers}   trainers(NumberLeft:{NewPortObject FTrainer Trainers.NumberLeft}) $}
	 
      end
   end
in
   {Recurs Number Trainers}
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% TROISIEME PARTIE %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declare
PortPersoPrincipal
CanvasMap
XMap
%Création de la map
{Send Map get(XMap)}

%Démarrage du jeux
CanvasMap = {StartGame XMap (proc{$} {Send PortPersoPrincipal moveUp} end) (proc{$} {Send PortPersoPrincipal moveLeft} end) (proc{$} {Send PortPersoPrincipal moveDown} end) (proc{$} {Send PortPersoPrincipal moveRight} end)}

%Créer le pokCreatePokemoz5émon du perso principal
PortPersoPrincipal={NewPortObject FTrainer {CreateTrainer "Moi" {NewPortObject FPokemoz {CreatePokemoz5 {Choose}}} 7 7 2 persoPrincipal CanvasMap} }


%%%%% Fonction qui fait évoluer les pokémoz sauvages %%%%% j'hesite à la place d'implémenter dans les mvt
thread {WildsXpAdd Wilds 100} end

%%%%% Fonction pour créer des autres personnages %%%%%%%%%

declare
Coucou = {CreateOtherPortObjectTrainers 3 3 CanvasMap}
{Browse Coucou}
{Send Coucou.1 moveUp}
{Send Coucou.1 moveRight}
{Send Coucou.1 moveDown}

thread {MoveOther Coucou 200} end % boucle infinie qui fait en sorte que les dresseurs se déplace attention à certains moment ils se superposent !!!!
%%% To DO :
% Gestion mouvement autres dresseurs attention ils déclanchent des combats 
%
% Gestion lancement combat avec dresseur
% Gestion Combat automatique
% Remettre de l'ordre dans le code
%
%
