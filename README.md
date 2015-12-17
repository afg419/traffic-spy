# Traffic Spy

### A basic analytics webapp written in the Sinatra framework for Ruby using PostgreSQL database.  Designed to link up with javascript generated http requests containing basic information about user data on client sites, store data, and render relevant analytics.

To clone the repo down to local machine, copy the following in terminal:
- $ git clone https://github.com/afg419/traffic-spy.git
- $ bundle

To seed database:
- $rake db:setup
- $rake db:migrate

To run the test suite:
- $rake db:test:prepare
- $rake test

To manually interact with program from command line:

- $Tux ...
- $Exit

Within Tux session, Curl class designed to help load databases manually:
- $Curl.new.load_database_tables 

Outside Tux session, to run server locally from command line: 
- $shotgun

And in the browser...
- localhost:9393
