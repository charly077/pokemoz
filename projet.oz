
% creation d'une fonction créatrice de portobject qui renvoie un port
declare
fun {NewPortObject Behaviour Init}
   proc{MsgLoop S1 State}
      case S1 of Msg|S2 then
	 {MsgLoop S2 {Behaviour Msg State}}
      [] nil then skip
      end
   end
   Sin
in
   thread {MsgLoop Sin Init} end
   {NewPort Sin}
end





