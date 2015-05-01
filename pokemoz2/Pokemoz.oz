%This functor stocks everythings related to pokemoz

functor

import
   System
   OS
   Application
   Browser
   
export

   Wilds
   CreatePokemoz5
   CreatePokemozTrainer
   FPokemoz
   Pokemozs
   
define
   Show = System.show
   Browse = Browser.browse
   
   
Pokemozs = pokemozs("Bulbasoz" "Oztirtle" "Charmandoz")


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
%%%%%%%%%%%%%%%%%%%% Gestion Pokemoz %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The pokemoz represents the state of Pokemon in real time before, during and after a fight.
%
% A Pokemoz is represented in the form of a record which
% structure is :
% Pokemoz = p(type:_ name:_ hp:_ lx:_ xp:_)
%Where
%    type :the atoms grass/fire/water 
%    name : String representative the name of the pokemoz
%    hp : int representative the health point of pokemoz
%    lx : int representative the leve of pokemoz
%    xp : int representative the experience of pokemoz
%

%%%%%%%%%%%%% Gestion création Pokemoz %%%%%%%%%%%%%%%

   fun{CreatePokemoz5 Name}
      Type in
      case Name of "Bulbasoz" then Type=grass
      [] "Oztirtle" then Type=water
      [] "Charmandoz" then Type=fire
      end
      p(type:Type name:Name hp:20 lx:5 xp:0)
   end

   Wilds = pokemozs({NewPortObject FPokemoz {CreatePokemoz5 "Bulbasoz"}} {NewPortObject FPokemoz {CreatePokemoz5 "Oztirtle"}} {NewPortObject FPokemoz {CreatePokemoz5 "Charmandoz"}})

   fun{LevelRand Lx}
      case Lx of 5 then 5+({OS.rand} mod 2)
      [] 6 then 5+({OS.rand} mod 3)
      [] 7 then 5+({OS.rand} mod 5)
      else 5+({OS.rand} mod 6)
      end
   end      


   fun{CreatePokemozTrainer T}
      Type Name Hp Lx Trainer Pokemoz in
      {Send T get(Trainer)}
      {Send Trainer.p get(Pokemoz)}
      Name=Pokemozs.(({OS.rand} mod {Width Pokemozs})+1)
      case Name of "Bulbasoz" then Type=grass
      [] "Oztirtle" then Type=water
      [] "Charmandoz" then Type=fire
      end
      Lx={LevelRand Pokemoz.lx}
      Hp=20 +2*(Lx-5)
      p(type:Type name:Name hp:Hp lx:Lx xp:0)
   end
	       


%%%%%%%%%%%%%%%% Gestion Xp et Level %%%%%%%%%%%%%%%%%

   %pre : Init is the state of the port of pokemoz during call of function
   %      X is the value add to level of pokemoz
   %post : increase the level of pokemoz to X
   %
   fun {AddLx Init X}
      {AdjoinAt Init lx (Init.lx)+X}
   end


   %pre : Init is the state of the port of pokemoz during call of function
   %      X is the value add to xp of pokemoz
   %post : increase the xp of pokemoz to X
   %
   fun {AddXp Init X}
      {AdjoinAt Init xp (Init.xp)+X}
   end

   %pre : Init is the state of the port of pokemoz during call of function
   %      X is the value add to hp of pokemoz
   %post : increase the hp of pokemoz to X
   %
   fun {AddHp Init X}
      {AdjoinAt Init hp (Init.hp)-X}
   end

   %pre :Init is the state of the port of pokemoz during call of function 
   %
   %post : increase the level of pokemoz, update xp and reset max hp
   %
   fun {LevelUp Init}
      case Init.lx of 5 then if Init.xp>5 then {AdjoinList Init [xp#(Init.xp mod 5) lx#6 hp#22]}  else Init end
      [] 6 then if Init.xp>12 then {AdjoinList Init [xp#(Init.xp mod 12) lx#7 hp#24]}  else Init end
      [] 7 then if Init.xp>20 then {AdjoinList Init [xp#(Init.xp mod 20) lx#8 hp#26]}  else Init end
      [] 8 then if Init.xp>30 then {AdjoinList Init [xp#(Init.xp mod 30) lx#9 hp#28]}  else Init end
      [] 9 then if Init.xp>50 then {AdjoinList Init [xp#(Init.xp mod 50) lx#10 hp#30]}  else Init end
      [] 10 then Init   end
   
   end

   %pre :State is the state of the port of pokemoz during call of function 
   %
   %post : Reset max hp of pokemoz
   %
   fun {SetHpMax State}
      case State.lx of 5 then {Record.adjoin State p(hp:20) $}
      [] 6 then {Record.adjoin State p(hp:22) $}
      [] 7 then {Record.adjoin State p(hp:24) $}
      [] 8 then {Record.adjoin State p(hp:26) $}
      [] 9 then {Record.adjoin State p(hp:28) $}
      [] 10 then {Record.adjoin State p(hp:30) $}
      end
   end

   %pre :Init is the state of the port of pokemoz during call of function 
   %     Y is the port of the pokemoz attacking Init
   %
   %post : inflicts damage of pokemoz Init by type and decreasse the hp of Init 
   %
   fun {AttackBy Y Init} Attaquant in {Send Y get(Attaquant)}
      case Init.type
      of fire then case Attaquant.type
		   of fire then {AdjoinAt Init hp ((Init.hp)-2)}
		   [] water then {AdjoinAt Init hp ((Init.hp)-3)}
		   [] grass then {AdjoinAt Init hp ((Init.hp)-1)}
		   end
      [] grass then  case Attaquant.type
		     of fire then {AdjoinAt Init hp ((Init.hp)-3)}
		     [] water then {AdjoinAt Init hp ((Init.hp)-1)}
		     [] grass then {AdjoinAt Init hp ((Init.hp)-2)}
		     end
      [] water then  case Attaquant.type
		     of fire then {AdjoinAt Init hp ((Init.hp)-1)}
		     [] water then {AdjoinAt Init hp ((Init.hp)-2)}
		     [] grass then {AdjoinAt Init hp ((Init.hp)-3)}
		     end	  
      end
   end

   %pre :Init is the state of the port of pokemoz during call of function 
   %     Y is the port of the pokemoz attacked by Init
   %
   %post : check if the pokemoz Init can attack the pokemoz Init
   %       or if his attack fails
   %
   fun{Attack Y Init}
      X in {Send Y get(X)}
      ((((6+X.lx-Init.lx)*9))>({OS.rand} mod 100))
   end

   %pre :Status is the state of the port of pokemoz during call of function 
   %     Perdant is the port of the pokemoz who loss
   %
   %post : increase the xp of the pokemoz represented by Status
   %
   fun{UpdateXp Perdant Status}
      {AdjoinAt Status xp ((Status.xp)+(Perdant.lx))}
   end


   %pre :Status is the state of the port of pokemoz during call of function 
   %     Perdant is the port of the pokemoz who loss
   %
   %post : update the state of pokemoz represented by Status after a win fight
   %
   fun{GagneContre Y Status}
      Perdant in {Send Y get(Perdant)}
      {LevelUp {UpdateXp Perdant Status}}
   end

   

%%%%%%%%%%%%% Fonction mere Pokemoz %%%%%%%%%%%%%%%%%%


   fun{FPokemoz Msg State}
      case Msg
      of sethp(X) then {AddHp State X} 
      [] setlx(X) then {AddLx State X} 
      [] addXp(X) then {AddXp State X} 
      [] setHpMax() then {SetHpMax State}
      [] levelup then {LevelUp State}
      [] get(X) then X=State State
      [] getState(StateR) then StateR=State State
      [] getHp(Hp) then Hp=State.hp State
      [] attack(Y Succeed) then Succeed={Attack Y State} State
      [] attackedBy(Y) then {AttackBy Y State}
      [] stillAlife(B) then B=(State.hp>0) State
      [] gagneContre(Y) then {GagneContre Y State}
      end
   end
end
