# Bones
##### Dammit Jim, I'm a developer, not a magician.

Bones is a [Fossil](https://fossil-scm.org/) repository managment site in the
lines of [Flint, backing
Chisel](https://chiselapp.com/user/rkeene/repository/flint).

---

**Note**: Bones hosts it's own [Fossil](https://bones.isin.space/user/JoshAshby/repository/Bones/) repository which is mirrored on [Github](https://github.com/JoshAshby/bones).  

The canonical Fossil source: [Fossil Bones](https://bones.isin.space/user/JoshAshby/repository/Bones/)  
My hosted version of Bones: [Bones.isin.space](https://bones.isin.space)  

---

Provides a bare-bones interface for managing multiple Fossil repositories on a
per user basis.

Bones is still being polished for depolys with the following tasks still
needing to be completed before the first version goes live:

#### Todos

- [ ] Sandbox Fossil
- [ ] Ensure all text input is escaped in the templates
- [ ] Flesh out tests and documentation for Bones & Fossil modules
- [x] Ensure usernames are validated like repository names
- [x] Setup Mail gem to be configurable per env - https://github.com/mikel/mail#sending-an-email
- [x] Non-page based log out. Button on sidebar should just do it
- [x] Feature flag for public sign-up
- [x] Build out lighttpd setup and test it out
- [x] Dockerfile for the ruby component
- [-] Mobile/responsive design
  - This is somewhat done, in that the site is mostly usable on mobile, but
    doesn't have a good mobile friendly design

Bones is missing these features but I *might* add them in the future:  

- [ ] Periodic task to pull/sync cloned repos
- [ ] Periodic task to mirror a repo to git automatically
- [ ] Public/Private setting repositories (all repositories as "private" at the
  moment)
- [ ] Possible webhook setup for pushes using the 2.12.1 hooks feature
- [ ] Email relay to allow repos to send emails from Bones
- [ ] Custom domain handling

# Development

As this project only provides the management of Fossil repository files, you'll
still need to have Fossil serving the individual repositories. You could look
into something like running `fossil server ` but the recommended fashion is by
using [lighttpd](http://www.lighttpd.net/) and using Fossil as [a cgi
script](https://fossil-scm.org/home/doc/trunk/www/server/any/cgi.md). In fact
it's so recommended that Bones auto generates a CGI script for each users
repositories.

An example lighttpd config is provided, along with a functional docker-compose
setup in `docker/`; A simple `cd docker/; docker-compose up` should do the
trick.

## Setup

Ensure you have Fossil in your path, as well as Sqlite, then:

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

### Frontend

Bones is moving towards a utility css backed, componentized view setup with
Trailblazer cells; Frontend magic is done with the help of some splashes of
AlpineJS. I'll fill this section out more in the future when the migration is
finished or at least solidified in practices.

While there is a `app/styles.css` and some small amount of rscss that'll
probably remain in place, for the most part everything is done with Tailwind
and the css gets stripped with purgecss. See [Tailwind CSS v2](https://tailwindcss.com/)
for more help with the available classes.

If you do need to rebuild the `public/styles.css` file after changing something
in `app/css/`, just run the `css` npm script: `npm run css`

## Release Prep

At the least these two commands should be ran and pass:

Rubocop:

```shell
bundle exec rubocop -A
```

Tests, with coverage:

```shell
bundle exec rake
```

Optionally, but good to test if changing something in `lib/` that should be
documented:
```shell
bundle exec rake rdoc
```
