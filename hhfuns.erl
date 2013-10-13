-module (hhfuns).
-compile(export_all).

one() -> 1.
two() -> 2.

add(X, Y) -> X() + Y().

increment([]) -> [];
increment([ H | T ]) -> [ H + 1 | increment(T) ].

decrement([]) -> [];
decrement([ H | T ]) -> [ H - 1 | decrement(T) ].

map(_, []) -> [];
map(F, [ H | T ]) -> [ F(H) | map(F, T) ].

incr(X) -> X + 1.
decr(X) -> X - 1.

maxx([]) -> undefined;
maxx([ H | T ]) -> maxx(T, H).
maxx([], Max) -> Max;
maxx([ H | T ], Max) ->
  if H >  Max -> maxx(T, H);
     H =< Max -> maxx(T, Max)
  end.
