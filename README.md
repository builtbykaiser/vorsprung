# Vorsprung
[![Build Status](https://travis-ci.org/builtbykaiser/vorsprung.svg?branch=master)](https://travis-ci.org/builtbykaiser/vorsprung) [![Coverage Status](https://coveralls.io/repos/github/builtbykaiser/vorsprung/badge.svg?branch=master)](https://coveralls.io/github/builtbykaiser/vorsprung?branch=master)

Give your Rails app a running start! Vorsprung generates the base Rails applications for [Built By Kaiser](http://www.builtbykaiser.com) and stays up-to-date with best practices.

## Installation

Run this in your terminal:

```shell
$ gem install vorsprung
```

Then, to create a new Rails app, run:

```shell
$ vorsprung new myapp
```

And you'll be off to a running start!

## Postgres & Mac OS X

If it's your first time installing the `pg` gem on Mac OS X, you may have to use one of the methods below:

Homebrew: `gem install pg -- --with-pg-config=/usr/local/bin/pg_config`

MacPorts: `gem install pg -- --with-pg-config=/opt/local/lib/postgresql84/bin/pg_config`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/builtbykaiser/vorsprung).

## License

Vorsprung is Copyright 2017 Built By Kaiser, LLC. It is free software and may be redistributed under the terms specified in the [LICENSE] file.

[LICENSE]: LICENSE
