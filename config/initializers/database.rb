require "yaml"
template = ERB.new File.new("config/db.yml").read
settings = YAML.load template.result(binding)

# Sequel Configuration
DB = Sequel.connect(settings[ENV['RACK_ENV']])
