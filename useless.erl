-module (useless).
-export ([hello/0, add_two/1]).
-import (io, [format/1]).

hello() ->
  format("hello there~n").

add_two(Num) ->
  Num + 2.
