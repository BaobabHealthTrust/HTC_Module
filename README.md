# HTC_Module
HIV Testing and Counselling module

Setup Settings.

1. Use ruby version 2.1.2 
2. Use rails 4.1.0

Copy config/database.yml.example to config/database.yml

Specify your database name in config/database.yml

Run `bundle install --local`

From application root directory, run

  `./bin/initial_database_setup.sh development|production`
  
Run migrations by:

  `rake db:migrate RAILS_ENV=development|production`
  
Finally run the application:

  `rails s [port]`
