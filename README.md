# Overview
The Nomo FOMO platform is a way to socially connect users and their friends to share experiences, trips and day to day travels. The platform connects users with people they know to allow them to see where they are, what trips they have coming up and who will be in the next city they plan to visit.

## Experience the Platform

The latest version of this project is running [here](http://www.nomo-fomo.com/)

---

# NEW UNSTABLE WAY

# Developing with Docker

## Dependencies
- Docker Sync: `gem install docker-sync`

## Environment Variables
- Copy this into your `config/application.yml` https://nomo-fomo.slack.com/archives/C6NFVA7HT/p1515767438000704

## Standing up
- `docker-sync start`
- `docker-compose build`
- `docker-compose up`
- `docker-compose run --rm web rake db:create db:migrate db:seed`
- `docker-compose run --rm web rake db:create db:migrate db:seed RAILS_ENV=development` (optional)
- View app at http://localhost:3000
- Run tests `docker-compose run --rm web rake nomofomo:all`

---

# OLD WAY

## Requirements
- ruby-2.3.3
- rails 4.2.5.1
- postgresql 9.6

## Dependencies
- OpenSSL
- Chromedriver

### Install OpenSSL
- Mac OS X = `$ brew install ruby`
- Linux - `$ sudo apt-get install openssl`
- Windows - [Installer](https://www.openssl.org/source/)

### Install Chromedriver
- Max OS X - `$ brew install chromedriver`

### Install Ruby
- Mac OS X - `$ brew install ruby`
- Linux - `$ sudo apt-get install ruby-full`
- Windows - [Installer](https://rubyinstaller.org/downloads/)

### Install Rails
- Mac OS X and Linux - `$ gem install rails -v 4.2.5.1`
- Windows - [Installer](https://s3.amazonaws.com/railsinstaller/Windows/railsinstaller-3.3.0.exe)

### Install Postgres
- Linux - `$ apt-get install postgresql-9.4`
- Mac - `brew install postgresql@9.4`
  - By default the postgresql user is your current OS X username with no password.
- Windows - [Installer](https://www.postgresql.org/download/)
  - Note you will need to change add a your user account name to the postgres userrole. (for example, mine is 'graham plata' with a role of postgres user)
  
### Install Xcode
- Run `xcode-select install` to install dev tools OR
- Manually download and install XCode
  - Open XCode
  - Go to Preferences
  - Select XCode from the dropdown for **Command Line Tools**
- Restart terminal

## Installation
- Clone the repository with: `git clone git@github.com:Nomo-FOMO/nomofomo.git`
- You May be propted for your username and password. This can be avoided by adding an ssh key. [Guide](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account)
- With the repo cloned and Ruby installed you may now `cd nomofomo` and run `bundle install`
  - Note if you have to install bundler and receive the following error: `Unable to require openssl, install OpenSSL and rebuild ruby (preferred) or use non-HTTPS sources` it can be resolved by re-installing Ruby by running the command `` rvm reinstall 2.3.3 --with-openssl-dir=`brew --prefix openssl` ``
- After all dependencies are installed run
  - `rake db:create` to create a database
  - `rake db:migrate` to apply the schemas
  - `rake db:seed` to seed the database with dummy data

## Running the Application
- With Postgres running start the application with `rails s` in your terminal
- You can now visit http://localhost:3000

### Seed Data
- Sign in locally or to the [test app](https://nomofomo-test.herokuapp.com/)
  - Emails:
    - user_one@email.com
    - user_two@email.com
    - user_three@email.com
  - Passwords:
    - Check the `ENV['SEED_PASSWORD']` variable in your `application.yml` file

## Add Facebook Authentication
- Login to Facebook
- Navigate to user settings tab ~ [portal](https://www.facebook.com/settings?tab=applications)
- Find the Nomo FOMO application - Click edit
- Under the "Get Help From App Developers" there should be an id `'##################'`
- open config/application.yml
- Add app id `'##################'` with the others on line 1

## Development
- Before EVERY commit run and solve any issues that come up from `rake nomofomo:all`
- To see code coverage through simplecov, open `coverage/index.html` in a browser and keep refreshing after every test run.
- Use `rake test` to run the tests
- Use `rake teaspoon` to run the javaScript tests or visit http://localhost:3000/teaspoon to run the tests in your browser

## Enviromental Variables
- To setup your environment variables create a `config/application.yml` and receive information from Slack channel #engineering

# Deployment
- Deployments are done automatically through CircleCI. Once you click on the merge button on pull requests in GitHub, the merge happens and then CI runs all the tests and checks. Once those have passed, CI will deploy to the proper environment.
- To manually deploy to QA: `git push heroku-qa develop:master`
- To manually deploy to Production: `git push heroku-production master:master`

# To install QT on CircleCI again
```
dependencies:
  pre:
    - sudo apt-get install apt -y
    - sudo add-apt-repository ppa:beineri/opt-qt542-trusty -y
    - sudo apt-get update -y; true
    - sudo apt-get install -y qt54webkit libwebkit-dev libgstreamer0.10-dev
    - echo "/opt/qt54/bin/qt54-env.sh" >> ~/.circlerc
```

# 3rd party libraries
Gemfile should only be used for Ruby dependencies, not for JavaScript or CSS dependencies. Using JavaScript or CSS dependencies has more disadvantages than advantages, because in many situations those libraries aren't the official ones, and are poorly supported. To use JavaScript dependencies you should add those dependencies to the HTML using a CDN, or using the vendor folder in Rails. There are some dependencies in the Gemfile that are not following this rule due to legacy reasons, and we're trying to remove those dependencies.

If you are going to use a Ruby dependency, ask yourself a question: Does this library can be implemented by hand using a few hours? If so, don't use the library and start developing that functionality from scratch. This is because we're having many security problems due to poorly supported libraries that don't provide a real benefit.

# Moving from CoffeeScript to Javascript
We're trying to get rid of CoffeeScript and start using JavaScript for the entire system, because there's no benefit in using CoffeeScript after the ECMAScript standarization. It was useful before, but that's no longer the case.
In order to do that, we're using a library called Decaffeinate to convert CoffeeScript to JavaScript, but be careful because this library generates ECMAScript 5, and Sprockets doesn't currently have support for that. It is your own responsibility to convert that ECMAScript 5 to plain JavaScript. There are still some parts of the code using CoffeeScript due to legacy reasons, so if your ticket touches one of those parts, you should decaffeinate those CoffeeScript files and start doing the corresponding testing.
