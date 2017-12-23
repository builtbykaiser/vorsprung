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
    expect(file("Procfile")).to match /worker:/
  end

  it "creates an .env file with SECRET_KEY_BASE" do
    expect(file(".env")).to match /SECRET_KEY_BASE='\h+'/
  end

  it "creates a secrets.yml file with SECRET_KEY_BASE" do
    # include a bit of ERB so we confirm it's being escaped properly
    expect(file("config/secrets.yml")).to match /shared:\n  secret_key_base: <%= ENV/
  end

  it "uses PostgreSQL as the database" do
    expect(file("config/database.yml")).to match /adapter: postgresql/
    expect(file("Gemfile")).to match /gem (?<quote>['"])pg\k<quote>/
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
