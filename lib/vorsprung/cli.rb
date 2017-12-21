module Vorsprung
  class CLI < Thor
    include Thor::Actions

    desc "new APP_NAME", "create a new Rails app called APP_NAME"
    def new(app_name)
      say "Vorsprinkling you a new Rails app..."
      run "rails new #{app_name} --database=postgresql", capture: true
      template "Procfile", "#{app_name}/Procfile"
      template ".env", "#{app_name}/.env"
      template "Gemfile", "#{app_name}/Gemfile", force: true
      template "secrets.yml", "#{app_name}/config/secrets.yml", force: true
    end
  end
end
