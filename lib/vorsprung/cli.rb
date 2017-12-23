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
      setup_databases(app_name)
    end

    private

    # this sets up Postgres and Redis with Docker
    def setup_databases(app_name)
      postgres_user = app_name
      postgres_pass = SecureRandom.urlsafe_base64
      postgres_port = find_open_port
      redis_port = find_open_port

      add_env "REDIS_URL",
              "redis://localhost:#{redis_port}",
              app_name

      add_env "DATABASE_URL",
              "postgres:///#{postgres_user}:#{postgres_pass}@localhost:#{postgres_port}",
              app_name,
              skip_secrets: true

      template "database.yml",
               "#{app_name}/config/database.yml",
               force: true

      template "docker-compose.yml",
               "#{app_name}/docker-compose.yml",
               postgres_user: postgres_user,
               postgres_pass: postgres_pass,
               postgres_port: postgres_port,
               redis_port:    redis_port
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

    def add_env(key, value, app_name, skip_secrets: false)
      insert_into_file "#{app_name}/.env",
                       "#{key.upcase}='#{value}'",
                       after: /SECRET_KEY_BASE='\h+'\n/

      unless skip_secrets
        insert_into_file "#{app_name}/config/secrets.yml",
                         "#{key.downcase}: <%= ENV[\"#{key.upcase}\"] %>",
                         after: /secret_key_base:.*\n/
      end
    end
  end
end
