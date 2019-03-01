listseparator:
  parse ARG list
  sep = ''
  select
    when list == 'list' then sep = ' '
    when list == 'semicolon-list' then sep = ';'
    when list == 'equal-list' then sep = '='
    when list == 'tilde-list' then sep = '~'
    when list == 'underscore-list' then sep = '_'
    otherwise nop
  end
return sep

