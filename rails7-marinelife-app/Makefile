

populate:
	MAX_FILES_PER_DIR=1000 rake db:seed

populate-from-scratch:
	rake db:drop
	rake db:migrate
	make populate
