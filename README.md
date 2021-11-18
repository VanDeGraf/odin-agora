# Agora

This project is part
of [The Odin Project Curriculum](https://www.theodinproject.com/paths/full-stack-ruby-on-rails/courses/ruby-on-rails/lessons/rails-final-project)  
You can try it on [live version](https://odin-agora.herokuapp.com)

## Description

#### _Project: Building Facebook_

"_You’ll be building Facebook. As usual, any additional styling will be up to you but the really important stuff is to
get the data and back end working properly. You’ll put together some of the core features of the platform – users,
profiles, “friending”, posts, news feed, and “liking”. You’ll also implement sign-in with the real Facebook by using
OmniAuth and Devise._"

"_Some features of Facebook we haven’t yet been exposed to – for instance chat, realtime updates of the newsfeed, and
realtime notifications. You won’t be responsible for creating those unless you’d like to jump ahead and give it a
shot._"

#### Not implemented features yet

* Omniauth Facebook provider
* Polymorphic Post model (with text or picture)
* ActiveStorage requests optimize

## Requirements

* ruby >= '2.7.2'
* rails >= '6'
* gems:
    * figaro >= '1.2'
    * pg
    * devise >= '4'
    * simple_form
    * faker
    * cloudinary
    * omniauth-yandex = '0.0.2'
    * rubocop
    * guard
    * letter_opener
    * factory_bot
* npm:
    * bootstrap >= '5'

## Configuration

Mail provider config in `config/environments/production.rb` > `config.action_mailer.smtp_settings`

Devise OmniAuth providers config in `config/initializers/devise.rb` >
`config.omniauth :provider_name, 'APP_ID', 'APP_SECRET'`

ActiveStorage providers config in default `config/storage.yml`

All secure configs in created by figaro `config/application.yml`:

* `production:`
    * `host` - production host
    * `email` - sender email
    * `yandex_mail_login`/`yandex_mail_password` - Yandex mail provider application credentials
    * `yandex_omniauth_id`/`yandex_omniauth_password` - Yandex OAuth provider application credentials
    * `CLOUDINARY_URL` - Cloudinary storage provider credentials

## Install and Run

* Clone the repo locally
* `cd` into it
* Run `bundle install`
* `npm install`
* `rails db:migrate`
* `rails db:seed`, if you need it
* `rails s`, if you want to run the installed project locally

## Deployment

* upload production env files
* set environment variables
* run `rails db:migrate`, and `rails db:seed` if need
* `rails s`

### Heroku

* `heroku create host_name` - create and connect, if you don't do this yet, host_name must be same as in configuration
* `git push -u heroku main:main` - upload production files and build
* `figaro heroku:set -e production`- set environment variables
* `heroku run rails db:migrate` - create database with heroku addons and migrate
* `heroku run rails db:seed` - create example dataset, if need

## Tests

Run test suites with `rails test`

Implemented:

* Model tests

Not implemented:

* Integration tests(View, Mailer)
* Controller tests

## Services

### Omniauth

You can add\change omniauth provider with add\change `config.omniauth :provider_name, 'APP_ID', 'APP_SECRET'` param in
devise initialization (`config/initializers/devise.rb`)
and add\change callback method in `app/controllers/users/omniauth_callbacks_controller.rb`

Current providers:

* Yandex

Future providers can be attached:

* Facebook
* GitHub
* Discord
* VK

### ActiveStorage

ActiveStorage don't use any provider dependent methods.

ActiveStorage upload images on:

* User change avatar (include sign_up with omniauth)
* User create Post with picture

ActiveStorage destroy images on attachable object destroy

### Mail

You can change mail provider with change `config.action_mailer.smtp_settings` param in production
environment (`config/environments/production.rb`)