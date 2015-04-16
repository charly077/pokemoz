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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% Création graphique de la map %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
   {CreateMap Map CanvasMap}
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
   case Attaquant of  t(p:p(name:X)) then PokemozAttaquantName = X end
   case Attaque of t(p:p(name:X)) then PokemozPersoPrincipalName=X end
   {CanvasPersoPrincipal create(image 150 150 image:{ChoosePhotoPokemoz PokemozPersoPrincipalName})}
   {CanvasAttaquant create(image 550 150 image:{ChoosePhotoPokemoz PokemozAttaquantName})}
   {ImageCanvasPersoPrincipal delete}
   {ImageCanvasPersoSauvage delete}
end

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% TEST ET DEMONSTRATION DE LA PREMIERE PARTIE %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
declare
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
declare
fun{CreateMap}
   map(r(0 0 0 0 0 0 0)
       r(0 0 0 0 0 0 0)
       r(0 0 0 0 0 0 0)
       r(0 0 0 0 0 0 0)
       r(0 0 0 0 0 0 0)
       r(0 0 0 0 0 0 0)
       r(0 0 0 0 0 0 0))
end

% Verifie si la case de coordonnee (X,Y) est vide
declare
fun {Check X Y Init}
   Init.Y.X==1  
end



% Fonction qui modifie les coordonnee (X,Y) de la Map Init
declare
fun {SetMap X Y Init}
   {Browse {Check X Y Init}}
   if {Check X Y Init} then {AdjoinAt Init Y {AdjoinAt Init.Y X (Init.Y.X)-1}}
   else {AdjoinAt Init Y {AdjoinAt Init.Y X (Init.Y.X)+1}}
   end
end

% 

%%%%%%%%%%%%% fonction mere Map %%%%%%%%%%%%%%%%%%
declare FMap in
fun {FMap Msg Init}
   case Msg
   of  setMap(X Y) then {SetMap X Y Init}
   %[] check(X Y) then {Check X Y Init}setMap(X Y) then {SetMap X Y Init}
   [] get(X) then X=Init Init 
   end
end

% Initialisation Map et Maptrainers
declare Maptrainers Map
Maptrainers={NewPortObject FMap {CreateMap}}
Map={NewPortObject FMap {CreateMap}}

%test

{Browse {Send Maptrainers check(5 7)}}
local X in {Send Map get(X)} {Browse X} end
local X in {Send Maptrainers get(X)} {Browse X} end
{Send Map setMap(5 6)} 
{Send Maptrainers setMap(5 6)} 
local X in {Send Map get(X)} {Browse X} end
local X in {Send Maptrainers get(X)} {Browse X} end

T3={NewPortObject FTrainer {CreateRandTrainer 4}}

{Browse {SetMapTrainer 4 3}}
{Browse {SetMapTrainer 3 6}}
{Browse {SetMapTrainer 5 6}}

{Browse MapTrainer}


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


%% Variables initiales
declare
Names = names("Jean" "Sacha" "Ondine" "Pierre")
Pokemozs = pokemozs("Bulbasoz" "Oztirlte" "Charmandoz")



%Creation d'un record trainer spécifique
declare
fun {CreateTrainer Name Pokemoz X Y Speed Type}
   trainer(name:Name p:Pokemoz x:X y:Y speed:Speed auto:0  type:Type)
end

declare
T1={CreateTrainer "Jean" "dfss" 4 6 4 "wild"}
{Browse T1}

% Création d'un record trainer sauvage aleatoire
declare
fun {CreateRandTrainer  Speed Number}
   local Name X Y Pokemoz Type in
      Name = Names.Number
      Pokemoz = Pokemozs.(({OS.rand} mod {Width Pokemozs})+1)
      X=({OS.rand} mod 7)+1
      Y=({OS.rand} mod 7)+1
      Type="wild"
      {CreateTrainer Name Pokemoz X Y Speed Type}
   end
end

%test
declare
T1={CreateRandTrainer 4  1}
{Browse T1}


%Creation d'un record trainers contenant des trainers aleatoires
declare
fun{CreateOtherTrainer Number Speed}
   local R
      fun{CreateOtherTrainers Number Speed Trainers}
	 if Number>0 then {CreateOtherTrainers Number-1 Speed {AdjoinAt Trainers Number {CreateRandTrainer Number  Speed}}}
	 else Trainers
	 end
      end
      in {MakeRecord trainers [1] R}
	 {CreateOtherTrainers Number Speed R}	 
      end
end


%test
declare
Trainers = {CreateOtherTrainer 3 4}
{Browse Trainers}
{Browse Trainers.3}


%%%%%%%%%%%%%%% Gestion des déplacements %%%%%%%%%%%%%%%%%%%

declare
fun {MoveLeft Init}
   if {And Init.x<{Width Map.1} {Send MapTrainers check((Init.x)+1 Init.y)} then {AdjoinAt Init x (Init.x)+1} %{MoveLGUI}
      else Init
   end 
end

declare
fun {MoveRight Init}
   if  {And (Init.x>0){Send MapTrainers check((Init.x)+1 Init.y)}} then {AdjoinAt Init x (Init.x)-1} %{MoveRGUI}
      else Init
   end
end

declare
fun {MoveUp Init}
   if {And Init.y<{Width Map} MapTrainers.(y-1).x} then {AdjoinAt Init y (Init.y)-1} %{MoveUGUI}
      else Init
   end  
end

declare
fun {MoveDown Init}
   if {And Init.y>0 MapTrainers.(y+1).x} then {AdjoinAt Init y (Init.y)+1} %{MoveDGUI}
      else Init
   end 
end

%%%%%%%%%%%%% Fonctions générales %%%%%%%%%%%%%%%%%%%%

declare
fun {SetAuto Init}
   if Init.auto>0 then {AdjoinAt Init auto (Init.auto)-1}
   else {AdjoinAt Init auto (Init.auto)+1}
   end
end


%%%%%%%%%%%%% fonction mere trainer %%%%%%%%%%%%%%%%%%
declare FTrainer in
fun {FTrainer Msg Init}
   case Msg
   of moveLeft then {MoveLeft Init} 
   [] moveRight then {MoveRight Init} 
   [] moveDown then {MoveDown Init} 
   [] moveUp then {MoveUp Init}
   [] setauto then {SetAuto Init}
   [] get(X) then X=Init Init 
   end
end


% test

declare T1 T2 T3
T1={NewPortObject FTrainer {CreateRandTrainer 1 4}}
T2={NewPortObject FTrainer {CreateRandTrainer 1 4}}
T3={NewPortObject FTrainer {CreateRandTrainer 1 4}}

local X in {Send T1 get(X)} {Browse X} end
{Send T1 setauto}
{Send T1 moveLeft}
local X in {Send T1 get(X)} {Browse X} end
local X in {Send T2 get(X)} {Browse X} end
{Send T2 moveUp}
{Send T2 moveLeft}
local X in {Send T2 get(X)} {Browse X} end
local X in {Send T3 get(X)} {Browse X} end
{Send T3 moveUp}
{Send T3 moveLeft}
local X in {Send T3 get(X)} {Browse X} end



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

declare
fun{CreatePokemoz Type Name Hp Lx}
   p(type:Type name:Name hp:Hp lx:Lx xp:0)
end

declare
fun{CreatePokemoz Type Name}
   p(type:Type name:Name hp:20 lx:5 xp:0)
end


%%%%%%%%%%%%%%%% Gestion Xp et Level %%%%%%%%%%%%%%%%%

declare
fun {SetLx Init X}
   {AdjoinAt Init lx (Init.lx)+X}
end

declare
fun {SetXp Init X}
   {AdjoinAt Init xp (Init.xp)+X}
end

declare
fun {SetHp Init X}
   {AdjoinAt Init hp (Init.hp)-X}
end


declare
fun {LevelUp Init}
   case Init.lx of 5 then if Init.xp>5 then {AdjoinList Init [xp#(Init.xp mod 5) lx#6 hp#22]}  else Init end
   [] 6 then if Init.xp>12 then {AdjoinList Init [xp#(Init.xp mod 12) lx#7 hp#24]}  else Init end
   [] 7 then if Init.xp>20 then {AdjoinList Init [xp#(Init.xp mod 20) lx#8 hp#26]}  else Init end
   [] 8 then if Init.xp>30 then {AdjoinList Init [xp#(Init.xp mod 30) lx#9 hp#28]}  else Init end
   [] 9 then if Init.xp>50 then {AdjoinList Init [xp#(Init.xp mod 50) lx#10 hp#30]}  else Init end
   [] 10 then Init   end
   
end

declare
fun {Combat Msg Init}
   case Msg 


%%%%%%%%%%%%% Fonction mere Pokemoz %%%%%%%%%%%%%%%%%%

declare FPokemoz in
fun {FPokemoz Msg Init}
   case Msg
   of sethp(X) then {SetHp Init X} 
   [] setlx(X) then {SetLx Init X} 
   [] setxp(X) then {SetXp Init X} 
   [] levelup then {LevelUp Init}
   [] get(X) then X=Init Init
   [] attack then {Attack 
      
   end
end


declare P1 P2 P3
P1={NewPortObject FPokemoz {CreatePokemoz "fire" "Buloz"}}
P2={NewPortObject FPokemoz p(type:"Fire" name:"Bulboz" hp:20 lx:5 xp:6)}
P3={NewPortObject FTrainer {CreateRandTrainer 1 4}}


local X in {Send P1 get(X)} {Browse X} end
local X in {Send P2 get(X)} {Browse X} end
{Send P1 levelup}
{Send P2 levelup}





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% TROISIEME PARTIE %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
