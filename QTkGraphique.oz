%Declaration QTk
declare
[QTk] = {Module.link ['x-oz://system/wp/QTk.ozf']}
Grass = {QTk.newImage photo(file:'/Users/charles/Desktop/pokemoz/herbe.gif')}
Road = {QTk.newImage photo(file:'/Users/charles/Desktop/pokemoz/chemin.gif')}

HeightWidth=60
AddXY=HeightWidth div 2
WidthBetween= HeightWidth + HeightWidth div 6
N=7

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
   proc{CreateLine Line Canvas X Y}
      %Pour le moment j'ai un tuple r :)
      LineList
      %Création de la proc récursive pour dessiner les carrés :)
      proc {ProcRecursLine Line X Y}
	 case Line of nil then skip
	 [] T|H then
	    %dessiner le carré
	    if (T==1) then
	       {Canvas create(image X+AddXY Y+AddXY image:Grass)}
	    else
	       {Canvas create(image X+AddXY Y+AddXY image:Road)}
	    end
	    %rappeler la fonction
	    {ProcRecursLine H X+WidthBetween Y}
	 end
      end
   in
      {Record.toList Line LineList}
      {ProcRecursLine LineList X Y}
   end
   %Création d'une fonction récursive pour créer la map
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


%Création de la map en QTk
local
   Canvas
   Window
   Desc = td(title:"Pokemoz, the beginning of the end :) " canvas(handle:Canvas width:N*WidthBetween+100 height:N*WidthBetween+100))
in
   Window = {QTk.build Desc}
   %C'est ici qu'on peut dessiner la map :)
   {CreateMap Map Canvas}
   {Window show}
end

   
%tuto
declare
[Prototyper] = {Module.link ["x-oz://system/wp/Prototyper.ozf"]}
{Prototyper.run}
