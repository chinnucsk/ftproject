-module(ftproject_main_controller, [Req]).
-compile(export_all).

index('GET', []) ->
  Posts = boss_db:find(posts, [], [{limit, 10}, {order_by, post_date_time}, descending]),
  {ok, [{posts, Posts}]}.

post('GET', []) ->
  {redirect, "/"};
post('GET', [Hru]) ->
  Post = boss_db:find_first(posts, [hru, 'equals', http_uri:decode(Hru)]),
  Comm = boss_db:find(comments,[{posts_id,'equals',Post:id()},{ap,'equals',1}],[{order_by,comment_time},descending]),
  case Post of
    undefined -> {redirect, "/"};
    _ -> case Comm of
      []-> {ok, [{post, Post}]};
      _ -> {ok, [{post, Post},{comms,Comm}]}
  end
 end;
post('POST', [Hru]) ->
  Author = Req:post_param("author"),
  Email = Req:post_param("email"),
  Body = Req:post_param("body"),
  Post = boss_db:find_first(posts, [hru, 'equals', http_uri:decode(Hru)]),
  NewCom = comments:new(id,Post:id(),binary:bin_to_list(mochiweb_html:escape(Author)),
    binary:bin_to_list(mochiweb_html:escape(Email)),binary:bin_to_list(mochiweb_html:escape(Body)),calendar:local_time(),0),
  case NewCom:save() of
       {ok,_} ->
         {redirect, "/main/post/"++ http_uri:decode(Hru)};
       {error,ErrorList} ->
         {ok, [{errors, ErrorList},{author,Author},{email,Email},{post,Post},{body,Body}]}
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
