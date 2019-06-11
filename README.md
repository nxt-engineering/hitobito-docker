# Hitobito

_hitobito_ is an open source web application to manage complex group hierarchies with members, events and a lot more.

## Preparation

Check out the hitobito projects you'd like to build:

```bash
# core project
git clone https://github.com/hitobito/hitobito.git

# wagon projects
git clone https://github.com/hitobito/hitobito_generic.git
```

You need to set up at least one wagon project.

## Docker Runtime

The simplest way to work on hitobito is to use Docker:

```bash
# First time
docker-compose run --rm app rake db:seed

# Every other time
docker-compose up app

# Open the app:
echo "http://$(docker-compose port app 3000)"

# In order to "receive" emails, open mailcatcher:
echo "http://$(docker-compose port mail 1080)"
```

## First Login

Use the password reset flow and use the e-mail address `hitobito@puzzle.ch`.

Then open the mailcatcher and copy the path.
**Don't forget to adjust the host & port in that url!**

Now you should be able to log-in.
