-module (recursion).
-compile(export_all).

duplicate(Number, Term) ->
  duplicate(Number, Term, []).
duplicate(0, _, Acc) ->
  Acc;
duplicate(Number, Term, Acc) when Number > 0 ->
  duplicate(Number - 1, Term, [Term | Acc]).

len(List) -> len(List, 0).
len([], Acc) -> Acc;
len([_ | List], Acc) ->
  len(List, Acc + 1).

reverse(List) -> reverse(List, []).
reverse([], Acc) -> Acc;
reverse([Head | Rest], Acc) ->
  reverse(Rest, [Head | Acc]).
