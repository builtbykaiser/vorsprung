module Vorsprung
  class CLI < Thor
    desc "new APP_NAME", "create a new Rails app called APP_NAME"
    def new(app_name)
      puts "Vorsprinkling you a new Rails app..."
      Bundler.clean_system("rails new #{app_name}")
    end
  end
end
