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

The final structure should look something like this:

```bash
$ ls -l
total 16K
-rw-r--r--  1 user 1.3K Jul 15 10:57 Dockerfile
-rw-r--r--  1 user 1.4K Jul 15 17:43 README.md
-rw-r--r--  1 user  625 Jul 15 17:41 docker-compose.yml
drwxr-xr-x 36 user 1.2K Jul 15 13:56 hitobito
-rw-r--r--  1 user  153 Jul 15 10:35 hitobito.code-workspace
drwxr-xr-x 27 user  864 Jun 11 09:30 hitobito_generic
drwxr-xr-x 29 user  928 Jul 15 09:43 hitobito_insieme
```

## Docker Runtime

The simplest way to work on hitobito is to use Docker:

```bash
# First time
docker-compose run --rm app rake db:seed wagon:seed

# Every other time
docker-compose up app

# Open the app:
echo "http://$(docker-compose port app 3000)"

# In order to "receive" emails, open mailcatcher:
echo "http://$(docker-compose port mail 1080)"
```

## First Login

Use the password reset flow and use the e-mail address of the root account.
You find it as `root_email` in the `settings.yml` file of the wagon.

Then open the mailcatcher and copy the path.
**Don't forget to adjust the host & port in that url!**

Now you should be able to log-in.

## Debug

The Rails console is your friend.
Run the following command, to open it.

```bash
docker-compose exec app rails c
```

## Test

The hitobito application has a lot of rspec tests.
To run them all, use the following command:

```bash
docker-compose run --rm app rspec
```
