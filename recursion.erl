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

take(List, Number) -> take(List, Number, []).
take(_, 0, Acc) -> reverse(Acc);
take([Head | Rest], Number, Acc) when Number > 0 ->
  take(Rest, Number - 1, [Head | Acc]).

zip(List1, List2) -> zip(List1, List2, []).
zip([], _, Acc) -> lists:reverse(Acc);
zip(_, [], Acc) -> lists:reverse(Acc);
zip([Head1 | Rest1], [Head2 | Rest2], Acc) ->
  zip(Rest1, Rest2, [{Head1, Head2} | Acc]).

qsort([]) -> [];
qsort([Pivot | Rest]) ->
  { Smaller, Larger } = partition(Rest, Pivot, [], []),
  qsort(Smaller) ++ [ Pivot ] ++ qsort(Larger).

partition([], _, Smaller, Larger) -> { Smaller, Larger };
partition([Head | Tail], Pivot, Smaller, Larger) ->
  if Head =< Pivot -> partition(Tail, Pivot, [ Head | Smaller ], Larger);
     Head > Pivot  -> partition(Tail, Pivot, Smaller, [ Head | Larger ])
  end.

lc_qsort([]) -> [];
lc_qsort([ Pivot | Rest]) ->
  lc_qsort([Smaller || Smaller <- Rest, Smaller =< Pivot])
  ++ [ Pivot ] ++
  lc_qsort([Larger || Larger <- Rest, Larger > Pivot]).
