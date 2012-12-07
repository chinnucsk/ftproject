-module(comments,[Id,PostsId,Author,Email,Body,CommentTime,Ap::integer()]).
-compile(export_all).
-belongs_to(posts).

validation_tests() ->

  [{fun() -> ((length(Author) > 0) and (length(Author) < 20)) end,
    unicode:characters_to_binary("Имя автора  должно содержать от 1 до 20 символов")
  },
    {fun() -> ((length(Email) > 0) and (length(Email) < 50)) end,
      unicode:characters_to_binary("Email должен содержать от 1 до 50 символов")
    },
    {fun() -> ((length(Body) > 0) and (length(Body) < 500)) end,
      unicode:characters_to_binary("Содержимое комментария должно содержить от 1 до 500 символов")
    }].