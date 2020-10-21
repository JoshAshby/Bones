# Bones
##### Dammit Jim, I'm a developer, not a magician.

A [Fossil](https://fossil-scm.org/) repository managment site in the lines of
[Flint, backing Chisel](https://chiselapp.com/user/rkeene/repository/flint).

---

Provides a bare-bones interface for managing multiple Fossil repositories on a
per user basis.

Bones is still being polished for depolys with the following tasks still
needing to be completed before the first version goes live:

- [x] Setup Mail gem to be configurable per env - https://github.com/mikel/mail#sending-an-email
- [ ] Ensure all text input is escaped in the templates
- [ ] Ensure usernames are validated like repository names
- [ ] Flesh out tests and documentation for Bones & Fossil modules
- [x] Non-page based log out. Button on sidebar should just do it
- [x] Feature flag for public sign-up
- [ ] Build out lighttpd setup and test it out
- [ ] Dockerfile for the ruby component

Bones is missing these features but I *might* add them in the future:
- [ ] Mobile/responsive design
- [ ] Periodic task to pull/sync cloned repos
- [ ] Public/Private setting repositories (all repositories as "private" at the
  moment)
- [ ] Possible CI api hooks? Maybe a webhook setup for pushes?

# Deploy

TODO

# Development

As this project only provides the management of Fossil repository files, you'll
still need to have Fossil serving the individual repositories. You could look
into something like running `fossil server ` but the recommended fashion is by
using [lighttpd](http://www.lighttpd.net/) and using Fossil as [a cgi
script](https://fossil-scm.org/home/doc/trunk/www/server/any/cgi.md). An
example lighttpd config is provided as well as a functional docker-compose
setup (coming soon).

## Setup

Ensure you have Fossil installed, as well as Sqlite, then:

```shell
asdf local 2.7.0
./bin/setup
```

You'll also want to ensure that the settings in `config/` are to your liking.

Finally use the user tool to make youself a new user:

```shell
./bin/bones user create --help
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
server is when changing `env.rb`, `config.ru` or `config/<environment>.yml`.

### Frontend Styles

There is a [Tailwind CSS](https://tailwindcss.com/) setup for styling. Make style changes to
`app/styles.pcss` and then run tailwind to regnerate the styles file.

```shell
npx tailwindcss build app/css/styles.pcss -o public/styles.css
```

If you have [`entr`](http://eradman.com/entrproject/) installed you could run:

```shell
echo app/css/styles.pcss | entr -c npx tailwindcss build /_ -o public/styles.css
```

to continueously rebuild the styles when working on them.

## Release Prep

At the least these two commands should be ran and pass:

Rubocop:

```shell
bundle exec rubocop -A
```

Tests, with coverage:

```shell
env COVERAGE=true bundle exec rake
```

Optionally, but good to test if changing something in `lib/` that should be
documented:
```shell
bundle exec rake rdoc
```
