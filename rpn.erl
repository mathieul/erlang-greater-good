-module (rpn).
-export ([calc/1]).

calc(Expression) when is_list(Expression) ->
  Tokens = string:tokens(Expression, " "),
  lists:foldl(fun process/2, [], Tokens).

process("+", [B, A | Stack]) -> [A + B | Stack];
process("-", [B, A | Stack]) -> [A - B | Stack];
process("*", [B, A | Stack]) -> [A * B | Stack];
process("/", [B, A | Stack]) -> [A / B | Stack];
process(Number, Stack) -> [read_number(Number) | Stack].

read_number(Number) ->
  case string:to_float(Number) of
    { error, no_float } -> list_to_integer(Number);
    { Float, _ } -> Float
  end.
