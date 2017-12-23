require 'socket'

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
      setup_database(app_name)
    end

    private

    def setup_database(app_name)
      user = app_name
      pass = SecureRandom.urlsafe_base64
      port = find_open_port
      env = "DATABASE_URL='postgres:///#{user}:#{pass}@localhost:#{port}'"

      template "database.yml", "#{app_name}/config/database.yml", force: true
      insert_into_file "#{app_name}/.env", env, after: /SECRET_KEY_BASE='\h+'\n/
      template "docker-compose.yml",
               "#{app_name}/docker-compose.yml",
               postgres_port: port,
               postgres_user: user,
               postgres_pass: pass
    end

    # this is an attempt to prevent port collisions when multiple
    # postgres databases are being run on the same development machine.
    # finding a free port: https://stackoverflow.com/a/201528
    def find_open_port
      server = TCPServer.new('127.0.0.1', 0)
      port = server.addr[1]
      server.close
      port
    end
  end
end
