PGSQLLOG_CUT=CUT ==================================
PGSQL_TESTDIR=test/logs/pgsql_logs
PGFOUINE=/home/alf/bin/pgfouine-1.2/pgfouine.php
MYSQLDUMP=mysqldump -n -t --xml
pager = vim - -R
##
##	make dump
##		Make a dump of MySQL/PostrgeSQL database
##		Parameters:
##			REMOTEHOST - database host
##			REMOTEUSER - user name for SSH connection to REMOTEHOST
##			DUMP_CMD   - database-specific command that creates a database dump
##				PostgreSQL example: DUMP_CMD=pg_dump -U wwwuser hsphere
dump:
	mkdir -p test/logs/dump
	ssh $(REMOTEUSER)@$(REMOTEHOST) "$(DUMP_CMD)" > test/logs/dump/`date +%Y-%m-%d_%H%M%S`_$(REMOTEHOST).dump 
##
##	make dump-view
##		View the most recent database dump in vim
dump-view:
	vim -R "+set filetype=sql" `ls -1t test/logs/dump/*_$(REMOTEHOST).dump  | head -1`
##
##	make dump-diff
##		Make database snapshot and show difference between current and previous dumps
##		Each part of the diff is annotated using the table name
dump-diff: dump dump-history
	# find test/logs/dump -maxdepth 1 -iname \*_$(REMOTEHOST).dump -type f | sort | tail -2 | xargs diff -u -F "COPY\|<table_data" | vim - -R
	# ls -1t test/logs/dump/*_$(REMOTEHOST).dump | head -2 | tac | xargs diff -u -F "COPY\|<table_data" |
##
## make dump-history
##		View dump diff for existing dumps
dump-history: step=1
dump-history:
	ls -1t test/logs/dump/*_$(REMOTEHOST).dump  | sed -n '$(step),+1 p' | tac | xargs diff -u -F "COPY\|table_data" | $(pager)
## 
##	make pgsqlreport-start
##		Start logging SQL queries
pgsqlreport-start:
	ssh root@$(REMOTEHOST) "logger -p local7.info '$(PGSQLLOG_CUT)'"
pgsqlreport: LOGFILE=/var/log/messages
pgsqlreport:
	CUTFROM=`ssh root@$(REMOTEHOST) "grep -n '$(PGSQLLOG_CUT)' $(LOGFILE) | tail -1 | cut -d: -f 1"` \
		&& ssh root@$(REMOTEHOST) "awk 'NR>$$CUTFROM' $(LOGFILE) " > $(PGSQL_QUERYLOG)
## 
##	make pgsqlreport-get
##		Generate SQL query report using PgFouine
pgsqlreport-pgfouine: LOGFILE=/var/log/messages
pgsqlreport-pgfouine:
	mkdir -p $(PGSQL_TESTDIR)
	#scp root@$(REMOTEHOST):/hsphere/local/var/postgres/postgres.log $(PGSQL_TESTDIR)/postgres.$(REMOTEHOST).log
	scp root@$(REMOTEHOST):$(LOGFILE) $(PGSQL_TESTDIR)/postgres.$(REMOTEHOST).log
	LOGREPORT=$(PGSQL_TESTDIR)/`date +%Y-%m-%d_%H%M%S`_$(REMOTEHOST).log \
			&& CUTFROM=`grep -n $(PGSQLLOG_CUT) $(PGSQL_TESTDIR)/postgres.$(REMOTEHOST).log | tail -1 | cut -d: -f 1` \
			&& awk "NR>$$CUTFROM" $(PGSQL_TESTDIR)/postgres.$(REMOTEHOST).log  > $$LOGREPORT \
			&& $(PGFOUINE)  -syslogident pgsql -file $$LOGREPORT -report history -report $$LOGREPORT.html=overall,bytype,slowest,n-mosttime,n-mostfrequent,n-slowestaverage -format html-with-graphs > $$LOGREPORT.history.html \
			&& echo "pgFouine report: $$LOGREPORT.html"
