-module (fancier).
-compile(export_all).

head([H | _]) -> H.
second([_First, Second | _]) -> Second.

same(X, X) -> true;
same(_, _) -> false.

valid_time({Date = {Y,M,D}, Time = {H,Min,S}}) ->
    io:format("The Date tuple (~p) says today is: ~p/~p/~p,~n",[Date,Y,M,D]),
    io:format("The time tuple (~p) indicates: ~p:~p:~p.~n", [Time,H,Min,S]);
valid_time(_) ->
    io:format("Stop feeding me wrong data!~n").

old_enough(Age) when Age >= 16 -> true;
old_enough(_) -> false.
