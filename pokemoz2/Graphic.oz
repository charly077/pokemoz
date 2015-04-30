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
   %AttackWildPokemoz
   %AttackTrainer
   StartCombat
   SetCombatState
   Choose
   
define
   Show = System.show
   Browse = Browser.browse

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% Variable declaration %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


   GrassImage = {QTk.newImage photo(file:'herbe.gif')}
   RoadImage = {QTk.newImage photo(file:'chemin.gif')}
   AreneImage = {QTk.newImage photo(file:'arene.gif')}
   HomeImage = {QTk.newImage photo(file:'home.gif')}

   Bulbasoz = {QTk.newImage photo(file:'Bulbasoz.gif')}
   Oztirtle = {QTk.newImage photo(file:'Oztirtle.gif')}
   Charmandoz = {QTk.newImage photo(file:'Charmandoz.gif')}

   PersoPrincipalImage = {QTk.newImage photo(file:'persoPrincipal.gif')}
   PersoPrincipalImageGrand = {QTk.newImage photo(file:'persoPrincipalGrand.gif')}
   PersoSauvageImage = {QTk.newImage photo(file:'persoSauvage.gif')}
   PersoSauvageImageGrand = {QTk.newImage photo(file:'persoSauvageGrand.gif')}


   % Windows usefull information
   HeightWidth=100
   AddXY=HeightWidth div 2
   WidthBetween= HeightWidth %+ HeightWidth div 6
   N=7

   Map
   DSpeed
   
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Map %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
   % C'est cette fonction qui doit être appellée pour démarrer le jeux
   %
   % Pre : - Map, un record de type map
   %       - MoveUpPrincipal MoveLeftPrincipal MoveDownPrincipal
   %         MoveRightPrincipal, les fonctions utilisée pour déplacer
   %         un personnage
   %
   %Post : Renvoie le Canvas de la Map, il est utilile pour d'autres
   %       Fonctions
   fun {StartGame MoveUpPrincipal MoveLeftPrincipal MoveDownPrincipal MoveRightPrincipal DSpeedToApply MapFile MoveAuto}
      CanvasMap
      WindowMap
      Desc
   in
      {Show startGame}
      DSpeed=DSpeedToApply
      {Pickle.load MapFile Map} % pick the map
      Desc = td(title:"Pokemoz, the beginning of the end :) "
		canvas(handle:CanvasMap width:(N-1)*WidthBetween+100 height:(N-1)*WidthBetween+100)
		button(text:"Close" action:toplevel#close width:10))
   
      WindowMap = {QTk.build Desc}

   % Appel de la fonction qui va dessiner la map
      {CreateMapGraphique Map CanvasMap}
      {WindowMap show}

   % Affectation des touches au mouvement du personnage principal
      if (MoveAuto == false) then 
	 {WindowMap bind(event:"<Up>" action:MoveUpPrincipal)}
	 {WindowMap bind(event:"<Left>" action:MoveLeftPrincipal)}
	 {WindowMap bind(event:"<Down>" action:MoveDownPrincipal)}
	 {WindowMap bind(event:"<Right>" action:MoveRightPrincipal)}
      end
      game(canvasMap:CanvasMap windowMap:WindowMap)
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
   fun {AttackWildPokemoz  WindowCombat CanvasAttaquant CanvasPersoPrincipal Attaque Attaquant}
      PokemozAttaquantName
      PokemozPersoPrincipalName
      PokemozAttaquantType
      PokemozPersoPrincipalType
      ImageCanvasPersoPrincipal
      AttaquantImage
      AttaqueImage
      ColorAttaquant
      ColorAttaque
      X
   in
      PokemozAttaquantName = Attaquant.name
      PokemozAttaquantType = Attaquant.type
      {Send Attaque.p getState(X)}
      PokemozPersoPrincipalName = X.name 
      PokemozPersoPrincipalType = X.type

     % On peut mettre directement le pokemoz
      %TODO Faire les colors
      case PokemozAttaquantType
      of grass then ColorAttaquant=green
      [] fire then ColorAttaquant=red
      [] water then ColorAttaquant=blue
      end
      {CanvasAttaquant set(bg:ColorAttaquant)}

      case PokemozPersoPrincipalType
      of grass then ColorAttaque=green
      [] fire then ColorAttaque=red
      [] water then ColorAttaque=blue
      end
      
      {CanvasPersoPrincipal set(bg:ColorAttaque)}	
      {CanvasAttaquant create(image 550 150 image:{ChoosePhotoPokemoz PokemozAttaquantName} handle:AttaquantImage) }
      % Mettre l'image du dresseur pendant une seconde
      {CanvasPersoPrincipal create(image 150 150 image:PersoPrincipalImageGrand handle:ImageCanvasPersoPrincipal)}
      {Delay 3000}
      {ImageCanvasPersoPrincipal delete}
      {CanvasPersoPrincipal create(image 150 150 image:{ChoosePhotoPokemoz PokemozPersoPrincipalName}handle:AttaqueImage) }
      combat(attaquantImage:AttaquantImage attaqueImage:AttaqueImage)
   end

   % Perso principal >< autre dresseur
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
      ColorAttaquant
      ColorAttaque
   in
      {CanvasPersoPrincipal create(image 150 150 image:PersoPrincipalImageGrand handle:ImageCanvasPersoPrincipal)}
      {CanvasAttaquant create(image 550 150 image:PersoSauvageImageGrand handle:ImageCanvasPersoSauvage)}
      {Delay 3000} % Permet de laisser les perso 3 secondes
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

      % On peut mettre directement le pokemoz
      %TODO Faire les colors
      case PokemozAttaquantState.type 
      of grass then ColorAttaquant=green
      [] fire then ColorAttaquant=red
      [] water then ColorAttaquant=blue
      end
      {CanvasAttaquant set(bg:ColorAttaquant)}

      case PokemozPersoPrincipalState.type
      of grass then ColorAttaque=green
      [] fire then ColorAttaque=red
      [] water then ColorAttaque=blue
      end
      {CanvasPersoPrincipal set(bg:ColorAttaque)}
      
      combat(attaquantImage:AttaquantImage attaqueImage:AttaqueImage)
   end

   %PortAttaque est un port qui permet de savoir que le bouton attack à été appuyé
   fun {StartCombat Attaque AttaquantPort PortAttack PausePortObject FightAuto}
      WindowCombat
      CanvasAttaquant
      CanvasPersoPrincipal
      PlaceHolder
      LabelAttaquant
      LabelPersoPrincipal
      %Attaque
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
	 {Send PausePortObject continue}
      end
   in
      {Browse 'coucou1'}
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
	     {Browse 'coucou'}
	     
	     if (Label == p) then {PlaceHolder set(lr(button(text:"Attack" action:proc{$} {Send PortAttack attack} end width:10) button(text:"Run away" action:Close width:10 glue:we bg:white)))}
	     else
	        {PlaceHolder set(lr(button(text:"Attack" action:proc{$} {Send PortAttack attack} end width:10)))}  % we can't run away
	    end
	  end
      end
      {Record.adjoin ToAddCombat combat(windowCombat:WindowCombat canvasAttaquant:CanvasAttaquant labelAttaquant:LabelAttaquant canvasPersoPrincipal:CanvasPersoPrincipal labelPersoPrincipal:LabelPersoPrincipal labelWriteAction:LabelWriteAction) $}
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
   %%%%%%%%%%% Choisir un pokémoz avant de commencer %%%%%%%%%%%%%%%%%%%
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

end
