src?=src
REPOLIST=find $(src) -maxdepth 2 -type l | xargs -n 1 readlink -f  | sort | uniq |  xargs -n 1
##
## Run 'svn update' for all SVN repo symlinks found in the given directory
up:
	$(REPOLIST) svn up --non-interactive
##
## Run 'svn status' for all SVN repo symlinks found in the given directory
st:
	$(REPOLIST) svn st --non-interactive 
##
## Run 'svn diff' on all SVN repo symlinks found in the given directory
diff:
	$(REPOLIST) svn diff -x -b | vim - -R 
##
## Create a patch for given source directories
patch: PATCHFILE=patches/$(src)/$(DD)_$(name).patch
patch:
	mkdir -p `dirname $(PATCHFILE)`
	$(REPOLIST) svn diff -x -b > $(PATCHFILE)
	@echo $(PPATCHFILE)
