.PHONY: all deps compile run release test clean check

all: deps compile

deps:
	mix deps.get
	mix deps.compile

compile:
	mix compile

release:
	mix release

test:
	mix test

check:
	mix format --check-formatted

clean:
	rm -rf _build

run:
	iex -S mix
