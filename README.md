###################################################
# HTC_Module
# HIV Testing and Counselling module
###################################################

Clone the HTC application from the Baobab Health Trust organisation github account as below
Using ssh: (if you use ssh to clone)
    git clone git@github.com:BaobabHealthTrust/HTC_Module.git

            --- OR ---

Using https: (if you use https to clone)
    git clone https://github.com/BaobabHealthTrust/HTC_Module.git

Setup Settings.

1. Use ruby version 2.1.2 
2. Use rails 4.1.0 or above

Copy config/database.yml.example to config/database.yml

Copy config/database.yml.example to config/database.yml

Sspecify your database settings('name', 'username', and 'password') in config/database.yml

Run the command below:

  ./bin/initial_database_setup.sh development|production

Done, Yeay...!!!
Nothing to do.
Run your application.
