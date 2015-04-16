%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% Pokemoz %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%% Explications générales %%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Cette partie du projet est divise en trois grandes parties, "classes",
% grace a l'utilisation des NewPortObject.
%
% Les trois "classes" sont les suivantes : Trainers, Maps et Pokemoz 
%
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% Fonctions de base %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% creation d'une fonction créatrice de portobject qui renvoie un port
declare
fun {NewPortObject Behaviour Init}
   proc{MsgLoop S1 State}
      case S1 of Msg|S2 then
	 {MsgLoop S2 {Behaviour Msg State}}
      [] nil then skip
      end
   end
   Sin
in
   thread {MsgLoop Sin Init} end
   {NewPort Sin}
end



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
   P S
in
   P={NewPort S}
   thread {Loop S Init} end % Port object is sequential internally
   P
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
   Init.Y.X
end



% Fonction qui modifie les coordonnee (X,Y) de la Map Init
declare
fun {SetMap X Y Init}
   if {Check X Y Init}>0 then {AdjoinAt Init Y {AdjoinAt Init.Y X (Init.Y.X)-1}}
   else {AdjoinAt Init Y {AdjoinAt Init.Y X (Init.Y.X)+1}}
   end
end

% 

%%%%%%%%%%%%% fonction mere Map %%%%%%%%%%%%%%%%%%
declare FMap in
fun {FMap Msg Init}
   case Msg
   of check(X Y) then {Check X Y Init} 
   [] setMap(X Y) then {SetMap X Y Init}
   [] get(X) then X=Init Init 
   end
end

% test

{Browse {CreateMap}}

declare T1 T2 T3
Maptrainers={NewPortObject FMap {CreateMap}}
Map={NewPortObject FMap {CreateMap}}

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
   trainer(name:Name p:Pokemoz x:X y:Y speed:Speed auto:0 handle:0 type:Type)
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
   if Init.x<{Width Map.1} then {AdjoinAt Init x (Init.x)+1} %{MoveLGUI}
      else Init
   end 
end

declare
fun {MoveRight Init}
   if  Init.x>0 then {AdjoinAt Init x (Init.x)-1} %{MoveRGUI}
      else Init
   end
end

declare
fun {MoveUp Init}
   if Init.y<{Width Map} then {AdjoinAt Init y (Init.y)+1} %{MoveUGUI}
      else Init
   end  
end

declare
fun {MoveDown Init}
   if Init.y>0 then {AdjoinAt Init y (Init.y)-1} %{MoveDGUI}
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
fun {LevelUp Init}
   case Init.lx of 5 then if Init.xp>5 then {AdjoinList Init [xp#(xp mod 5) lx#6 hp#22]}  else Init end
   [] 6 then if Init.xp>12 then {AdjoinList Init [xp#0 lx#6 hp#22]}  else Init end
   [] 7 then if Init.xp>5 then {AdjoinAt Init lx ({AdjoinAt Init xp ((Init.xp) mod 5)}.lx)+1}  else Init end
   [] 8 then 
   [] 9 then
   [] 10 then
      
      
end


declare
fun {SetHp Init X}
   {AdjoinAt Init hp (Init.hp)-X}
end


%%%%%%%%%%%%% Fonction mere Pokemoz %%%%%%%%%%%%%%%%%%

declare FPokemoz in
fun {FPokemoz Msg Init}
   case Msg
   of sethp(X) then {SetHp Init X} 
   [] setlx(X) then {SetLx Init X} 
   [] setxp(X) then {SetXp Init X} 
   [] levelup(Xp Lx) then {LevelUp Init Xp Lx}
   [] get(X) then X=Init Init 
   end
end


declare P1 P2 P3
P1={NewPortObject FPokemoz {CreatePokemoz "fire" "Buloz"}}
P2={NewPortObject FTrainer {CreateRandTrainer 1 4}}
P3={NewPortObject FTrainer {CreateRandTrainer 1 4}}


local X in {Send P1 get(X)} {Browse X} end
{Send P1 sethp(5)}
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