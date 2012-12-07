-module(posts, [Id, Hru, PostTitle, PostBody, PostDateTime]).
-compile(export_all).
-has({posttags, many}).
-has({comments, many}).

validation_tests() ->

  [{fun() -> length(PostTitle) > 0 end,
  unicode:characters_to_binary("Название записи не может быть пустым")
    },
    {fun() -> length(PostBody) > 0 end,
   unicode:characters_to_binary("Текст записи не может быть пустым")
      },
    {fun() -> length(Hru) > 0 end,
   unicode:characters_to_binary("ЧПУ не может быть пустым")
      }].
