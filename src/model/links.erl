-module(links,[Id,Name,Url]).
-compile(export_all).

validation_tests() ->

  [{fun() -> length(Name) > 0 end,
    unicode:characters_to_binary("Название ссылки не может быть пустым")
  },
    {fun() -> length(Url) > 0 end,
      unicode:characters_to_binary("Адрес ссылки не может быть пустым")
    }].
