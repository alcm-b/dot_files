DD:=$(shell date +%Y-%m-%d_%H%M)

##
## Display help on Makefile targets
usage:
	sed -ne '1 s/.*/Makefile/p; s/^include[ -]\+\(.*Makefile\|.*.mk\)/\1/p' ./Makefile | xargs ls |\
	while read b; do \
		a=`readlink -f $$b` ;\
		printf "\nSource $$a:\n" ;\
		sed -ne '/^##[[:space:]]*/ {s/^##[[:space:]]*/\t/ ; p}; /^[[:alnum:]-]\+:$/ { s/^\([[:alnum:]-]\+:\)/\t\1\n/; p; };' $$a;\
	done | less
##
## Move remaining vim swap files off the way (to a temporary diretory)
vimclean:
	mkdir ./-/$(DD)
	find -L ./$(src)/ -name \*sw[pon]  -exec echo mv {} ./-/$(DD) \;
	read yy ; if [ 'y' == $$yy ] ; then find -L ./$(src)/ -name \*sw[pon] -exec echo mv2 {} ./-/${$DD} \; ; fi
## 
## Find two most recently changed files with a given pattern; display diff between them.
diff-recent:
	ls -rt $(file_pattern) | tail -2 | xargs diff -u | vim - -R
