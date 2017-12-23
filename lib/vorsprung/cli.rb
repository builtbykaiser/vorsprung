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
      template "database.yml", "#{app_name}/config/database.yml", force: true
      insert_into_file "#{app_name}/.env", database_env(app_name), after: /SECRET_KEY_BASE='\h+'\n/
    end

    private

    def database_env(app_name)
      user = app_name
      pass = SecureRandom.urlsafe_base64
      "DATABASE_URL='postgres:///#{user}:#{pass}@localhost:5432'"
    end
  end
end
