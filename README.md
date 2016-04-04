###################################################
# HTC_Module
# HIV Testing and Counselling module
###################################################

System Requirements
-------------------
Verify your system meets the following requirements for a successful application setup.

    1. Use ruby version 2.1.2
    2. Use rails 4.1.0 or above

Get Application
--------------------
Clone the HTC application from the Baobab Health Trust organisation github account as below

Using ssh: (if you use ssh to clone)

    git clone git@github.com:BaobabHealthTrust/HTC_Module.git

            --- OR ---

Using https: (if you use https to clone)

    git clone https://github.com/BaobabHealthTrust/HTC_Module.git

Toolkit Integration
-------------------
Integrate TouchScreen Toolkit to the application by navigating into the application's public directory and cloning it from github.
Run command as below to do so:

    cd public/

While in public/ directory, run below commands to clone touchscreentoolkit.

Using ssh: (if you use ssh to clone)
    ------

    git clone git@github.com:BaobabHealthTrust/touchscreentoolkit.git

            --- OR ---

Using https: (if you use https to clone)
    --------

    git clone https://github.com/BaobabHealthTrust/touchscreentoolkit.git

Navigate back into the applications root directory.
Run command as below to do so:

    cd ..

Get database.yml
------------------
Copy the config/database.yml.example to config/database.yml

    cp config/database.yml.example config/database.yml

Get settings.yml
------------------
Copy config/settings.yml.example to config/settings.yml

    cp config/settings.yml.example config/settings.yml

Setup database.yml
------------------
Open config/database.yml file using your favourite editor and modify where necessary to specify your database settings.
('name', 'username', and 'password' => possible recommendations)

Setup settings.yml
------------------
NB: Make sure BART application is running on your server and take note of the port number.

Open config/database.yml file using your favourite editor and modify the below settings.
    create_from_remote: true
    bart2_address: localhost:port, where port is the port number BART is running on. The one you noted earlier above.

Initialize system
-----------------
Run the command below:

    ./bin/initial_database_setup.sh development|production

Summary
-------
Yeay...!!!

Done. Nothing to do.

Run your application.
