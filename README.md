# Restaurants Workspace

## System setup with Docker (recommended)

#### 1. Install Docker Desktop on your system

(If it is already installed, skip this step).

* This can be done following the documentation in this link: [`https://docs.docker.com/engine/install/`](https://docs.docker.com/engine/install/). If you install *Docker* on an Unix like system, you must also install *Docker Compose*.

## Start development server

For full console output, navigate to the Restaurants project directory and run:

    docker-compose up --build

To stop it, simply press `Ctrl+C`.

* #### Elixir's Interactive Shell

    Alternatively if an *Interactive Elixir Shell* is needed when starting the server, navigate to the project directory and run:

        
        docker-compose build && docker-compose run --rm -p 4000:4000 app ./run.sh iex


    
    To stop it, simply press `Ctrl+C`, `a` then `Enter`.

* #### Test coverage report

    In order to visualize the test coverage report is required to generate it before the server starts, and then start the server. To do that navigate to the Restaurants project directory and run:

        docker-compose build && docker-compose run --rm -p 4000:4000 app ./run.sh cover


    To stop it, simply press `Ctrl+C`, `a` then `Enter`.

## Run automated tests

In order to run the automated tests, navigate to the Restaurants project directory and run:

    docker-compose build && docker-compose run --rm app mix test

It's possible to use all the `mix test` and `mix coveralls` command options, like but not limited to `--trace`, `--failed`, `--max_failures`, `--seed` or `--only`.

## Reset the database

If is needed to reset the database (drop, create and run migrations & seeds), navigate to the Restaurants project directory and run:

    docker-compose build && docker-compose run --rm app mix ecto.reset

## Server usage

|Server URL|[`http://localhost:4000/`](http://localhost:4000/)|
|--:|:--|
|Phoenix LiveDashboard|[`http://localhost:4000/dashboard`](http://localhost:4000/dashboard)|
|API-REST documentation|[`http://localhost:4000/doc/api`](http://localhost:4000/doc/api)|
|Code documentation|[`http://localhost:4000/doc/code`](http://localhost:4000/doc/code)|
|Code documentation ePub file|[`http://localhost:4000/doc/code/Restaurants.epub`](http://localhost:4000/doc/code/Restaurants.epub)|
|Test coverage report|[`http://localhost:4000/doc/coverage`](http://localhost:4000/doc/coverage)|

### Useful Docker commands

|Definition|Command|
|:--|:--|
|Stop all containers|`docker stop $(docker container ls -q)`|
|Remove all unused containers, networks, images and volumes|`docker system prune -a --volumes`|