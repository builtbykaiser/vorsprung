RSpec.describe Vorsprung do
  before(:all) { setup }
  after(:all)  { teardown }

  it "has a version number" do
    expect(Vorsprung::VERSION).not_to be nil
  end

  it "uses the proper version of Rails" do
    Dir.chdir(app_path) do
      expect(`rails --version`).to include Vorsprung::RAILS_VERSION
    end
    expect(file("Gemfile")).to match /gem 'rails', '~> #{Vorsprung::RAILS_VERSION}'/
  end

  it "installs a standard Rails app" do
    # some standard Rails files that we've randomly picked
    # to make sure the Rails generator actually ran
    expect(File).to exist("#{app_path}/Rakefile")
    expect(File).to exist("#{app_path}/Gemfile")
    expect(File).to exist("#{app_path}/app/models/application_record.rb")
    expect(File).to exist("#{app_path}/bin/rails")
    expect(File).to exist("#{app_path}/config/application.rb")
    expect(File).to exist("#{app_path}/lib")
    expect(File).to exist("#{app_path}/public")
  end

  it "creates a Procfile" do
    expect(file("Procfile")).to match /web:/
  end

  it "sets the max threads for ActiveRecord connection pool size" do
    expect(file("Procfile")).to match /web.*RAILS_MAX_THREADS=\d/
  end

  it "creates an .env file with SECRET_KEY_BASE" do
    expect(file(".env")).to match /SECRET_KEY_BASE='\h+'/
  end

  it "creates a secrets.yml file with SECRET_KEY_BASE" do
    # include a bit of ERB so we confirm it's being escaped properly
    expect(file("config/secrets.yml")).to match /shared:\n  secret_key_base: <%= ENV/
  end

  context "Database" do
    it "sets PostgreSQL as the database" do
      expect(file("config/database.yml")).to match /adapter: postgresql/
    end

    it "installs the pg gem" do
      expect(file("Gemfile")).to match /gem (?<quote>['"])pg\k<quote>/
    end

    it "uses DATABASE_URL env variable for every environment" do
      expect(file("config/database.yml")).to match /url:  <%= ENV\["DATABASE_URL"\] %>/
      expect(file("config/database.yml")).to match /development:\n  <<: \*default/
      expect(file("config/database.yml")).to match /test:\n  <<: \*default/
      expect(file("config/database.yml")).to match /production:\n  <<: \*default/
    end

    it "adds DATABASE_URL to .env" do
      expect(file(".env")).to match /DATABASE_URL='.*'/
    end

    it "does not add DATABASE_URL to secrets.yml" do
      expect(file("config/secrets.yml")).to_not match /database_url/
    end

    it "uses branched databases" do
      expect(file("config/database.yml")).to match /<% branch = `git symbolic-ref HEAD/
      expect(file("config/database.yml")).to match /development:.*database: dev_<%= branch %>/m
      expect(file("config/database.yml")).to match /test:.*database: test_<%= branch %>/m
    end
  end

  context "Docker: Postgres" do
    it "creates a PostgreSQL database with the right user" do
      expect(file("docker-compose.yml")).to match /POSTGRES_USER: #{app_name}/
    end

    it "creates a PostgreSQL database with the right password" do
      password = file(".env").match(/DATABASE_URL='postgres:\/\/\/#{app_name}:(?<password>.*)@localhost/)[:password]
      expect(file("docker-compose.yml")).to match /POSTGRES_PASSWORD: #{password}/
    end

    it "creates a PostgreSQL database with the right port" do
      port = file(".env").match(/DATABASE_URL='.*@localhost:(?<port>\d+)/)[:port]
      expect(file("docker-compose.yml")).to match /ports:.*#{port}:5432/m
    end
  end

  context "Docker: Redis" do
    it "creates a Redis server with the right port" do
      port = file(".env").match(/REDIS_URL='.*localhost:(?<port>\d+)/)[:port]
      expect(file("docker-compose.yml")).to match /ports:.*#{port}:6379/m
    end

    it "adds REDIS_URL to .env" do
      expect(file(".env")).to match /REDIS_URL='.*'/
    end

    it "adds REDIS_URL to secrets.yml" do
      expect(file("config/secrets.yml")).to match /redis_url: <%= ENV\["REDIS_URL"\] %>/
    end
  end

  context "Background Jobs" do
    it "installs the Sidekiq gem" do
      expect(file("Gemfile")).to match /gem 'sidekiq'/
    end

    it "adds a worker entry to the Procfile" do
      expect(file("Procfile")).to match /worker/
    end

    it "sets the max threads for Sidekiq concurrency and ActiveRecord connection pool size" do
      expect(file("Procfile")).to match /worker.*RAILS_MAX_THREADS=\d/
    end

    it "creates a worker process with 3 priority levels" do
      expect(file("Procfile")).to match /worker.*high.*default.*low/
    end

    it "creates a 2nd worker process to prevent job starvation" do
      expect(file("Procfile")).to match /worker.*low.*default.*high/
    end

    it "sets Sidekiq worker process timeout to 25 seconds for Heroku" do
      expect(file("config/sidekiq.yml")).to match /:timeout: 25/
    end
  end

  it "creates a custom Gemfile" do
    expect(file("Gemfile")).to match /# added by Vorsprung/
  end

  private

  def file(path)
    IO.read("#{app_path}/#{path}")
  end

  def temp_dir
    "tmp"
  end

  def app_name
    "myapp"
  end

  def app_path
    "#{temp_dir}/#{app_name}"
  end

  def setup
    FileUtils.mkdir_p(temp_dir)
    Dir.chdir(temp_dir) do
      Bundler.clean_system("bundle exec vorsprung new #{app_name}")
    end
  end

  def teardown
    FileUtils.rm_rf(temp_dir)
  end
end
