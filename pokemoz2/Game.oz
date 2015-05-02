%This functor is where we create the map and control the game

functor

import
   System
   OS
   Application
   Browser
   Pickle
   Trainer
   Pokemoz
   Graphic

export
   GrassCombat
   MapTrainers
   MapFile
define
   Browse = Browser.browse
   Show = System.show
   StartGame = Graphic.startGame
   FPokemoz = Pokemoz.fPokemoz
   CreatePokemoz5 = Pokemoz.createPokemoz5
   SetCombatState = Graphic.setCombatState
   Choose = Graphic.choose
   StartCombat = Graphic.startCombat
   FTrainer = Trainer.fTrainer
   CreateTrainer = Trainer.createTrainer
   InitTrainerFunctor = Trainer.initTrainerFunctor
   CreateOtherPortObjectTrainers = Trainer.createOtherPortObjectTrainers
   MoveOther = Trainer.moveOther
   FightAuto %C'est un atom argument:)
   PersoPrincipalAuto
   Delai=400
   
   % Gestion des arguments
   Args = {Application.getArgs record(mapFile(single type:string default:'map.txt') probability(single type:int default:35) speed(single type:int default:4) autofight(single type:atom default:fight) auto(single type:bool default:true))}
   FightAuto = Args.autofight
   MapFile = Args.mapFile % have to be the name of the file
   Proba = (Args.probability*100) mod 101 % must be less than 100
   Speed = Args.speed mod 11 % must be less than 10
   PersoPrincipalAuto = Args.auto % On utilise l'intelligence artificielle par défaut
   
   
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

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Function to Pause during Combat %%%%%%%%%%%%%%%
   fun {Pause Msg State}
      case Msg of pause then 1
       [] continue then 0
      [] getState(X) then X=State State
      end
   end
   PausePortObject = {NewPortObject Pause 0} % Port Utilisé pour mettre les perso en Pause :)   
   WaitBeforeFight = {NewPortObject Pause 0}
   
   fun{WaitCombat}
      fun {PauseRec}
	 {Delay ({OS.rand $} mod 5)} %Avoid synchronisation
	 if ({Send WaitBeforeFight getState($)}>0) then {PauseRec}
	 else
	    {Send WaitBeforeFight pause} % On remet en pause car si on est bloqué on va démarrer un autre combat
	    {Send PausePortObject pause} % Si il y a eu un autre combat entre tps qui aurait débloqué .. on rebloque
	    1 % L'affectation met le programme en pause :)
	 end
      end
   in
      {Send PausePortObject pause}
      {PauseRec}
   end
   proc{EndCombat}
      {Send WaitBeforeFight continue}
      {Send PausePortObject continue} % je débloque
   end



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
      {Pickle.load MapFile $} % pick the map
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



%( Fonction qui modifie les coordonnee (X,Y) de la Map Init ) = ancienne version .. maintenant le Set est un vrai set
   fun {SetMap X Y Value MapState}
      {AdjoinAt MapState Y {AdjoinAt MapState.Y X Value}}
   end

   proc {CheckFight NPerso X Y MapState}
      if {Or (MapState.Y.X == 0) (NPerso==0)} then skip
      else
	 if (MapState.Y.X == 1000) then  thread {CombatPerso {Send PortPersoPrincipal getState($)} RecordOtherPortObjectTrainers.NPerso} end % car peut attendre
	 end
	 if (NPerso == 1000) then thread {CombatPerso {Send PortPersoPrincipal getState($)} RecordOtherPortObjectTrainers.(MapState.Y.X)} end
	 end
      end
   end
   proc {CheckCombat X Y MapState} % considère aussi les diagonales ....
      NPerso = MapState.Y.X in
      if (X > 1) then {CheckFight NPerso X-1 Y MapState} end
      if (X < 7) then {CheckFight NPerso X+1 Y MapState} end
      if (Y > 1) then {CheckFight NPerso X Y-1 MapState} end
      if (Y < 7) then {CheckFight NPerso X Y+1 MapState} end
   end
   
   
%%%%%%%%%%%%% fonction mere Map %%%%%%%%%%%%%%%%%%
   fun {FMap Msg MapState}
      case Msg
      of  setMap(X Y Value) then {SetMap X Y Value MapState}
      [] check(X Y B) then B={Check X Y MapState} MapState
      [] checkin(X Y B) then B={Checkin X Y MapState} MapState
      [] get(X) then X=MapState MapState
      [] checkCombat(X Y) then {CheckCombat X Y MapState} MapState
      end
   end

   MapTrainers
   Map


%%%%%%%%%%%%%%%%%%%%%% Gestion de combat %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% X doit être l'état du portObject perso principal
% Y doit être le portObject pokémoz sauvage
%

      % La les variable doivent être 2 pokemoz
      proc{CombatRec X Y S Combat PortAttack MsgAttack MsgBeAttacked}
	 P1 P2  D = ((10-Speed)*Delai) in
	 {Send PausePortObject pause} % In case of unfortunal bugs cause to threads happen, like having several combats, if one end we have to put back trainers in "pause" mode
	 case S of nil then skip
	 [] attack|Sr then Succeed1 Succeed2 StillAlife1 StillAlife2 in
	    {Send X attack(Y Succeed1)}
	    if (Succeed1==true) then
	       {Combat.labelWriteAction set(MsgAttack)}
	       {Delay D}
	       {Combat.labelWriteAction set("")}
	       {Send Y attackedBy(X)} {Send Y stillAlife(StillAlife1)}
	    else {Combat.labelWriteAction set("Miss your attack")} {Delay D} StillAlife1=true end
	    
	    if (StillAlife1==true) then
	       {Send Y attack(X Succeed2)}
	       {Combat.labelWriteAction set(MsgBeAttacked)}
	       {Delay D}
	       {Combat.labelWriteAction set("")}
	       if (Succeed2 == true) then {Send X attackedBy(Y)} {Send X stillAlife(StillAlife2)}
		  if(StillAlife2 == false) then
		     {Send Y gagneContre(X)}
		     {Combat.attaqueImage delete}%suppression de l'image du perdant
		     {Combat.labelWriteAction set("You Lose")}
		  end
	       else {Combat.labelWriteAction set("Miss his attack")} {Delay D} StillAlife2=true end
	    else
	       {Send X gagneContre(Y)}
	       {Combat.attaquantImage delete}
	       {Combat.labelWriteAction set("You Win")}
	    end
	 % Remise à jour des valeurs
	    {Send X getState(P1)}
	    {Send Y getState(P2)}
	    {SetCombatState Combat P1 P2}
	    if ({And StillAlife1 StillAlife2}) then
	       %Si le combat est automatique il faut lui permettre de continuer
	       if (FightAuto==fight) then {Send PortAttack attack} end
	       if (FightAuto==runAway) then {Send PortAttack attack} end
	       {CombatRec X Y Sr Combat PortAttack MsgAttack MsgBeAttacked}
	    else
	       {Delay D}
	       {Combat.windowCombat close}
	       {EndCombat}
	    end
	 end
      end

      % StateX est l'état de X, Y est le portObject
      % dresseur pokemoz
   proc{CombatWild StateX Y}
      PortAttack PortAttackList StateY Combat StatePokemozX StateCombat X
   in
      {Show blockedWild}
      X = {WaitCombat}
      {Show deblockedWild}
      PortAttack={NewPort PortAttackList}
      if (FightAuto==fight) then {Send PortAttack attack} end % Permettre de démarrer le combat automatiquement si autoFight est déclenché
      
      if ({Send Y getHp($)}<1) then {Send  Y setHpMax} end
      {Send Y getState(StateY)}
      {Send StateX.p getState(StatePokemozX)}
      if ({And StatePokemozX.hp>0 StateY.hp>0}) then
	 Combat = {StartCombat StateX Y PortAttack PausePortObject FightAuto WaitBeforeFight}
	 {SetCombatState Combat StatePokemozX StateY}
	 if (FightAuto == runAway) then {Combat.windowCombat close} {EndCombat}
	 else
	    thread {CombatRec StateX.p Y PortAttackList Combat PortAttack "We have successfully attacked the wild pokemoz" "The wild pokemoz has successfully attacked your pokemoz" } end
	 end 
      else
	 {EndCombat}
      end
   end

%
% X doit être l'état du perso principal
% Y doit être le portObject du perso adverse
%
   proc{CombatPerso StateX Y}
      PortAttack PortAttackList StateY StatePokemozX StatePokemozY Combat X
   in
      {Show blockedPerso}
      X = {WaitCombat}
      {Show deblockedPerso}
      PortAttack={NewPort PortAttackList}
      {Send Y getState(StateY)}
      if (FightAuto==fight) then {Send PortAttack attack} end % start automatically the fight
      if (FightAuto==runAway) then {Send PortAttack attack} end
       % Obtain the state of the two pokemoz
       %if (FightAuto==you) then {Send PortAttack attack} end
      {Send StateX.p getState(StatePokemozX)}
      {Send StateY.p getState(StatePokemozY)}
      if ({And StatePokemozX.hp>0 StatePokemozY.hp>0}) then
	 Combat = {StartCombat StateX Y PortAttack PausePortObject FightAuto WaitBeforeFight}
	 {SetCombatState Combat StatePokemozX StatePokemozY}
	 % We can't run away
	 thread {CombatRec StateX.p StateY.p PortAttackList Combat PortAttack "We have successfully attacked the wild trainer's pokemoz" "The wild trainer's pokemoz has successfully attacked your pokemoz"} end
      else     
	 {EndCombat}
	 {Send PausePortObject continue} % pq pas idem pour CombatWild ?
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
	 thread {CombatWild PersoState (Wilds.RandomPokemoz)} end % vu que ça attend parfois
      end
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
	    if (Rand < 10 ) then
	       {Send Wilds.N addXp(1)}
	       {Send Wilds.N levelup}
	    end
	    {Recurs Wilds N-1}
	 end
      end
   in
      {Recursion Wilds Width}
   end

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%TODO INTELLIGENCE ARTIFICIELLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   proc {MovePersoPrincipalIntelligence }
      State StatePokemoz
      fun {PauseRec}
	 if ({Send PausePortObject getState($)}==1) then {PauseRec}
	 else
	    1 % L'affectation met le programme en pause :)
	 end
      end
      %During Combat we have to do a Pause !!!
      X = {PauseRec}
   in
      {Delay ((10-Speed)*Delai)}
      {Send PortPersoPrincipal getState(State)}
      {Send State.p getState(StatePokemoz)}
      if {Or (StatePokemoz.lx < 9) (StatePokemoz.hp == 0)} then
	 if(StatePokemoz.hp>12) then Rand Rand2 in
	    if ({And (State.x > 5) (State.y > 5)}) then
	       Rand = ({OS.rand $} mod 70)
	    else
	       Rand = ({OS.rand $} mod 100)
	    end
	    Rand2 = ({OS.rand $} mod 2)
	    if (Rand < 50 ) then
	       
	       if (Rand2 == 0) then {Send PortPersoPrincipal moveLeft}
	       else {Send PortPersoPrincipal moveUp} end
	    else
	       if (Rand2 == 0) then {Send PortPersoPrincipal moveRight}
	       else {Send PortPersoPrincipal moveDown} end
	    end
	 else Trainer in Trainer = {Send PortPersoPrincipal getState($)}
	    if ({And (Trainer.x == 7) (Trainer.y == 7) }) then {Send PortPersoPrincipal moveUp} {Send PortPersoPrincipal moveLeft}
	    else
	       {Send PortPersoPrincipal moveRight}
	       {Send PortPersoPrincipal moveDown}
	    end
	 end
      else
	 {Send PortPersoPrincipal moveRight}
	 {Send PortPersoPrincipal moveUp}
      end
      {MovePersoPrincipalIntelligence }
   end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% THE GAME %%%%%%%%%%%%%%%%%%%

   PortPersoPrincipal
   Game
   XMap
   PortPersoPrincipal
   Wilds = Pokemoz.wilds
   RecordOtherPortObjectTrainers
   
in
   
   MapTrainers={NewPortObject FMap {CreateEmptyMap}}
   Map={NewPortObject FMap {CreateMap}}
   %Création de la map
   {Send Map get(XMap)}
   %Démarrage du jeux
   Game = {StartGame (proc{$} {Send PortPersoPrincipal moveUp} end) (proc{$} {Send PortPersoPrincipal moveLeft} end) (proc{$} {Send PortPersoPrincipal moveDown} end) (proc{$} {Send PortPersoPrincipal moveRight} end) ((10-Speed)*Delai) MapFile PersoPrincipalAuto}
  

   {InitTrainerFunctor GrassCombat MapTrainers Map Game.windowMap PortPersoPrincipal PausePortObject Game.text} % Moyen de contrer un bug en transferant manuellement des informations une fois qu'elles sont compilée :)
   PortPersoPrincipal={NewPortObject FTrainer {CreateTrainer "Moi" {NewPortObject FPokemoz {CreatePokemoz5 {Choose}}} 7 7 persoPrincipal Game.canvasMap 1000} } % N = 1000 pour le perso principal

   %%%%% Fonction qui fait évoluer les pokémoz sauvages 
   thread {WildsXpAdd Wilds Delai*2} end

   RecordOtherPortObjectTrainers = {CreateOtherPortObjectTrainers 3  Game.canvasMap}

   thread {MoveOther RecordOtherPortObjectTrainers Delai Speed PausePortObject} end % boucle infinie qui fait en sorte que les dresseurs se déplace attention à certains moment ils se superposent !!!

   
   if (PersoPrincipalAuto) then thread {MovePersoPrincipalIntelligence} end end % lance ou pas l'intelligence artificielle
end