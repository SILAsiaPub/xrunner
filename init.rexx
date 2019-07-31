/* auto generated tasks.rexx */
say ''
say center('  Loading tasks variables  ',80,'-') 
scripts = projectpath'/scripts'
infile = ''
outfile = ''
taskerr = 0
taskskip = 0
count = 0
fatal = 0
skiptasks = 0
nameext = 'name'
if ADDRESS() == 'CMD' 
	then 
	Do 
		slash = '\'
		delete = 'del'
		move = 'move'
		makedir = 'md'
	end
	else
	Do
		slash = '/'
		delete = 'rm'
		move = 'mv'
		makedir = 'mkdir -p'
	end