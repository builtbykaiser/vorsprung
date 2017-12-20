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
