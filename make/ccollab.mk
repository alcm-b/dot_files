CHANGESET_PATH?=var/ccollab
CHANGESET = $(CHANGESET_PATH)/current/changeset.list 
# Collaborator
ccollab-changeset: up
	CHANGESETDIR=$(CHANGESET_PATH)/$(DD) \
		&& mkdir -p $$CHANGESETDIR \
		&& ( cd $(SVNHOME) && svn -x -w diff ) > $$CHANGESETDIR/changeset.patch \
		&& ( cd $(SVNHOME) && svn st ) | sed -ne "s/^[AMD]\([[:space:]]\++\)\?//p" > $$CHANGESETDIR/changeset.list \
		&& ( cd $(CHANGESET_PATH) && ( [ -s current ] && unlink current) ; ln -s $(DD) current )
		echo vi -o $(CHANGESET_PATH)/current/*

ccollab-addchanges: cllid=new
ccollab-addchanges:
	echo "Changeset:"
	cat $(CHANGESET)
	echo
	FILES=`cat $(CHANGESET) | tr '\n' ' '` \
	&& (cd $(SVNHOME) && ccollab addchanges $(cllid) $$FILES )
##
## Take the most recent review file from download dir; unpack the file and create a patch
ccollab-review: NUM=*
ccollab-review: DOWNLOAD_PATH=/media/sf_Downloads
ccollab-review: CLL_REVIEW_HOME=./tmp/ccollab
ccollab-review: up
	mkdir -p $(CLL_REVIEW_HOME)
	CLLZIP=`ls -1t $(DOWNLOAD_PATH)/review-$(NUM)-files*.zip | head -1` ; \
	CLLFILE=`basename "$$CLLZIP"`  ; \
	CURRENT_REVIEW="$(CLL_REVIEW_HOME)/$${CLLFILE}_$(DD)"; \
	unzip "$$CLLZIP" -d "$$CURRENT_REVIEW" ; \
	cd "$$CURRENT_REVIEW" && find . -type f -exec diff -uNw `dirname $(SVNHOME)`/{} {} \; > "../$$CLLFILE.patch" ; \
	mv "../$$CLLFILE.patch" ./review.patch ; \
	cd .. && ( [ -s current ] && unlink current) ;\
	ln -s $${CLLFILE}_$(DD) current ;\
	echo "Open:\n(cd \" $(CLL_REVIEW_HOME)/current\" && vim \"review.patch\")"

ccollab-addchanges2: cllid=new
ccollab-addchanges2:
	CHANGESETDIR=$(CHANGESET_PATH)/$(DD) \
		&& mkdir -p $$CHANGESETDIR \
		&& cd /opt/alf/ref/digitalriver/trunk/ \
		&& screen -d -m -L ccollab addchanges $(cllid) . \
		&& sleep 9 \
		&& CHANGESETFILE=`grep '/tmp/edit-list' screenlog.0 | fromdos | tail -1` \
		&& vim $$CHANGESETFILE && cp $$CHANGESETFILE $$CHANGESETDIR ; screen -D -RR \
		&& mv screenlog.* $$CHANGESETDIR/ 
	# ehm, and now... screen?
		#&& ccollab addchanges $(cllid) hsbuild/ > $$CHANGESETDIR/ccollab.out & 
ccollab-commit:
	cat $(CHANGESET) | ( cd $(SVNHOME) && xargs svn commit -m "$(message)")
