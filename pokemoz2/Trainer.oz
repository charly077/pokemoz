%This function stocks everythings related to trainers

functor

import
   System
   Browser
   OS
   Application
   Pokemoz
   Game
   Graphic
   
export

   FTrainer
   CreateOtherPortObjectTrainers
   CreateTrainer
   CreateOtherTrainer
   MoveOther
   InitTrainerFunctor
   
define
   Show = System.show
   Browse = Browser.browse
   CreatePerso = Graphic.createPerso
   FPokemoz = Pokemoz.fPokemoz
   CreatePokemoz5 = Pokemoz.createPokemoz5
   Pokemozs = Pokemoz.pokemozs
   Move = Graphic.move
   GrassCombat
   MapTrainers
   Map
   WindowMap
   
   Names = names("Jean" "Sacha" "Ondine" "Pierre")

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% Fonctions de base %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   proc {InitTrainerFunctor GrassCombatFunction MapTrainersPortObject MapPortObject WindowMapToUse}
      GrassCombat = GrassCombatFunction
      MapTrainers = MapTrainersPortObject
      Map = MapPortObject
      WindowMap = WindowMapToUse
   end
   

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

Wilds = Pokemoz.wilds

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



%%%%%%%%%%%%%%% Gestion des déplacements %%%%%%%%%%%%%%%%%%%


   proc {MoveOther RecordPortTrainer DelayToApply Speed Pause}
      Width = {Record.width RecordPortTrainer}
      Move=move(moveUp moveDown moveRight moveLeft)
      Delai=DelayToApply
      ProbMove=65
      fun {PauseRec}
	 if ({Send Pause getState($)}==1) then {PauseRec}
	 else
	    1 % L'affectation met le programme en pause :)
	 end
      end
      proc {MoveTrainer RecordPortTrainer N}
	 %During Combat we have to do a Pause !!!
	 X = {PauseRec}
      in
	 if N>0 then
	    {Delay 10} %% Avoid that 2 trainer use the same MapTrainerState so it can avoid collision and créate a fact that all trainer doesn't still move at the same time
	    if ProbMove>({OS.rand} mod 100)+1 then
	       {Send RecordPortTrainer.N Move.(({OS.rand} mod 4)+1)}
	       {MoveTrainer RecordPortTrainer N-1}
	    end
	 end
      end
   in
      {Delay ((10-Speed)*Delai)}
      {MoveTrainer RecordPortTrainer Width}
      {MoveOther RecordPortTrainer DelayToApply Speed Pause}
   end
   
      

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
	 if (Init.type==persoPrincipal) then
	    if (Grass==false) then {GrassCombat Init} end
	    if {And (Init.x +1 == 7) (Init.y ==1)} then {WindowMap close} end
	 end
	 {AdjoinAt Init x (Init.x)+1}
      else Init
      end
   end


   fun {MoveUp Init}
      B Grass in
      {Send MapTrainers check((Init.x) (Init.y)-1 B)} {Send Map check((Init.x) (Init.y)-1 Grass)} 
      if B then  {Send MapTrainers setMap((Init.x) Init.y)}
	 {Send MapTrainers setMap((Init.x) (Init.y)-1)}
	 {Move Init moveUp}
	 if  (Init.type==persoPrincipal) then
	    if (Grass==false) then {GrassCombat Init} end
	    if {And (Init.x == 7) (Init.y-1 ==1)} then {WindowMap close} end
	 end
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
      %% fonction pour permettre de créer des portObject des trainers
      fun {Recurs NumberLeft Trainers}
	 if (NumberLeft == 0 ) then trainers()
	 else
	    {Record.adjoin {Recurs NumberLeft-1 Trainers}   trainers(NumberLeft:{NewPortObject FTrainer Trainers.NumberLeft}) $}
	 
	 end
      end
   in
      {Recurs Number Trainers}
   end


end