# HTC_Module
HIV Testing and Counselling module

clone the application 
'git clone git@github.com:BaobabHealthTrust/HTC_Module.git'

Setup Settings.

1. Use ruby version 2.1.2 
2. Use rails 4.0.0 or above

Copy config/database.yml.example to config/database.yml

Specify your database name in config/database.yml

Run `bundle install --local`

From application root directory, run

  `./bin/initial_database_setup.sh development|production`

Load Counseling protocols by loading the counseling_protocols.sql, run

  'mysql -u username -rpassword dbName < counseling_protocols.sql'
