-module(posttags_lib).
-compile(export_all).

% get list of tuple {postid,tagid}
% return result
save(Ar) ->
  saves(Ar, []).

saves(Ar, State) ->
  case Ar of
    [] -> case State of
      [] -> {ok, norm};
      [E] -> {errors, E}
    end;
    [H | []] ->
      {P, T} = H,
      New = posttags:new(id, P, T),
      case New:save() of
        {ok, _} -> saves([], State);
        {error, Error} -> saves([], [[State] | Error])
      end;
    [H | Tail] ->
      {P, T} = H,
      New = posttags:new(id, P, T),
      case New:save() of
        {ok, _} -> saves(Tail, State);
        {error, Error} -> saves(Tail, [[State] | Error])
      end

  end.

% delete from posttags by postid
del_by_post(Post) ->
  DelIds = boss_db:find(posttags, [posts_id, 'equals', Post]),
  DelId = [X || {_, X, _, _} <- DelIds],
  dbps(DelId, []).
dbps(Ids, State) ->
  case Ids of
    [] -> case State of
      [] -> {ok, norm};
      [E] -> {errors, E}
    end;
    [H | []] ->
      case boss_db:delete(H) of
        ok -> dbps([], State);
        {error, Error} -> dbps([], [[State] | Error])
      end;
    [H | Tail] ->
      case boss_db:delete(H) of
        ok -> dbps(Tail, State);
        {error, Error} -> dbps(Tail, [[State] | Error])
      end
  end.
del_by_tagid(Id) ->
  DelIds = boss_db:find(posttags, [tags_id, 'equals', Id]),
  DelId = [X || {_, X,_, _} <- DelIds],
  dbps(DelId, []).
