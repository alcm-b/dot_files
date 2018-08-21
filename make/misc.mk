DD:=$(shell date +%Y-%m-%d_%H%M)

##
## Display help on Makefile targets
usage:
	(echo ./Makefile ; sed -ne 's|~|$(HOME)| ; s/^-\{0,1\}include \(.*Makefile\|.*.mk\)/\1/p' ./Makefile) |\
	while read b; do \
		a=$$(realpath $$b) ;\
		printf "\nSource file '$$a':\n" ;\
		sed -ne '/^##[[:space:]]*/ {s/^##[[:space:]]*/\t/ ; p}; /^[[:alnum:]-]\+:\([^=]\|$$\)/ { s/^\([[:alnum:]-]\+:.*$$\)/\t\t\1/; p; };' $$a;\
	done
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

##
## Upon user request, trigger code linter or any other commands defined in 
## 'f2' target (see .vimrc for F2 key mapping)
tdd:
	touch /tmp/00$$(id -u) 
	while true; do \
		$(MAKE) f2 ; \
		inotifywait -eattrib /tmp/00$$(id -u) ;\
	done
