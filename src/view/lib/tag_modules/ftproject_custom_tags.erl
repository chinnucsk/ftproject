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
  lists:flatten(["<li><a href='/main/tags/"++X++"' >"++X++"</a></li>"||{_,_,X,_}<-boss_db:find(tags,[])]).

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