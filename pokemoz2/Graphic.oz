%this functor stocks everythings related to graphic and so QTK

functor

import
   QTk at 'x-oz://system/wp/QTk.ozf'
   System
   Application
   Browser
   Pickle

export
   StartGame
   StartCombat
   Move
   CreatePerso
   StartCombat
   SetCombatState
   Choose
   
define
   Show = System.show
   Browse = Browser.browse

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% Variable declaration %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


   GrassImage = {QTk.newImage photo(file:'img/herbe.gif')}
   RoadImage = {QTk.newImage photo(file:'img/chemin.gif')}
   AreneImage = {QTk.newImage photo(file:'img/arene.gif')}
   HomeImage = {QTk.newImage photo(file:'img/home.gif')}

   Bulbasoz = {QTk.newImage photo(file:'img/Bulbasoz.gif')}
   Oztirtle = {QTk.newImage photo(file:'img/Oztirtle.gif')}
   Charmandoz = {QTk.newImage photo(file:'img/Charmandoz.gif')}

   PersoPrincipalImage = {QTk.newImage photo(file:'img/persoPrincipal.gif')}
   PersoPrincipalImageGrand = {QTk.newImage photo(file:'img/persoPrincipalGrand.gif')}
   PersoSauvageImage = {QTk.newImage photo(file:'img/persoSauvage.gif')}
   PersoSauvageImageGrand = {QTk.newImage photo(file:'img/persoSauvageGrand.gif')}


   % Windows usefull information
   HeightWidth=100
   AddXY=HeightWidth div 2
   WidthBetween= HeightWidth
   N=7

   Map
   DSpeed
   
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Map %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %
   %Create map GUI
   %
   proc{CreateMapGraphique Map Canvas}
      MapList % Allow recursion
      % Function to create lines
      proc{CreateLine Line Canvas X Y}
	 LineList % Also to allox recursion
	 proc {ProcRecursLine Line X Y}
	    case Line of nil then skip
	    [] T|H then
	       % drax
	       if (T==1) then
		  {Canvas create(image X Y image:GrassImage)}
	       else
		  {Canvas create(image X Y image:RoadImage)}
	       end
	       
	       {ProcRecursLine H X+WidthBetween Y}
	    end
	 end
      in
	 {Record.toList Line LineList}
	 {ProcRecursLine LineList X Y}
      end
      %Recursive function
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
      {Canvas create(image AddXY+WidthBetween*(N-1) AddXY+WidthBetween*(N-1) image:HomeImage)}
      {Canvas create(image AddXY+WidthBetween*(N-1) AddXY image:AreneImage)}
   end


%%%%%%%%%%%%%%%%% Movement %%%%%%%%%%%%%%%

   %
   %Perso is the trainer GUI
   %Movement is a atom which indicate the direction of movement 
   %
   %Fonction which manage move trainer on GUI map
   %
   proc{Move Perso Movement}
      CanvasPerso
      TimeDelay
      N
      NSpace
      proc {MoveDelay X Y}
	 {Delay TimeDelay}
	 if {And {And (X < NSpace) (X > ~NSpace) }  {And (Y < NSpace) (Y > ~NSpace) }} then {CanvasPerso move(X Y)}
	 elseif (X>0) then {CanvasPerso move(NSpace 0)} {MoveDelay X-NSpace Y}
	 elseif (X<0) then {CanvasPerso move(~NSpace 0)} {MoveDelay X+NSpace Y}
	 elseif (Y>0) then {CanvasPerso move(0 NSpace)} {MoveDelay X Y-NSpace}
	 elseif (Y<0) then {CanvasPerso move(0 ~NSpace)} {MoveDelay X Y+NSpace}
	 end
      end
   in
      N=10
      TimeDelay = DSpeed div N
      NSpace = WidthBetween div N
      CanvasPerso = Perso.handle
      case Movement of nil then skip
      []moveUp then {MoveDelay 0 ~WidthBetween}
      []moveDown then {MoveDelay 0 WidthBetween}
      []moveLeft then {MoveDelay ~WidthBetween 0}
      []moveRight then {MoveDelay WidthBetween 0}
      else
	 {Show Movement}
      end
   end




   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%%%%%%%%%%%% Démarrage de la map et du jeux %%%%%%%%%%%%%%%%%%%%%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %
   % It is this function that must be called to start the game
   %
   % Pre : - Map, a map type record
   %       - MoveUpPrincipal MoveLeftPrincipal MoveDownPrincipal
   %         MoveRightPrincipal, functions used to move a character
   %
   %Post : Returns the Canvas of the Map, it is utilile for other functions
   %
   fun {StartGame MoveUpPrincipal MoveLeftPrincipal MoveDownPrincipal MoveRightPrincipal DSpeedToApply MapFile MoveAuto}
      CanvasMap
      WindowMap
      Desc
      Text
      Font = {QTk.newFont font(family:"courier" size:15 weight:bold slant:italic)}
      proc {Close1}
	 {WindowMap close} 
	 {Application.exit 0}
      end
   in
      {Show startGame}
      DSpeed=DSpeedToApply
      {Pickle.load MapFile Map} % pick the map
      Desc = td(title:"Pokemoz, the beginning of the end :) "
		canvas(handle:CanvasMap width:(N-1)*WidthBetween+100 height:(N-1)*WidthBetween+100)
		button(text:"Close" action:Close1 width:10)
	       label(handle:Text justify:center width:65 font:Font ))  
   
      WindowMap = {QTk.build Desc}

   % Call the function that will draw the map
      {CreateMapGraphique Map CanvasMap}
      {WindowMap show}

   % Key assignment to the movement of the main character
      if (MoveAuto == false) then 
	 {WindowMap bind(event:"<Up>" action:MoveUpPrincipal)}
	 {WindowMap bind(event:"<Left>" action:MoveLeftPrincipal)}
	 {WindowMap bind(event:"<Down>" action:MoveDownPrincipal)}
	 {WindowMap bind(event:"<Right>" action:MoveRightPrincipal)}
      end
      game(canvasMap:CanvasMap windowMap:WindowMap text:Text)
   end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% Gestion des personnages %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %
   % Pre : - Canvas, canva obtained through function StartGame
   %       - Trainer, a trainer who has not been initialized
   %                 graphically. It must have a type
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
	 Photo = nil 
      end
      {Canvas create(image 50+(X-1)*WidthBetween 50+(Y-1)*WidthBetween image:Photo handle:Handle)}
      %set handle of trainer
      {Record.adjoin Trainer t(handle:Handle) Perso}
      Perso
   end

   % Small independent function to find the photo of pokemoz
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
   % Start with the StartCombat function, which returns a record
   % combat(canvasAttaquant:CanvasAttaquant
   %                          canvasPersoPrincipal:CanvasPersoPrincipal)
   % This record allows access to variables, for preventive case
   % This function allows you to manage fight
   %
   % Pre: - Attaque t is a type of recorde, and should be the main personal
   %      - Attaquant, either a p-type record, if the attacker is a pokémoz
   %                   either a t type of record, if the attacker is a trainer
   %


   %
   %pre: Pokemoz : record representing the state of a pokemoz
   %
   fun{BackGroundColorFight Pokemoz}
      case Pokemoz.type
      of grass then green
      [] fire then red
      [] water then blue
      end
   end
   
   %
   %Function which manage fight between Main Perso >< wild pokémoz
   %
   fun {AttackWildPokemoz  WindowCombat CanvasAttaquant CanvasPersoPrincipal Attaque Attaquant}
      PokemozAttaquantName
      PokemozPersoPrincipalName
      PokemozAttaquantType
      PokemozPersoPrincipalType
      ImageCanvasPersoPrincipal
      AttaquantImage
      AttaqueImage
      X
   in
      PokemozAttaquantName = Attaquant.name
      PokemozAttaquantType = Attaquant.type
      {Send Attaque.p getState(X)}
      PokemozPersoPrincipalName = X.name 
      PokemozPersoPrincipalType = X.type
	
      {CanvasAttaquant create(image 550 150 image:{ChoosePhotoPokemoz PokemozAttaquantName} handle:AttaquantImage) }
      % display the image of the trainer for one second
      {CanvasPersoPrincipal create(image 150 150 image:PersoPrincipalImageGrand handle:ImageCanvasPersoPrincipal)}
      {Delay 3000}
      {ImageCanvasPersoPrincipal delete}
      {CanvasPersoPrincipal create(image 150 150 image:{ChoosePhotoPokemoz PokemozPersoPrincipalName}handle:AttaqueImage) }

      {CanvasAttaquant set(bg:{BackGroundColorFight Attaquant})}
      {CanvasPersoPrincipal set(bg:{BackGroundColorFight X})}
      combat(attaquantImage:AttaquantImage attaqueImage:AttaqueImage)
   end

   %
   % Function which manage fight between Main Perso  >< Other Trainer
   %
   fun {AttackTrainer  WindowCombat CanvasAttaquant CanvasPersoPrincipal Attaque Attaquant}
      PokemozAttaquantName
      PokemozPersoPrincipalName
      PokemozPersoPrincipal % the same as attaque wich mean attacked (attaqué)
      PokemozPersoPrincipalState
      PokemozAttaquant
      PokemozAttaquantState
      ImageCanvasPersoPrincipal
      ImageCanvasPersoSauvage
      AttaquantImage
      AttaqueImage
   in
      {CanvasPersoPrincipal create(image 150 150 image:PersoPrincipalImageGrand handle:ImageCanvasPersoPrincipal)}
      {CanvasAttaquant create(image 550 150 image:PersoSauvageImageGrand handle:ImageCanvasPersoSauvage)}
      {Delay 3000} % display three seconds trainers
      PokemozAttaquant = Attaquant.p
      PokemozPersoPrincipal = Attaque.p
      PokemozAttaquantState = {Send PokemozAttaquant getState($)}
      PokemozAttaquantName = (PokemozAttaquantState).name
      PokemozPersoPrincipalState = {Send PokemozPersoPrincipal getState($)}
      PokemozPersoPrincipalName = (PokemozPersoPrincipalState).name

      {CanvasPersoPrincipal create(image 150 150 image:{ChoosePhotoPokemoz PokemozPersoPrincipalName} handle:AttaqueImage) }
      {CanvasAttaquant create(image 550 150 image:{ChoosePhotoPokemoz PokemozAttaquantName} handle:AttaquantImage) }
      {ImageCanvasPersoPrincipal delete}
      {ImageCanvasPersoSauvage delete}

      {CanvasAttaquant set(bg:{BackGroundColorFight PokemozAttaquantState})}      
      {CanvasPersoPrincipal set(bg:{BackGroundColorFight PokemozPersoPrincipalState})}
      
      combat(attaquantImage:AttaquantImage attaqueImage:AttaqueImage)
   end

   %
   % function that handles the start of a fight 
   %
   fun {StartCombat Attaque AttaquantPort PortAttack PausePortObject FightAuto WaitBeforeFight}
      WindowCombat
      CanvasAttaquant
      CanvasPersoPrincipal
      PlaceHolder
      LabelAttaquant
      LabelPersoPrincipal
      Attaquant
      LabelWriteAction
      Font = {QTk.newFont font(family:"courier" size:15 weight:bold slant:italic)}
      Combat = td(title:"Pokemoz, the fight can begin !"
		  label(handle:LabelAttaquant glue:e)
		  canvas(handle:CanvasAttaquant width:700 height:300 bg:white)
		  canvas(handle:CanvasPersoPrincipal width:700 height:300 bg:white)
		  label(handle:LabelPersoPrincipal glue:w)
		  label(handle:LabelWriteAction bg:c(42 167 169) borderwidth:3 justify:center width:65 font:Font)
		  placeholder(handle:PlaceHolder))
      Label
      ToAddCombat
      proc {Close}
	 {WindowCombat close}
	 {Send WaitBeforeFight continue}
	 {Send PausePortObject continue}
      end
   in
      WindowCombat = {QTk.build Combat}
      {WindowCombat show(modal:true)}
      {Send AttaquantPort getState(Attaquant)}
      {Record.label Attaquant Label}
      case Label of p then ToAddCombat={AttackWildPokemoz WindowCombat CanvasAttaquant CanvasPersoPrincipal Attaque Attaquant} 
      [] t then ToAddCombat={AttackTrainer WindowCombat CanvasAttaquant CanvasPersoPrincipal Attaque Attaquant}
      else
	 {Show "error StartCombat"}
      end
      if (FightAuto == you) then
	  thread
	     {Delay 3500}
	     if (Label == p) then {PlaceHolder set(lr(button(text:"Attack" action:proc{$} {Send PortAttack attack} end width:10) button(text:"Run away" action:Close width:10 glue:we bg:white)))}
	     else
	        {PlaceHolder set(lr(button(text:"Attack" action:proc{$} {Send PortAttack attack} end width:10)))}  % we can't run away
	    end
	  end
      end
      {Record.adjoin ToAddCombat combat(windowCombat:WindowCombat canvasAttaquant:CanvasAttaquant labelAttaquant:LabelAttaquant canvasPersoPrincipal:CanvasPersoPrincipal labelPersoPrincipal:LabelPersoPrincipal labelWriteAction:LabelWriteAction) $}
   end

   %
   % handling function messages displayed during a fight pokemoz
   %
   proc {SetCombatState Combat StateAttaque StateAttaquant}
      fun{CreateString List}
	 case List of nil then nil
	 [] X|L then
	    case X of nil then {CreateString L}
	    [] T|H then T|{CreateString H|L}
	    end
	 end
      end
      % Ccreating the message of the attacked
      Xp1 MsgAttaquant Hp1 Lx1
      Xp2 MsgAttaque Hp2 Lx2
      Font
   in
      {Int.toString StateAttaquant.xp  Xp1}
      {Int.toString StateAttaquant.hp  Hp1}
      {Int.toString StateAttaquant.lx Lx1}

      {Int.toString StateAttaque.xp  Xp2}
      {Int.toString StateAttaque.hp  Hp2}
      {Int.toString StateAttaque.lx Lx2}

      if {And (StateAttaque.hp > 0) (StateAttaquant.hp > 0) } then 
	 MsgAttaquant = {CreateString [ "Name: " StateAttaquant.name "  Level: " Lx1 "  XP: " Xp1 "  HP: " Hp1]}
	 MsgAttaque = {CreateString [ "Name: " StateAttaque.name "  Level: " Lx2 "  XP: " Xp2 "  HP: " Hp2]}
      elseif (StateAttaque.hp < 1) then
	 MsgAttaquant = "Winner"
	 MsgAttaque = "Loser"
      else
	 MsgAttaquant = "Loser"
	 MsgAttaque = "Winner"
      end
      Font = {QTk.newFont font(family:"courier" size:20 weight:bold slant:italic)}
      {Combat.labelAttaquant set(MsgAttaquant font:Font)}
      {Combat.labelPersoPrincipal set(MsgAttaque font:Font)}
   end


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%%%%%%%% Choose a pokemoz before starting %%%%%%%%%%%%%%%%%%%
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
end
