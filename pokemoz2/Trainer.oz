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
   Exit = Application.exit
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
   PortPersoPrincipal
   PausePortObject
   GameText
   
   Names = names("Jean" "Sacha" "Ondine" "Pierre")

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% Fonctions de base %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %Initialization functions used by trainers
   proc {InitTrainerFunctor GrassCombatFunction MapTrainersPortObject MapPortObject WindowMapToUse PortPersoPrincipalToUse PausePortObjectToUse GameTextToUse}
      GrassCombat = GrassCombatFunction
      MapTrainers = MapTrainersPortObject
      Map = MapPortObject
      WindowMap = WindowMapToUse
      PortPersoPrincipal = PortPersoPrincipalToUse
      PausePortObject = PausePortObjectToUse
      GameText=GameTextToUse
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

% The Trainer represents trainers lying on the card and 
% the actions it can perform depending on where it is on the map.
%
% A trainer is represented in the form of a record which
% structure is :
% Trainer = t(p:_ x:X y:Y handle:_ type:wild/persoPrincipal name:Name)
%Where
%   p : PortObject of the trainer’s pokemoz
%   x : int representative of the abscisse of the position of the trainer on the map
%   y : int representative of the ordinate of the position of the trainer on the map
%   handle : graphics components of the trainer
%   type : atom that can take 2 different values : wild or persoPrincipal
%   name : String representative of the name of the trainer
%
%
%%%%%%%%%%%%%%%%% Fonctions de créations de Trainers %%%%%%%%%%%%%%%%

Wilds = Pokemoz.wilds

%creation of a record of specific Trainer
   fun {CreateTrainer Name Pokemoz X Y Type Canvas N}
      local B in {Send MapTrainers check(X Y B)}
	 if B then {Send MapTrainers setMap(X Y N)} {CreatePerso Canvas trainer(name:Name p:Pokemoz x:X y:Y type:Type n:N)}
	 else {CreateTrainer Name Pokemoz ({OS.rand} mod 7)+1 ({OS.rand} mod 7)+1 Type Canvas N}
	 end
      end
   end

% creation of a record of wild Trainer
   fun {CreateRandTrainer Number Canvas}
      local Name X Y Pokemoz Type X1 Y1 in
	 Name = Names.Number
	 Pokemoz = {NewPortObject FPokemoz {CreatePokemoz5 Pokemozs.(({OS.rand} mod {Width Pokemozs})+1)}} 
	 X=({OS.rand} mod 6)+1 
	 Y=({OS.rand} mod 6)+1
	 if ({And X==6 Y==6}) then X1=5 Y1=5
	 else
	    X1 = X
	    Y1 = Y
	 end
	 Type= wild
	 {CreateTrainer Name Pokemoz X1 Y1 Type Canvas Number}
      end
   end


%creation of an record of the record of wild Trainer
   fun{CreateOtherTrainer Number Canvas}
      local R
	 fun{CreateOtherTrainers Number Trainers Canvas}
	    if Number>0 then {CreateOtherTrainers Number-1 {AdjoinAt Trainers Number {CreateRandTrainer Number Canvas}} Canvas}
	    else Trainers
	    end
	 end
      in {MakeRecord trainers [1] R}
	 {CreateOtherTrainers Number R Canvas}	 
      end
   end



%%%%%%%%%%%%%%% Gestion des déplacements %%%%%%%%%%%%%%%%%%%
   %pre : RecordPortTrainer : record of port of trainer 
   %      DelayToApply : int represents the duration of a movement of turns
   %      Speed : int represents the speed of trainers
   %      Pause : port object for block the movements of trainers
   %
   %Function managing the random movements of wild trainers
   %
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
	 Y
      in
	 if N>0 then
	    {Delay ({OS.rand $} mod 5)+3} %% Avoid that 2 trainer use the same MapTrainerState so it can avoid collision and create a fact that all trainer doesn't still move at the same time
	    Y= {PauseRec} % Delay made a new problem .. if there is a combat, if a trainer move and create a second one .. it's difficult to handle due to thread .. 
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
   
      
   %
   % Moving the trainer to the left on the map trainer
   % starts or does not start fighting according to the current environment
   %
   fun {MoveLeft Init}
      B Grass TypePerso in {Send MapTrainers check((Init.x)-1 Init.y B)}
      {Send Map check((Init.x)-1 Init.y Grass)}
      if B then  {Send MapTrainers setMap((Init.x) Init.y 0)}
	 {Send MapTrainers setMap((Init.x)-1 Init.y Init.n)}
	 {Move Init moveLeft}
	 if (Init.type==persoPrincipal) then
	    if (Grass==false) then {GrassCombat Init} end
	    {Delay 10}
	 end	 
	 {Send MapTrainers checkCombat((Init.x)-1 Init.y)}
	 {AdjoinAt Init x (Init.x)-1}
      else Init
      end
   end

   %
   % Moving the trainer to the left on the map trainer
   % starts or does not start fighting according to the current environment
   %
   fun {MoveRight Init}
      B Grass Pokemoz in {Send MapTrainers check((Init.x)+1 Init.y B)} {Send Map check((Init.x)+1 Init.y Grass)} 
      if B then {Send MapTrainers setMap((Init.x) Init.y 0)}
	 {Send MapTrainers setMap((Init.x)+1 Init.y Init.n)}
	 {Move Init moveRight}
	 if (Init.type==persoPrincipal) then
	    if (Grass==false) then {GrassCombat Init}  {Delay 10} end
	    if {And (Init.x +1 == 7) (Init.y ==1)} then
	       Pokemoz = {Send Init.p getState($)}
	       if ({And (Pokemoz.hp > 0) (Pokemoz.lx == 10)}) then {GameText set("You win the game !!!")}
	       else {GameText set("You lose the game :( ")} end
	       {Delay 2000} {GameText set("")}
	       {WindowMap close} {Exit 0} end
	    if {And (Init.x +1 == 7) (Init.y == 7)} then Pokemoz in
	       {Send Init.p setHpMax()}
	       {Send Init.p getState(Pokemoz)}
	       {GameText set("Your pokemon health had been set to its max!")}
	       thread
		  {Delay 1000}
		  {GameText set("")}
	       end
	    end   
	 end
	 {Send MapTrainers checkCombat((Init.x)+1 Init.y)}
	 {AdjoinAt Init x (Init.x)+1}
      else Init
      end
   end

   %
   % Moving the trainer to the left on the map trainer
   % starts or does not start fighting according to the current environment
   %
   fun {MoveUp Init}
      B Grass in
      {Send MapTrainers check((Init.x) (Init.y)-1 B)} {Send Map check((Init.x) (Init.y)-1 Grass)} 
      if B then  {Send MapTrainers setMap((Init.x) Init.y 0)}
	 {Send MapTrainers setMap((Init.x) (Init.y)-1 Init.n)}
	 {Move Init moveUp}	 
	 if  (Init.type==persoPrincipal) then
	    if (Grass==false) then {GrassCombat Init} {Delay 10} end
	    if {And (Init.x == 7) (Init.y-1 ==1)} then
	       Pokemoz = {Send Init.p getState($)}
	       if ({And (Pokemoz.hp > 0) (Pokemoz.lx == 10)}) then {GameText set("You win the game !!!")}
	       else {GameText set("You lose the game :( ")} end
	       {Delay 2000} {GameText set("")}

	       {WindowMap close} {Exit 0} end
	 end
	 {Send MapTrainers checkCombat(Init.x (Init.y)-1)}
	 {AdjoinAt Init y (Init.y)-1}
      else Init
      end
   end

   %
   % Moving the trainer to the left on the map trainer
   % starts or does not start fighting according to the current environment
   %
   fun {MoveDown Init}
      B Grass in {Send MapTrainers check((Init.x) (Init.y)+1 B)} {Send Map check((Init.x) (Init.y)+1 Grass)}
      if B then {Send MapTrainers setMap((Init.x) Init.y 0) }
	 {Send MapTrainers setMap((Init.x) (Init.y)+1 Init.n)}
	 {Move Init moveDown}	 
	 if (Init.type==persoPrincipal) then
	    if (Grass==false) then {GrassCombat Init} {Delay 10} end
	    if {And (Init.x == 7) (Init.y+1 == 7)} then Pokemoz in
	       {Send Init.p setHpMax()}
	       {Send Init.p getState(Pokemoz)}
	       {GameText set("Your pokemon health had been set to its max!")}
	       thread
		  {Delay 1000}
		  {GameText set("")}
	       end
	    end
	 end
	 {Send MapTrainers checkCombat((Init.x) (Init.y)+1)}
	 {AdjoinAt Init y (Init.y)+1}
      else Init
      end
   end

%%%%%%%%%%%%% fonction mere trainer %%%%%%%%%%%%%%%%%%

   fun {FTrainer Msg Init}
      case Msg
      of moveLeft then if ({Send PausePortObject getState($)}==0) then {MoveLeft Init} else Init end
      [] moveRight then if ({Send PausePortObject getState($)}==0) then {MoveRight Init} else Init end
      [] moveDown then if ({Send PausePortObject getState($)}==0) then {MoveDown Init} else Init end
      [] moveUp then if ({Send PausePortObject getState($)}==0) then {MoveUp Init} else Init end
      % [] setPortObject(X) then {Record.adjoin Init t(portObject:X) $} % but ???
      % [] getPortObject(R) then R = Init.portObject Init
      [] get(X) then X=Init Init
      [] getState(State) then State=Init Init
      end
   end

   %
   %function creating a port object record trainer
   %
   fun {CreateOtherPortObjectTrainers Number Canvas}
      Trainers = {CreateOtherTrainer Number Canvas}
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