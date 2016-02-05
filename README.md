###################################################
# HTC_Module
# HIV Testing and Counselling module
###################################################

System Configuration
--------------------
Clone the HTC application from the Baobab Health Trust organisation github account as below

    Using ssh: (if you use ssh to clone)
        git clone git@github.com:BaobabHealthTrust/HTC_Module.git

            --- OR ---

    Using https: (if you use https to clone)
        git clone https://github.com/BaobabHealthTrust/HTC_Module.git

Toolkit Integration
-------------------
Navigate to the public directory in the /app directory and integrate TouchScreen Toolkit by cloning it form github.
    cd app

System Requirements
-------------------
    1. Use ruby version 2.1.2
    2. Use rails 4.1.0 or above

Get database.yml
------------------
Copy the config/database.yml.example to config/database.yml

    cp config/database.yml.example to config/database.yml

Get settings.yml
------------------
Copy config/settings.yml.example to config/settings.yml

    cp config/settings.yml.example to config/settings.yml

Setup database.yml
------------------
Open config/database.yml file using your favourite editor and modify where necessary to specify your database settings.('name', 'username', and 'password' => possible recommendations)

Initialize system
-----------------
Run the command below:

    ./bin/initial_database_setup.sh development|production

Summary
-------
Yeay...!!!
Done. Nothing to do.
Run your application.
