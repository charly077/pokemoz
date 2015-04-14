%Declaration QTk
declare
[QTk] = {Module.link ['x-oz://system/wp/QTk.ozf']}

%declarartion de la map et gestion du graphisme
declare
Map = map(r(1 1 1 0 0 0 0)
	  r(1 1 1 0 0 1 1)
	  r(1 1 1 0 0 1 1)
	  r(0 0 0 0 0 1 1)
	  r(0 0 0 1 1 1 1)
	  r(0 0 0 1 1 0 0)
	  r(0 0 0 0 0 0 0))

%declaration des fonctions pour créer la map :)
declare
proc{CreateMap Map Canvas}
   %premièrement pour faire une fonction récursif je préfère travailler en liste
   MapList
   %Fonction pour créer une ligne :)
   fun{CreateLine Line Canvas X Y}
      %Pour le moment j'ai un tuple r :)
      %Création de la proc récursive pour dessiner les carrés :)
      proc {ProcRecursLine Line X Y}
	 case Line of nil then skip
	 [] T|H then
	    %dessiner le carré
	    if (T==1) then
	       {Canvas create (rect X Y X+50 Y+50 fill:red)}
	    else
	       {Canvas create (rect X Y X+50 Y+50 fill:green)}
	    end
	    %rappelé la fonction
	    {ProcRecursLine H X Y+100}
      end
   in
      {ProcRecusLine Line X Y}
   end
   %Création d'une fonction récursive pour créer la map
   proc{Create MapList Canvas X Y}
      case MapList of nil then skip
      [] T|H then
	 {CreateLine Canva X Y}
	 {Create H Canvas X+100 Y}
      end
in
   {Record.toList Map MapList}
   {Create MapList Canvas 50 50}
end

%Création de la map en QTk
local
   Canvas
   Window
   Desc = td(canvas(handle:Canvas width:1000 height:1000))
in
   Window = {QTk.build Desc}
   %C'est ici qu'on peut dessiner la map :)
   {Create Map Canvas}

   %{Canvas create(rectangle 50 80 100 100 fill:red)}
      {Window show}
end


   
































	 

% creation d'une fonction créatrice de portobject qui renvoie un port
declare
fun {NewPortObject Behaviour Init}
   proc{MsgLoop S1 State}
      case S1 of Msg|S2 then
	 {MsgLoop S2 {Beviour Msg State}}
      [] nil then skip
      end
   end
   Sin
in
   thread {MsgLoop Sin Init} end
   {NewPort Sin}
end

%le but vas être de pouvoir gérer un évènement

declare
[Prototyper] = {Module.link ["x-oz://system/wp/Prototyper.ozf"]}
{Prototyper.run}



local
   Canvas
   Window
   Desc=lr(canvas(
		  width:500
		  height:500
		  handle:Canvas))
in
   Window = {QTk.build Desc}
   {Window show}
  {Canvas create(image:{QTk.newImage photo(file:'herbe.gif')} 100 100 )}
end

local
   Canvas
   Desc=td(canvas(bg:green
                  width:200
                  height:200
                  handle:Canvas))
   Window={QTk.build Desc}
   Dir={NewCell r(~10 0)}
   Points={NewDictionary}
   {Window bind(event:"<Up>" action:proc{$} {Assign Dir r(~10 0)} end)}
   {Window bind(event:"<Left>" action:proc{$} {Assign Dir r(0 ~10)} end)}
   {Window bind(event:"<Down>" action:proc{$} {Assign Dir r(10 0)} end)}
   {Window bind(event:"<Right>" action:proc{$} {Assign Dir r(0 10)} end)}
   proc{Game X Y}
      D={Access Dir}
      LY=Y+{Access Dir}.1
      LX=X+{Access Dir}.2
      Key=LX*100+LY % Create a unique valid key for each X,Y position
   in
      {Canvas create(line X Y LX LY fill:red)}
      if LX>200 orelse LX<0 orelse LY>200 orelse LY<0 % Out of the window
         orelse {Dictionary.member Points Key}        % Eat tail
      then % Lost
         {QTk.bell}
         {Window close}
      else
         {Dictionary.put Points Key nil} % Remember the point
         {Delay 250}
         {Game LX LY}
      end
   end
in
   {Window show}
   {Delay 2000}
   {QTk.bell}
   {Game 100 100}
   {Show {Length {Dictionary.entries Points}}}
end