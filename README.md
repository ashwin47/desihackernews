### DesiHackerNews

DesiHackerNews(DHN) is an attempt to cultivate an India-centric technology/startup community around link aggregation and discussion.

This is a fork of [Lobster](https://github.com/lobsters/lobsters)


#### Contributing bugfixes and new features

We'd love to have your help.
Please see the [CONTRIBUTING](https://github.com/ashwin47/desihackernews/blob/master/CONTRIBUTING.md) file for details.

#### Initial setup

Use the steps below for a local install

* Install the Ruby version specified in [.ruby-version](https://github.com/ashwin47/desihackernews/blob/master/.ruby-version)

* Checkout the lobsters git tree from Github
    ```sh
    $ git clone https://github.com/ashwin47/desihackernews.git
    $ cd desihackernews
    desihackernews$
    ```

* Install Nodejs, needed (or other execjs) for uglifier
    ```sh
    Fedora: sudo yum install nodejs
    Ubuntu: sudo apt-get install nodejs
    OSX: brew install nodejs
    ```

* Run Bundler to install/bundle gems needed by the project:

    ```sh
    desihackernews$ bundle
    ```
    
    * If when installing the `mysql2` gem on macOS, you see 
      `ld: library not found for -l-lpthread` in the output, see 
      [this solution](https://stackoverflow.com/a/44790834/204052) for a fix.
      You might also see `ld: library not found for -lssl` if you're using
      macOS 10.4+ and Homebrew `openssl`, in which case see
      [this solution](https://stackoverflow.com/a/39628463/1042144).

* Generate rails credetials file and add following.
    ```sh
    rails credentials:edit --environment development
    ```
      ```yaml
      secret_key_base:

      DOMAIN: 
      DB_USER:
      DB_PASSWORD:       
      ```

* Create a MySQL (other DBs supported by ActiveRecord may work, only MySQL and
MariaDB have been tested) database, username, and password and put them in a
`config/database.yml` file.  You will also want a separate database for
running tests:

    ```yaml
    development:
      adapter: mysql2
      encoding: utf8mb4
      reconnect: false
      database: lobsters_dev
      socket: /tmp/mysql.sock
      username: <%= Rails.application.credentials.config[:DB_USER] %>
      password: <%= Rails.application.credentials.config[:DB_PASSWORD] %>
      
    test:
      adapter: mysql2
      encoding: utf8mb4
      reconnect: false
      database: lobsters_test
      socket: /tmp/mysql.sock
      username: <%= Rails.application.credentials.config[:DB_USER] %>
      password: <%= Rails.application.credentials.config[:DB_PASSWORD] %>
    ```

* Load the schema into the new database:

    ```sh
    desihackernews$ rails db:schema:load
    ```

* On your production server, copy `config/initializers/production.rb.sample`
  to `config/initalizers/production.rb` and customize it with your site's
  `domain` and `name`. (You don't need this on your dev machine).

* Put your site's custom CSS in `app/assets/stylesheets/local`.

* Seed the database to create an initial administrator user, the `inactive-user`, and at least one tag:

    ```sh
    desihackernews$ rails db:seed
    ```

* On your personal computer, you can add some sample data and run the Rails server in development mode.
  You should be able to login to `http://localhost:3000` with your new `test` user:

    ```sh
    desihackernews$ rails fake_data
    desihackernews$ rails server
    ```

* Deploying the site in production requires setting up a web server and running the app in production mode.

* Set up crontab or another scheduler to run regular jobs:

    ```
    */5 * * * *  cd /path/to/lobsters && env RAILS_ENV=production sh -c 'bundle exec ruby script/mail_new_activity; bundle exec ruby script/post_to_twitter; bundle exec ruby script/traffic_range'
    ```

* See `config/initializers/production.rb.sample` for GitHub/Twitter integration help.

#### Administration

Basic moderation happens on-site, but most other administrative tasks require use of the rails console in production.
Administrators can create and edit tags at `/tags`.
