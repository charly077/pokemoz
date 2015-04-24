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
   fun {StartGame MoveUpPrincipal MoveLeftPrincipal MoveDownPrincipal MoveRightPrincipal DSpeedToApply}
      CanvasMap
      WindowMap
      Desc
   in
      {Show startGame}
      DSpeed=DSpeedToApply
      {Pickle.load 'map.txt' Map} % pick the map
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

end