-module(ftproject_admin_controller, [Req]).
-compile(export_all).

index('GET', []) ->
  Posts = boss_db:find(posts, [], [{limit, 10}, {order_by, post_date_time}, descending]),
  {ok, [{posts, Posts}]}.

newpost('GET', []) ->
  Tags = boss_db:find(tags, []),
  {ok, [{tags, Tags}]};
newpost('POST', []) ->
  Title = Req:post_param("title"),
  Hru = Req:post_param("hru"),
  Body = Req:post_param("body"),
  TagL = boss_db:find(tags, []),
  F = fun(X) -> case Req:post_param(X) of
    undefined -> "no";
    "on" -> "yes"
  end end,
  NewTags = [{TN, K, KName, F(K)} || {TN, K, KName, _} <- TagL],
  NewRec = posts:new(id, Hru, Title, Body, calendar:local_time()),
  case boss_db:find_first(posts, [hru, 'equals', http_uri:decode(Hru)]) of
    undefined ->
      case NewRec:save() of
        {ok, NN} ->
          Ntag = [{NN:id(), K} || {_, K, _, Y} <- NewTags, Y == "yes"],
          case posttags_lib:save(Ntag) of
            {ok, _} -> {redirect, "/admin"};
            {error, ErrorList} -> {ok, [{errors, ErrorList}, {post, NewRec}, {tags, NewTags}]}
          end;
        {error, ErrorList} -> {ok, [{errors, ErrorList}, {post, NewRec}, {tags, NewTags}]}
      end;
    _ ->
      {ok, [{errors, unicode:characters_to_binary("Этот ЧПУ уже используется")}, {post, NewRec}]}
  end.

edit('GET', []) ->
  {redirect, "/admin"};
edit('GET', [Hru]) ->
  Post = boss_db:find_first(posts, [hru, 'equals', http_uri:decode(Hru)]),
  TagL = boss_db:find(tags, []),
  F = fun(X, Y) ->
    case boss_db:find(posttags, [{posts_id, 'equals', X}, {tags_id, 'equals', Y}]) of
      [] -> "no";
      _ -> "yes"
    end
  end,
  Tags = [{TN, K, KName, F(Post:id(), K)} || {TN, K, KName, _} <- TagL],
  case Post of
    undefined -> {redirect, "/admin"};
    _ -> {ok, [{post, Post}, {tags, Tags}]}
  end;
edit('POST', [Hru]) ->
  Post = boss_db:find_first(posts, [hru, 'equals', http_uri:decode(Hru)]),
  Titlenew = Req:post_param("title"),
  Hrunew = Req:post_param("hru"),
  Bodynew = Req:post_param("body"),
  TagL = boss_db:find(tags, []),
  F = fun(X) -> case Req:post_param(X) of
    undefined -> "no";
    "on" -> "yes"
  end end,
  NewTags = [{TN, K, KName, F(K)} || {TN, K, KName, _} <- TagL],
  Edited = Post:set([{hru, Hrunew}, {post_title, Titlenew}, {post_body, Bodynew}]),
  case ((http_uri:decode(Hru) == Hrunew) or (boss_db:find_first(posts, [hru, 'equals', Hrunew]) == undefined)) of
    false ->
      {ok, [{errors, unicode:characters_to_binary("Этот ЧПУ уже используется")}, {post, Edited}, {tags, NewTags}]};
    true ->
      case Edited:save() of
        {ok, NN} -> case posttags_lib:del_by_post(NN:id()) of
          {ok, _} -> Ntag = [{NN:id(), K} || {_, K, _, Y} <- NewTags, Y == "yes"],
            case posttags_lib:save(Ntag) of
              {ok, _} -> {redirect, "/admin"};
              {error, ErrorList} -> {ok, [{errors, ErrorList}, {post, Edited}, {tags, NewTags}]}
            end;
          {error, ErrorList} -> {ok, [{errors, ErrorList}, {post, Edited}, {tags, NewTags}]}
        end;
        {error, ErrorList} -> {ok, [{errors, ErrorList}, {post, Edited}, {tags, NewTags}]}
      end
  end.
delete('GET', []) ->
  {redirect, "/admin"};
delete('GET', [Hru]) ->
  Post = boss_db:find_first(posts, [hru, 'equals', http_uri:decode(Hru)]),
  case Post of
    undefined -> {redirect, "/admin"};
    _ -> posttags_lib:del_by_post(Post:id()),
      boss_db:delete(Post:id()),
      {redirect, "/admin"}
  end.
links('GET', []) ->
  Links = boss_db:find(links, [], [{limit, 10}]),
  {ok, [{links, Links}]}.
newlink('GET', []) ->
  {ok, []};
newlink('POST', []) ->
  Name = Req:post_param("name"),
  Url = Req:post_param("url"),
  NewRec = links:new(id, Name, Url),
  case NewRec:save() of
    {ok, _} -> {redirect, "/admin/links"};
    {error, ErrorList} -> {ok, [{errors, ErrorList}, {link, NewRec}]}
  end.

linkedit('GET', []) ->
  {redirect, "/admin"};
linkedit('GET', [Id]) ->
  Link = boss_db:find_first(links, [id, 'equals', http_uri:decode(Id)]),
  case Link of
    undefined -> {redirect, "/admin/links"};
    _ -> {ok, [{link, Link}]}
  end;
linkedit('POST', [Id]) ->
  Link = boss_db:find_first(links, [id, 'equals', http_uri:decode(Id)]),
  Namenew = Req:post_param("name"),
  Urlnew = Req:post_param("url"),
  Edited = Link:set([{name, Namenew}, {url, Urlnew}]),
  case Edited:save() of
    {ok, _} -> {redirect, "/admin/links"};
    {error, ErrorList} -> {ok, [{errors, ErrorList}, {link, Edited}]}
  end.
linkdelete('GET', []) ->
  {redirect, "/admin"};
linkdelete('GET', [Id]) ->
  Link = boss_db:find_first(links, [id, 'equals', http_uri:decode(Id)]),
  case Link of
    undefined -> {redirect, "/admin/links"};
    _ -> boss_db:delete(Link:id()),
      {redirect, "/admin/links"}
  end.

tegs('GET', []) ->
  Tags = boss_db:find(tags, [], [{limit, 10}]),
  {ok, [{tags, Tags}]}.
newtag('GET', []) ->
  {ok, []};
newtag('POST', []) ->
  TagName = Req:post_param("tag_name"),
  NewRec = tags:new(id, TagName, "no"),
  case NewRec:save() of
    {ok, _} -> {redirect, "/admin/tegs"};
    {error, ErrorList} -> {ok, [{errors, ErrorList}, {tag, NewRec}]}
  end.
tagdelete('GET', []) ->
  {redirect, "/admin/tegs"};
tagdelete('GET', [Id]) ->
  Tag = boss_db:find_first(tags, [id, 'equals', http_uri:decode(Id)]),
  case Tag of
    undefined -> {redirect, "/admin/tegs"};
    _ -> posttags_lib:del_by_tagid(Tag:id()),
      boss_db:delete(Tag:id()),
      {redirect, "/admin/tegs"}
  end.