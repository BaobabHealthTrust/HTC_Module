#!/bin/bash
b
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
 
set -e # exit shell script if any one command fails

# if [ ! -x config/database.yml ] ; then
#   cp config/database.yml.example config/database.yml
# fi

bundle install --local
bundle exec rake db:drop db:create

USERNAME=`ruby -ryaml -e "puts YAML::load_file('config/database.yml')['${ENV}']['username']"`
PASSWORD=`ruby -ryaml -e "puts YAML::load_file('config/database.yml')['${ENV}']['password']"`
DATABASE=`ruby -ryaml -e "puts YAML::load_file('config/database.yml')['${ENV}']['database']"`
HOST=`ruby -ryaml -e "puts YAML::load_file('config/database.yml')['${ENV}']['host']"`

echo "DROP DATABASE $DATABASE;" | mysql --host=$HOST --user=$USERNAME --password=$PASSWORD
echo "CREATE DATABASE $DATABASE;" | mysql --host=$HOST --user=$USERNAME --password=$PASSWORD

mysql --host=$HOST --user=$USERNAME --password=$PASSWORD $DATABASE < db/openmrs_1_9_initial.sql -v
mysql --host=$HOST --user=$USERNAME --password=$PASSWORD $DATABASE < db/openmrs_metadata_1_9.sql -v
#mysql --host=$HOST --user=$USERNAME --password=$PASSWORD $DATABASE < ../db/data/${SITE}/${SITE}.sql -v
mysql --host=$HOST --user=$USERNAME --password=$PASSWORD $DATABASE < db/malawi_regions.sql -v

#mysql --host=$HOST --user=$USERNAME --password=$PASSWORD $DATABASE < db/locations.sql -v
mysql --host=$HOST --user=$USERNAME --password=$PASSWORD $DATABASE < db/protocols.sql -v

echo "Running rake migrations"

bundle exec rake db:migrate

echo "Seeding default values using rake"

bundle exec rake db:seed


