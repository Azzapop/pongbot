require "yaml"
settings = YAML::load_file("config/db.yml")
# Sequel Configuration
puts settings.inspect
DB = Sequel.connect(settings[ENV['RACK_ENV']])
