module Vorsprung
  class CLI < Thor
    include Thor::Actions

    desc "new APP_NAME", "create a new Rails app called APP_NAME"
    def new(app_name)
      say "Vorsprinkling you a new Rails app..."
      run "rails new #{app_name}", capture: true
      template "Procfile", "#{app_name}/Procfile"
      template ".env", "#{app_name}/.env"
      template "secrets.yml", "#{app_name}/config/secrets.yml"
    end
  end
end
