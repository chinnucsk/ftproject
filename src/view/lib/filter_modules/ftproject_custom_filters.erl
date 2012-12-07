-module(ftproject_custom_filters).
-compile(export_all).

% put custom filters in here, e.g.
%
% my_reverse(Value) ->
%     lists:reverse(binary_to_list(Value)).
%
% "foo"|my_reverse   => "oof"

plaindatetime(Value) ->
  {{Y, M, D},{HH,MM,SS}} = Value,
  integer_to_list(HH)++":"++integer_to_list(MM)++":"++integer_to_list(SS)++" "
    ++ integer_to_list(D) ++ "/" ++ integer_to_list(M) ++ "/" ++ integer_to_list(Y).