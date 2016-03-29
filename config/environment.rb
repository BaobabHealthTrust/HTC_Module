# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
HTCModule::Application.initialize!
ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS=0")
