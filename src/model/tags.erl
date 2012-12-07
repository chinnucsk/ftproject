-module(tags,[Id,TagName,Stat]).
-compile(export_all).
-has({posttags,many}).

validation_tests() ->

  [{fun() -> length(TagName) > 0 end,
    unicode:characters_to_binary("Тэг не может быть пустым")
  }].
