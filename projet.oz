
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

%%%%%%% Initialisation Map %%%%%%%%%%%%
declare
Map = map(r(1 1 1 0 0 0 0)
	  r(1 1 1 0 0 1 1)
	  r(1 1 1 0 0 1 1)
	  r(0 0 0 0 0 1 1)
	  r(0 0 0 1 1 1 1)
	  r(0 0 0 1 1 0 0)
	  r(0 0 0 0 0 0 0))


%%%%%%%%%%%% Gestion de la position des trainers %%%%%%%%%%%%


declare
MapTrainer = map(r(0 0 0 0 0 0 0)
	  r(0 0 0 0 0 0 0)
	  r(0 0 0 0 0 0 0)
	  r(0 0 0 0 0 0 0)
	  r(0 0 0 0 0 0 0)
	  r(0 0 0 0 0 0 0)
	  r(0 0 0 0 0 0 0))

% Verifie si la case de coordonnee (X,Y) est vide
declare
fun {Check X Y}
   MapTrainer.Y.X
end

% Fonction qui modifie les coordonnee (X,Y) de la MapTrainer
declare
fun {SetMapTrainer X Y}
   if {Check X Y}>0 then {AdjoinAt MapTrainer.Y X (MapTrainer.Y.X)-1}
   else {AdjoinAt MapTrainer.Y X (MapTrainer.Y.X)+1}
   end
end

   
declare

{Browse MapTrainer}

{Browse {SetMapTrainer 4 3}}
{Browse {SetMapTrainer 3 6}}
{Browse {SetMapTrainer 5 6}}

{Browse MapTrainer}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% Gestion Trainers %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%% Fonctions de créations de Trainers %%%%%%%%%%%%%%%%


%% Variables initiales
declare
Names = names('Jean' 'Sacha' 'Ondine' 'Pierre')
Pokemozs = pokemozs('Bulbasoz' 'Oztirlte' 'Charmandoz')



%Creation d'un record trainer spécifique
declare
fun {CreateTrainer Name Pokemoz X Y Speed }
   trainer(name:Name pokemoz:Pokemoz x:X y:Y speed:Speed)
end


% Création d'un record trainer aleatoire
declare
fun {CreateRandTrainer  Speed}
   local Name X Y Pokemoz in
      Name = Names.(({OS.rand} mod {Width Names})+1)
      Pokemoz = Pokemozs.(({OS.rand} mod {Width Pokemozs})+1)
      X=({OS.rand} mod 7)+1
      Y=({OS.rand} mod 7)+1
      {CreateTrainer Name Pokemoz X Y Speed}
   end
end

%test
declare
T1={CreateRandTrainer  4}
{Browse T1}


%Creation d'un record trainers contenant des trainers aleatoires
declare
fun{CreateOtherTrainer Number Speed}
   local R
      fun{CreateOtherTrainers Number Speed Trainers}
	 if Number>0 then {CreateOtherTrainers Number-1 Speed {AdjoinAt Trainers Number {CreateRandTrainer  Speed}}}
	 else Trainers
	 end
      end
      in {MakeRecord trainers [1] R}
	 {CreateOtherTrainers Number Speed R}	 
      end
end


%test
declare
Trainers = {CreateOtherTrainer 5 4}
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

%%%%%%%%%%%%% fonction mere trainer %%%%%%%%%%%%%%%%%%
declare FTrainer in
fun {FTrainer Msg Init}
   case Msg
   of moveLeft then {MoveLeft Init} 
   [] moveRight then {MoveRight Init} 
   [] moveDown then {MoveDown Init} 
   [] moveUp then {MoveUp Init} 
   [] get(X) then X=Init Init 
   end
end


% test

declare T1 T2 T3
T1={NewPortObject FTrainer {CreateRandTrainer 4}}
T2={NewPortObject FTrainer {CreateRandTrainer 4}}
T3={NewPortObject FTrainer {CreateRandTrainer 4}}

local X in {Send T1 get(X)} {Browse X} end
{Send T1 moveUp}
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