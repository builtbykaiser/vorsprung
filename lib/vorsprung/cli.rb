require 'socket'

module Vorsprung
  class CLI < Thor
    include Thor::Actions

    desc "new APP_NAME", "create a new Rails app called APP_NAME"
    def new(app_name)
      @app_name = app_name
      say "Vorsprinkling you a new Rails app..."
      run "rails new #{app_name} --database=postgresql --skip-bundle", capture: true
      add_file "Procfile"
      add_file ".env"
      add_file "Gemfile"
      add_config "secrets.yml"
      setup_databases
      setup_sidekiq
      setup_bootsnap
    end

    def setup_sidekiq
      add_gem "sidekiq", comment: "background jobs"
      add_procfile_process "worker1: RAILS_MAX_THREADS=25 bundle exec sidekiq -q high -q default -q low"
      add_procfile_process "worker2: RAILS_MAX_THREADS=25 bundle exec sidekiq -q low -q default -q high"
      add_config "sidekiq.yml"
    end

    def setup_bootsnap
      add_gem 'bootsnap', required: false, comment: "speeds up app boot time"

      file = "#{app_name}/config/boot.rb"
      line = "require 'bootsnap/setup'"

      unless IO.read(file).match /#{line}/
        insert_into_file file, line, after: /require 'bundler\/setup'.*\n/
      end
    end

    private

    def app_name
      @app_name ||= '.'
    end

    def add_gem(name, required: true, comment: nil)
      line = "gem '#{name}'"
      line += ", require: false" if !required
      line += " ##{comment}" if comment
      line += "\n"

      insert_into_file "#{app_name}/Gemfile",
                       line,
                       after: /# added by Vorsprung\n/
    end

    def add_file(source, destination = nil)
      destination ||= source
      template source,
               "#{app_name}/#{destination}",
               force: true
    end

    def add_config(source, destination = nil)
      destination ||= source
      add_file(source, "config/#{destination}")
    end

    def add_procfile_process(process)
      append_to_file "#{app_name}/Procfile", "#{process}\n"
    end

    # this sets up Postgres and Redis with Docker
    def setup_databases
      postgres_user = app_name
      postgres_pass = SecureRandom.urlsafe_base64
      postgres_port = find_open_port
      redis_port = find_open_port

      add_env "REDIS_URL",
              "redis://localhost:#{redis_port}"

      add_env "DATABASE_URL",
              "postgres:///#{postgres_user}:#{postgres_pass}@localhost:#{postgres_port}",
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

    def add_env(key, value, skip_secrets: false)
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
