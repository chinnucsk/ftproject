-module(comments,[Id,PostsId,Author,Email,Body,CommentTime]).
-compile(export_all).
-belongs_to(posts).

