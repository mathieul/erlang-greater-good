-module (what_the_if).
-export ([heh_fine/1]).

heh_fine(N) ->
  if N =:= 1 ->
    works;
  true ->
   ok
 end.
