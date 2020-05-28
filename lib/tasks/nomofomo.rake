namespace :nomofomo do
  task all: ["code_quality", "tests"]

  desc "Runs rubocop"
  task :code_quality do
    puts "#=====================#"
    puts "|       Rubocop       |"
    puts "#=====================#"
    sh "bundle exec rubocop"

    puts "#=====================#"
    puts "|      SCSS Lint      |"
    puts "#=====================#"
    sh "bundle exec scss-lint"
  end

  desc "Runs minitests, and jasmine"
  task :tests do
    puts "#=====================#"
    puts "|        RSpec        |"
    puts "#=====================#"
    sh "bundle exec rspec"

    puts "#=====================#"
    puts "|       Jasmine       |"
    puts "#=====================#"
    sh "bundle exec rake teaspoon"
  end
end
