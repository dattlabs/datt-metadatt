

.PHONY: all test

all: test

test:
	bats ./tests/*
