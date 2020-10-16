# Bones
##### Dammit Jim, I'm a developer, not a magician.

A [Fossil](https://fossil-scm.org/) repository managment site in the lines of
[Flint, backing Chisel](https://chiselapp.com/user/rkeene/repository/flint).

---

Provides a bare-bones interface for managing multiple Fossil repositories on a
per user basis.

# Deploy

# Development

As this project only provides the management of Fossil repository files, you'll
still need to have Fossil serving the individual repositories. You could look
into something like running `fossil server ` but the recommended fashion is by
using [lighttpd](http://www.lighttpd.net/) and using Fossil as [a cgi
script](https://fossil-scm.org/home/doc/trunk/www/server/any/cgi.md). An
example lighttpd config is provided as well as a functional docker-compose
setup.

## Setup

Ensure you have Fossil installed, as well as Sqlite, then:

```shell
asdf local 2.7.0
./bin/setup
```

Finally use the user tool to make youself a new user:

```shell
./bin/user create --help
```

## Tools

An IRB shell is available with the environment loaded up via:

```shell
./bin/console
```

Debuggers, via the `break` gem, can be dropped in with:

```ruby
binding.irb
```

Additionally the project is configured with
[Zeitwerk](https://github.com/fxn/zeitwerk) for auto-loading and reloading of
code in development, the only time you should have to manually restart the
server is when changing `env.rb` or `config.ru`.

## Release Prep

Rubocop:

```shell
bundle exec rubocop -A
```

Tests:

```shell
bundle exec rake
```
