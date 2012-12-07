-module(ftproject_main_controller, [Req]).
-compile(export_all).

index('GET', []) ->
  Posts = boss_db:find(posts, [], [{limit, 10}, {order_by, post_date_time}, descending]),
  {ok, [{posts, Posts}]}.

post('GET', []) ->
  {redirect, "/"};
post('GET', [Hru]) ->
  Post = boss_db:find_first(posts, [hru, 'equals', http_uri:decode(Hru)]),
  case Post of
    undefined -> {redirect, "/"};
    _ -> {ok, [{post, Post}]}
  end.
tags('GET', []) ->
  {redirect, "/"};
tags('GET', [Tag]) ->
  {_, TagId, _, _} = boss_db:find_first(tags, [tag_name, 'equals', http_uri:decode(Tag)]),
  PostsId = boss_db:find(posttags, [tags_id, 'equals', TagId]),
  case PostsId of
    undefined -> {ok, []};
    _ -> PostsL = [X || {_, _, X, _} <- PostsId],
      Posts = boss_db:find(posts, [id, 'in', PostsL], [descending]),
      {ok, [{posts, Posts},{tag,http_uri:decode(Tag)}]}

  end.
