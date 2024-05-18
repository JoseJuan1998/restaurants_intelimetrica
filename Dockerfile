FROM bitwalker/alpine-elixir-phoenix:1.13.1

WORKDIR /app

COPY mix.exs ./
RUN mix deps.get
RUN MIX_ENV=test mix deps.compile
RUN MIX_ENV=dev mix deps.compile

COPY config config
COPY priv priv
COPY lib lib
COPY test test

COPY coveralls.json README.md run.sh ./
RUN chmod +x ./run.sh

CMD ["./run.sh"]
