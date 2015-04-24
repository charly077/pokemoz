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
   CreateRandPokemoz
   CreatePokemozTrainer
   FPokemoz
   Pokemozs
   WildsXpAdd
   
define
   Show = System.show
   Browse = Browser.browse
   
   
Pokemozs = pokemozs("Bulbasoz" "Oztirtle" "Charmandoz")

Types = types(fire water grass)
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

% Le pokemoz represente l'etat du pokemon en temps réel avant,
% durant et apres un combat.
%
% Un Pokemoz est represente sous la forme de d'un record dont
% la structure est :
% Pokemoz = p(type:_ name:_ hp:_ lx:_ xp:_)

%%%%%%%%%%%%% Gestion création Pokemoz %%%%%%%%%%%%%%%

   fun{CreatePokemoz Type Name Hp Lx}
      p(type:Type name:Name hp:Hp lx:Lx xp:0)
   end

   {Show coucou1}
   fun{CreatePokemoz5 Name}
      Type in
      case Name of "Bulbasoz" then Type=grass
      [] "Oztirtle" then Type=water
      [] "Charmandoz" then Type=fire
      end
      p(type:Type name:Name hp:20 lx:5 xp:0)
   end

   Wilds = pokemozs({NewPortObject FPokemoz {CreatePokemoz5 "Bulbasoz"}} {NewPortObject FPokemoz {CreatePokemoz5 "Oztirtle"}} {NewPortObject FPokemoz {CreatePokemoz5 "Charmandoz"}})

   {Show coucou2}
   fun{CreateRandPokemoz}
      Type Name Hp Lx in
      Name=Pokemozs.(({OS.rand} mod {Width Pokemozs})+1)
      case Name of "Bulbasoz" then Type=grass
      [] "Oztirtle" then Type=water
      [] "Charmandoz" then Type=fire
      end
      Lx=5+ {OS.rand} mod 5
      Hp=20 +2*(Lx-5)
      p(type:Type name:Name hp:Hp lx:Lx xp:0)
   end


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



   {Show coucou3}
	       


%%%%%%%%%%%%%%%% Gestion Xp et Level %%%%%%%%%%%%%%%%%


   fun {SetLx Init X}
      {AdjoinAt Init lx (Init.lx)+X}
   end


   fun {SetXp Init X}
      {AdjoinAt Init xp (Init.xp)+X}
   end


   fun {SetHp Init X}
      {AdjoinAt Init hp (Init.hp)-X}
   end



   fun {LevelUp Init}
      case Init.lx of 5 then if Init.xp>5 then {AdjoinList Init [xp#(Init.xp mod 5) lx#6 hp#22]}  else Init end
      [] 6 then if Init.xp>12 then {AdjoinList Init [xp#(Init.xp mod 12) lx#7 hp#24]}  else Init end
      [] 7 then if Init.xp>20 then {AdjoinList Init [xp#(Init.xp mod 20) lx#8 hp#26]}  else Init end
      [] 8 then if Init.xp>30 then {AdjoinList Init [xp#(Init.xp mod 30) lx#9 hp#28]}  else Init end
      [] 9 then if Init.xp>50 then {AdjoinList Init [xp#(Init.xp mod 50) lx#10 hp#30]}  else Init end
      [] 10 then Init   end
   
   end

   fun {SetHpMax State}
      case State.lx of 5 then {Record.adjoin State p(hp:20) $}
      [] 6 then {Record.adjoin State p(hp:22) $}
      [] 7 then {Record.adjoin State p(hp:24) $}
      [] 8 then {Record.adjoin State p(hp:26) $}
      [] 9 then {Record.adjoin State p(hp:28) $}
      [] 10 then {Record.adjoin State p(hp:30) $}
      end
   end

  {Show coucou4} 
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


   fun{Attack Y Init}
      X in {Send Y get(X)}
      ((((6+X.lx-Init.lx)*9))>({OS.rand} mod 100))
   end


   fun{UpdateXp Perdant Status}
      {AdjoinAt Status xp ((Status.xp)+(Perdant.lx))}
   end



   fun{GagneContre Y Status}
      Perdant in {Send Y get(Perdant)}
      {LevelUp {UpdateXp Perdant Status}}
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
	    if (Rand < 100 ) then
	       {Browse "Remise d'xp à"}
	       {Browse {Send Wilds.N getState($)}}
	       {Send Width.N addXp(1)}
	       {Send Width.N levelup}
	    end
	 end
      end
   in
      {Recurs Wilds Width}
   end
   


%%%%%%%%%%%%% Fonction mere Pokemoz %%%%%%%%%%%%%%%%%%


   fun{FPokemoz Msg State}
      case Msg
      of sethp(X) then {SetHp State X} 
      [] setlx(X) then {SetLx State X} 
      [] setxp(X) then {SetXp State X}
      [] addXp(X) then {SetXp State (State.xp + X)}
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

   {Show coucouEnd}

end
