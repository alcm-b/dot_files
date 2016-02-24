CHANGESET_PATH?=var/ccollab
CHANGESET = $(CHANGESET_PATH)/current/changeset.list 
SVNDIR = $(shell readlink -f $(CCOLLAB_SVNBRANCH) )
## 
## Prepare a changeset for a new review
ccollab-changeset: up
	CHANGESETDIR=$(CHANGESET_PATH)/$(DD) \
		&& mkdir -p $$CHANGESETDIR \
		&& ( cd $(SVNDIR) && svn -x -w diff ) > $$CHANGESETDIR/changeset.patch \
		&& ( cd $(SVNDIR) && svn st ) | sed -ne "s/^[AMD]\([[:space:]]\++\)\?//p" > $$CHANGESETDIR/changeset.list \
		&& ( cd $(CHANGESET_PATH) && ( [ -s current ] && unlink current) ; ln -s $(DD) current )
		echo vi -o $(CHANGESET_PATH)/current/*

## 
## Create a review using previously created changeset
ccollab-addchanges: cllid=new
ccollab-addchanges:
	echo "Changeset:"
	cat $(CHANGESET)
	echo
	FILES=`cat $(CHANGESET) | tr '\n' ' '` \
	&& (cd $(SVNDIR) && ccollab addchanges $(cllid) $$FILES )

##
## Take the most recent review file from download dir; unpack the file and produce a patch
ccollab-review: NUM=*
ccollab-review: DOWNLOAD_PATH=/media/sf_Downloads
ccollab-review: CLL_REVIEW_HOME=./tmp/ccollab
ccollab-review: up
	mkdir -p $(CLL_REVIEW_HOME)
	CLLZIP=`ls -1t $(DOWNLOAD_PATH)/review-$(NUM)-files*.zip | head -1` ; \
	CLLFILE=`basename "$$CLLZIP"`  ; \
	CURRENT_REVIEW="$(CLL_REVIEW_HOME)/$${CLLFILE}_$(DD)"; \
	unzip "$$CLLZIP" -d "$$CURRENT_REVIEW" ; \
	cd "$$CURRENT_REVIEW" && find . -type f -exec diff -uNw $(SVNHOME)/{} {} \; > "../$$CLLFILE.patch" ; \
	mv "../$$CLLFILE.patch" ./review.patch ; \
	cd .. && ( [ -s current ] && unlink current) ;\
	ln -s $${CLLFILE}_$(DD) current ;\
	echo "Open:\n(cd \" $(CLL_REVIEW_HOME)/current\" && vim \"review.patch\")"
	cp ./.vimrc $(CLL_REVIEW_HOME)/current 

##
## Commit the approved changeset to SVN
ccollab-commit: up
ccollab-commit:
	cat $(CHANGESET)
	echo 'cd $(SVNDIR) && xargs svn commit -m "$(message)" '
	echo "'Enter' to continue, Ctrl-C to quit."
	read a
	cat $(CHANGESET) | ( cd $(SVNDIR) && xargs svn commit -m "$(message)")
