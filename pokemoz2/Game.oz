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
   Proba=35
   Fight=fight % can be fight or runAway TODO
   FightAuto=true % true or false TODO
   
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
      {Pickle.load 'map.txt' $} % pick the map
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


   
%%%%%%%%%%%%% fonction mere Map %%%%%%%%%%%%%%%%%%
   fun {FMap Msg MapState}
      case Msg
      of  setMap(X Y) then {SetMap X Y MapState}
      [] check(X Y B) then B={Check X Y MapState} MapState
      [] checkin(X Y B) then B={Checkin X Y MapState} MapState
      [] get(X) then X=MapState MapState
      end
   end

   MapTrainers
   Map


%%%%%%%%%%%%%%%%%%%%%% Gestion de combat %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% X doit être le portObject perso principal
% Y doit être le portObject pokémoz sauvage
%

%TODO TEST DES DEUX FONCTIONS
   proc{CombatWild StateX Y}
   % La les variable doivent être 2 pokemoz
      proc{CombatRec X Y S Combat PortAttack}
	 P1 P2 in
	 case S of nil then skip
	 [] attack|Sr then Succeed1 Succeed2 StillAlife1 StillAlife2 in
	    {Send X attack(Y Succeed1)}
	    if (Succeed1==true) then
	       {Combat.labelWriteAction set("We have successfully attacked the wild pokemoz")}
	       {Delay 2000}
	       {Combat.labelWriteAction set("")}
	       {Send Y attackedBy(X)} {Send Y stillAlife(StillAlife1)}
	    else StillAlife1=true end
	    
	    if (StillAlife1==true) then
	       {Send Y attack(X Succeed2)}
	       {Combat.labelWriteAction set("The wild pokemoz has successfully attacked your pokemoz")}
	       {Delay 2000}
	       {Combat.labelWriteAction set("")}
	       if (Succeed2 == true) then {Send X attackedBy(Y)} {Send X stillAlife(StillAlife2)}
		  if(StillAlife2 == false) then
		     {Send Y gagneContre(X)}
		     {Combat.attaqueImage delete}%suppression de l'image du perdant
		     {Combat.labelWriteAction set("You Lose")}
		     {Delay 2000}
		     {Combat.windowCombat close}
		  end
	       else StillAlife2=true end
	    else
	       {Send X gagneContre(Y)}
	       {Combat.attaquantImage delete}
	       {Combat.labelWriteAction set("You Win")}
	       {Delay 1500}
	       {Combat.windowCombat close}
	    end
	 % Remise à jour des valeurs
	    {Send X getState(P1)}
	    {Send Y getState(P2)}
	    if ({And StillAlife1 StillAlife2}) then
	       %Si le combat est automatique il faut lui permettre de continuer
	       if (FightAuto) then {Send PortAttack attack} end
	       {SetCombatState Combat P1 P2}
	       {CombatRec X Y Sr Combat PortAttack}
	    end
	 end
      end
      PortAttack PortAttackList StateY Combat StatePokemozX StateCombat
   in
      {Send PausePortObject pause} 
      PortAttack={NewPort PortAttackList}
      if (FightAuto) then {Send PortAttack attack} end % Permettre de démarrer le combat automatiquement si autoFight est déclenché
      if ({Send Y getHp($)}<1) then {Send  Y setHpMax} end
      {Send Y getState(StateY)}
      {Send StateX.p getState(StatePokemozX)}
      if ({And StatePokemozX.hp>0 StateY.hp>0}) then
	 Combat = {StartCombat StateX Y PortAttack PausePortObject FightAuto}
	 {SetCombatState Combat StatePokemozX StateY}
	 if (Fight == runAway) then {Combat.windowCombat close}
	 else
	    thread {CombatRec StateX.p Y PortAttackList Combat PortAttack} end
	 end
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
		     {Delay 1500}
		     {Combat.windowCombat close}
		  end
	       else StillAlife2=true end
	    else
	       {Send X gagneContre(Y)} % Augmentation du niveau
	       {Combat.attaquantImage delete}
	       {Delay 1500}
	       {Combat.windowCombat close}
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
      PortAttack PortAttackList StateX StateY StateCombat1 StateCombat2 Combat
   in
      PortAttack={NewPort PortAttackList}
      {Send X getState(StateX)}
      {Send Y getState(StateY)}
      {Send StateX.p getState(StateCombat1)}
      {Send StateY.p getState(StateCombat2)}
      if ({And StateCombat1.hp>0 StateCombat2.hp>0}) then
	 Combat = {StartCombat StateX StateY PortAttack PausePortObject }
	 {SetCombatState Combat StateCombat1 StateCombat2} 
	 thread {CombatRec StateX.p StateY.p PortAttackList Combat} end
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
	 {CombatWild PersoState (Wilds.RandomPokemoz)}
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% THE GAME %%%%%%%%%%%%%%%%%%%

   PortPersoPrincipal
   Game
   XMap
   PortPersoPrincipal
   Wilds = Pokemoz.wilds
   RecordOtherPortObjectTrainers
   Delai
   Speed
        
in
   Delai=200
   Speed = 4
   
   MapTrainers={NewPortObject FMap {CreateEmptyMap}}
   Map={NewPortObject FMap {CreateMap}}
   %Création de la map
   {Send Map get(XMap)}
   %Démarrage du jeux
   Game = {StartGame (proc{$} {Send PortPersoPrincipal moveUp} end) (proc{$} {Send PortPersoPrincipal moveLeft} end) (proc{$} {Send PortPersoPrincipal moveDown} end) (proc{$} {Send PortPersoPrincipal moveRight} end) ((10-Speed)*Delai)}
   {InitTrainerFunctor GrassCombat MapTrainers Map Game.windowMap} % Moyen de contrer un bug en transferant manuellement des informations une fois qu'elles sont compilée :)

   PortPersoPrincipal={NewPortObject FTrainer {CreateTrainer "Moi" {NewPortObject FPokemoz {CreatePokemoz5 {Choose}}} 7 7 2 persoPrincipal Game.canvasMap} }

   %%%%% Fonction qui fait évoluer les pokémoz sauvages 
   thread {WildsXpAdd Wilds Delai*5} end

   RecordOtherPortObjectTrainers = {CreateOtherPortObjectTrainers 3 3 Game.canvasMap}
   thread {MoveOther RecordOtherPortObjectTrainers Delai Speed PausePortObject} end % boucle infinie qui fait en sorte que les dresseurs se déplace attention à certains moment ils se superposent !!!!

   
end