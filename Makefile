# Written by Draco (tytydraco @ GitHub)

HASH := $(shell git rev-parse --short HEAD)
VERSION := $(shell cat module.prop | grep version= | sed "s/version=//")

zip:
	zip -x .git\* Makefile README.md -r9 ktweak-$(VERSION)_$(HASH).zip .

clean:
	rm *.zip 2> /dev/null
