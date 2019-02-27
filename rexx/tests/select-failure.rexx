info = 3
select
when infolevel == 1 then; do; fb1 = 1; fb2 = 0; fb3 = 0; fb4 = 0; fb5 = 0; end
when infolevel == 2 then; do; fb1 = 1; fb2 = 1; fb3 = 0; fb4 = 0; fb5 = 0; end
when infolevel == 3 then; do; fb1 = 1; fb2 = 1; fb3 = 1; fb4 = 0; fb5 = 0; end
when info == 2 then; do
fb1 = 1
fb2 = 1
fb3 = 0
fb4 = 0
fb5 = 0
end
when info == 3  then; do
fb1 = 1
fb2 = 1
fb3 = 1
fb4 = 0
fb5 = 0
end
when info == 4 then; do
fb1 = 1
fb2 = 1
fb3 = 1
fb4 = 1
fb5 = 0
end
when info == 5 then; do
fb1 = 1
fb2 = 1
fb3 = 1
fb4 = 1
fb5 = 1
end
otherwise; do
fb1 = 0
fb2 = 0
fb3 = 0
fb4 = 0
fb5 = 0
end
end

say fb1 fb2 fb3 fb4 fb5