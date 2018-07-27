# Load the rails application
require File.expand_path('../application', __FILE__)

# Load the app's custom environment variables here, so that they are loaded before environments/*.rb
# via https://stackoverflow.com/questions/4911607/is-it-possible-to-set-env-variables-for-rails-development-environment-in-my-code/11765775#11765775
app_environment_variables = File.join(Rails.root, 'config', 'app_environment_variables.rb')
load(app_environment_variables) if File.exists?(app_environment_variables)

# Initialize the rails application
Foursweep::Application.initialize!
