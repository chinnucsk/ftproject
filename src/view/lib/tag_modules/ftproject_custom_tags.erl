-module(ftproject_custom_tags).
-compile(export_all).

% put custom tags in here, e.g.
%
% reverse(Variables, Options) ->
%     lists:reverse(binary_to_list(proplists:get_value(string, Variables))).
%
% {% reverse string="hello" %} => "olleh"
%
% Variables are the passed-in vars in your template

links(Variables,Option)->
lists:flatten(["<li><a href='"++Y++"' target='_blank' >"++X++"</a></li>"||{_,_,X,Y}<-boss_db:find(links,[])]).

tags_list(Variables,Option) ->
  F = fun(X)->
    boss_db:count(posttags,[tags_id,'equals',X])
    end,
  lists:flatten(["<li><a href='/main/tags/"++X++"' >"++X++"("++integer_to_list(F(Y))++")</a></li>"
    ||{_,Y,X,_}<-boss_db:find(tags,[])]).

tags_by_post(Variables,Option)->
  PostN = proplists:get_value(postnum,Variables),
  TagsL = boss_db:find(posttags,[posts_id,'equals',PostN]),
  F = fun(X) ->
    case boss_db:find(X) of
      {_,_,Y,_} -> Y;
      undefined  -> ":("
    end
  end,
  Tags =[{X,F(X)}||{_,_,_,X}<-TagsL],
  lists:flatten(["<a href='/main/tags/"++Y++"'>"++Y++"</a>  "||{_,Y}<-Tags]).
posts_by_tag(Variables,Option) ->
  TagN= proplists:get_value(tagnum,Variables),
  PostL = boss_db:find(posttags,[tags_id,'equals',TagN]),
  F = fun(X) ->
      case boss_db:find(X) of
        {_,_,Y,_,_,_} -> Y;
        undefined -> ":("
      end
     end,
   Posts =[{X,F(X)}||{_,_,X,_}<-PostL],
   NumPosts = lists:zip(Posts, lists:seq(1, length(Posts))),
   lists:flatten(["<a href='/main/post/"++Y++"'>"++integer_to_list(Num)++"</a>  "||{{_,Y}, Num} <- NumPosts]).

newcommentsall(Variables,Option) ->
  integer_to_list(boss_db:count(comments,[ap,'equals',0])).

comments_by_post(Variables,Option) ->
  PostN = proplists:get_value(postnum,Variables),
   binary:bin_to_list(unicode:characters_to_binary("<a href='/admin/coms/'>Всего</a>("))++
   integer_to_list(boss_db:count(comments,[posts_id,'equals',PostN]))++
   unicode:characters_to_list("),")++
   binary:bin_to_list(unicode:characters_to_binary("<a href='/admin/comnew/'>новых</a>(<strong>"))++
   integer_to_list(boss_db:count(comments,[{posts_id,'equals',PostN},{ap,'equals',0}]))++
   unicode:characters_to_list("</strong>)").
 comments_by_post_main(Variables,Option) ->
   PostN = proplists:get_value(postnum,Variables),
   binary:bin_to_list(unicode:characters_to_binary("Комментарии: "))++
   integer_to_list(boss_db:count(comments,[posts_id,'equals',PostN])).
