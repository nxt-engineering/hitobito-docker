# Hitobito

_Hitobito_ is an open source web application to manage complex group hierarchies with members, events and a lot more.
A quick way to begin working on Hitobito and it's wagons is using _Docker_ and _docker-compose_.

## System Requirements

In order to use this method, you need to have [Docker][docker] and _[docker-compose][doco]_ installed on your computer.
The free _Docker Community Edition (CE)_ works perfectly fine.

[docker]: https://docs.docker.com/install/
[doco]: https://docs.docker.com/compose/install/

## Preparation

First, you need to clone this repository:

```bash
git clone https://github.com/nxt-engineering/hitobito-docker.git hitobito \
  && cd hitobito
```

This contains only the Docker instructions.
But you will also need the Hitobito source code.
That's why you need to clone the Hitobito core project and the specific Hitobito wagon you'd like to work on:

```bash
# core project
git clone https://github.com/hitobito/hitobito.git

# wagon project(s)
git clone https://github.com/hitobito/hitobito_generic.git
```

You need to set up at least one wagon project. Don't forget to [copy the Wagonfile](https://github.com/hitobito/hitobito/blob/master/doc/development/04_wagons.md#grundlegendes) in the core project!
The final structure should look something like this:

```bash
$ ls -lh
total 16K
-rw-r--r--  1 user 1.3K Jul 15 10:57 Dockerfile
-rw-r--r--  1 user 1.4K Jul 15 17:43 README.md
-rw-r--r--  1 user  625 Jul 15 17:41 docker-compose.yml
drwxr-xr-x 36 user 1.2K Jul 15 13:56 hitobito
drwxr-xr-x 27 user  864 Jun 11 09:30 hitobito_generic
```

## Docker Runtime

To start the Hitobito application, run the following commands in your shell:

```bash
# Start the application
docker-compose up app

# Open the app:
echo "http://$(docker-compose port app 3000)"

# In order to "receive" emails, open mailcatcher:
echo "http://$(docker-compose port mail 1080)"
```

It will initially take a while to prepare the initial Docker images, to prepare the database and to start the application.
The process will be shorter on subsequent starts.

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

## Seed

If you need to re-seed your db, use the following command:

```
docker-compose run --rm app rake db:seed wagon:seed
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

## Clean up / Reset

Once you've made your changes and decide to stop working on the project, you should clean up. The following command will remove all data that was created by Docker and _docker-compose_.

```bash
docker-compose down --volumes --remove-orphans --rmi local
```

This method is also not too bad if your working environment got screwed up somehow and you'd like to try a fresh start.

## Internals

Here follows a dicussion about why certain things were done a certain way in this repository.

### Exposed Ports

The `docker-compose.yml` file does expose all relevant ports.
But it does not assign them a well-known port.
This means, that it is _intentionally_ not possible to access the main application using `http://localhost:3000`!
Either you use `docker-compose ps` (or the `docker-compose port SERVICE PORTNUMBER` command) to get the actual port Docker assigned – or you use something like [Reception](https://github.com/nxt-engineering/reception).

Why would you need this _Reception_ thingy? Because it makes all the services accessible through a reverse proxy that is accessible using `http://SERVICENAME.PROJECTNAME.docker` (or `http://SERVICENAME.PROJECTNAME.local` on Linux).
This makes work more convenient and allows to have multiple projects, that all bind to the same port (e.g. `3000`), running at the same time.
(Because Docker will handle the port conflict for us.)
As an extra you get an overview over all running services and their exposed ports for free at `http://reception.docker` (or `http://reception.local` on linux).

### Mounts

The current directy is mounted by _docker-compose_ into the running containers.
The main advantage is a much simpler workflow, because it allows you to change your 'local' files and they are immediately picked up by the commands in the server.
I.e. you don't have to re-build the Docker images after every time.
