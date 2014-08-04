#!/bin/bash

usage(){
  echo "Usage: $0 ENVIRONMENT SITE"
  echo
  echo "ENVIRONMENT should be: development|test|production"
  #echo "Available SITES:"
  #ls -1 ../db/data
}

ENV=$1
#SITE=$2

if [ -z "$ENV" ] ; then
  usage
  exit
fi

set -x # turns on stacktrace mode which gives useful debug information

# if [ ! -x config/database.yml ] ; then
#   cp config/database.yml.example config/database.yml
# fi

USERNAME=`ruby -ryaml -e "puts YAML::load_file('config/database.yml')['${ENV}']['username']"`
PASSWORD=`ruby -ryaml -e "puts YAML::load_file('config/database.yml')['${ENV}']['password']"`
DATABASE=`ruby -ryaml -e "puts YAML::load_file('config/database.yml')['${ENV}']['database']"`
HOST=`ruby -ryaml -e "puts YAML::load_file('config/database.yml')['${ENV}']['host']"`

#echo "DROP DATABASE $DATABASE;" | mysql --host=$HOST --user=$USERNAME --password=$PASSWORD
echo "CREATE DATABASE $DATABASE;" | mysql --host=$HOST --user=$USERNAME --password=$PASSWORD

mysql --host=$HOST --user=$USERNAME --password=$PASSWORD $DATABASE < db/openmrs_1_9_initial.sql
mysql --host=$HOST --user=$USERNAME --password=$PASSWORD $DATABASE < db/openmrs_metadata_1_9.sql
#mysql --host=$HOST --user=$USERNAME --password=$PASSWORD $DATABASE < ../db/data/${SITE}/${SITE}.sql
mysql --host=$HOST --user=$USERNAME --password=$PASSWORD $DATABASE < db/malawi_regions.sql
echo "After completing database setup"

