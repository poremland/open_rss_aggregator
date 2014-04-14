# Open Rss Aggregator

> Open Rss Aggregator is a Ruby on Rails application created to provide rss aggregation services. The Open Rss Aggregator was built to be simple and to integrate within an existing domain. Practically what this means is that there are no users to manage. Instead Open Rss Aggregator ties into your existing domain infrastructure and validates users using SMTP authentication. This allows anyone on your domain to have access to their own set of aggregated RSS feeds without putting the burden of user management on the domain administrator.

> Open Rss Aggregator provides a simple RESTFul API for use with automation and 3rd party application integration.

> I built this several years ago as a means to learn Ruby. While I've maintained it over the years, the code could use a little refactoring love. Because I built it with a RESTFul API it's actually been extemely useful in learning new langauges and platforms as it gives me something *to program against* which is fun and useful.  I've built native webOS and Android clients for it.

## Contributing

> See the [TODO.md](TODO.md) for how you can help contribute to this project.

## Setup

### OS X Specific
> Install [Homebrew](https://github.com/mxcl/homebrew/wiki/installation)
> Install [mysql](http://dev.mysql.com/doc/refman/5.5/en/) using homebrew. 5.5 works

### *nix
> Install [mysql](http://dev.mysql.com/doc/refman/5.5/en/)

### Everyone
> Install [RVM](https://rvm.io/) if you don't have it already.

> Install [httpd](http://httpd.apache.org)

> Install [Phusion Passenger](http://www.modrails.com/documentation/Users%20guide%20Apache.html) for Apache.

> Checkout the code

	$ cd /path/to/httpd/htdocs

	$ git clone git@github.com:poremland/open_rss_aggregator.git

	$ cd open_rss_aggregator

	$ gem install bundle

	$ bundle install

### Authentication
Copy the `config/config.yml.example`  to `config/config.yml` and enter credentials for your domains SMTP server.

### Database
Copy the `config/database.yml.example`  to `config/database.yml` and enter credentials for your local database.

> Setup the database

	$ rake db:create db:migrate db:seed

## Development

### After changing assets

	$ RAILS_ENV=development bundle exec rake clean assets:clean assets:precompile

## Running

> I'm a fan of running my rails apps on [Apache](http://www.apache.org) through [Phusion Passenger](http://www.modrails.com/documentation/Users%20guide%20Apache.html) but there's no reason this shouldn't work with another HTTP server. To setup on Apache with Phusion Passenger you need to edit your httpd.conf file and set your passenger specific variables.  For example:

	PassengerRoot /usr/local/rvm/gems/ruby-1.9.2-p320/gems/passenger-3.0.17

	PassengerRuby /usr/local/rvm/wrappers/ruby-1.9.2-p320/ruby

	PassengerMaxPoolSize 15

	PassengerPoolIdleTime 900

	PassengerHighPerformance on

	PassengerSpawnMethod smart

	PassengerMaxInstancesPerApp 3


> Then set the Rack Base URI to the name of the directory under apache's htdocs folder where you checked out the source

	RackbaseURI /open_rss_aggregator

> You should now be able to visit [http://localhost/open_rss_aggregator](http://localhost/open_rss_aggregator) to see your login screen.

## Scheduled Tasks
> There is a bash script, `lib/scripts/open.rss.aggregator.worker.sh`, which has been created that can be run as a cron job to allow syncing and purging of feeds for all users. You'll need to update the script and replace `/YOUR/PATH/TO/open-rss-aggregator` with the actual full path.

### Sync'ing feeds
> Add the following to your crontab

	*/30 * * * * /YOUR/PATH/TO/open-rss-aggregator/lib/scripts/open.rss.aggregator.worker.sh "sync"

### Purging Old Feeds
> Add the following to your crontab

	13 11 * * * /YOUR/PATH/TO/ruby/open-rss-aggregator/lib/scripts/open.rss.aggregator.worker.sh "purge"

