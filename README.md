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

Get the login information via the Rails console.

```bash
echo 'p=Person.first; p.update(password: "password"); "You can now login as #{p.email} with the password \"password\""' | \
     docker-compose run --rm -T app rails c
```

Now you should be able to log-in with the email address in the output and the password _password_.

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
docker-compose run --rm test
```

### Test of a specific Wagon

To test a specific wagon, you need to cd to the directory.
But because the `entrypoint` script automatically does a `bundle exec` for you (which is fine most of the time), you need to overwrite the entrypoint to be plain `bash`.

```bash
$ docker-compose run --rm --entrypoint bash test
Starting hitobito_db-test_1 ... done
root@a42b42c42d42:/app/hitobito# rake db:migrate wagon:migrate # if you changed the db schema
root@a42b42c42d42:/app/hitobito# cd ../hitobito_WAGON/
root@a42b42c42d42:/app/hitobito_WAGON# rspec
```

## Full-text search

Hitobito relies on Sphinx Search for indexing Persons, Events and Groups.

At first, you need to create the initial index:

```bash
docker-compose run --rm indexer
```

Then you can start the Sphinx server:

```bash
docker-compose up sphinx
```

The server does not automatically re-index.
In order to re-index, run the indexer again.
