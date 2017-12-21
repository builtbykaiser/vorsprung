module Vorsprung
  class CLI < Thor
    include Thor::Actions

    desc "new APP_NAME", "create a new Rails app called APP_NAME"
    def new(app_name)
      puts "Vorsprinkling you a new Rails app..."
      run "rails new #{app_name}", capture: true
    end
  end
end
