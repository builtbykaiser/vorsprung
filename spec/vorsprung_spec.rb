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
    expect(IO.read("#{app_path}/Procfile")).to match /web:/
    expect(IO.read("#{app_path}/Procfile")).to match /worker:/
  end

  private

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
      Bundler.clean_system("vorsprung new #{app_name}")
    end
  end

  def teardown
    FileUtils.rm_rf(temp_dir)
  end
end
