# Written by Draco (tytydraco @ GitHub)

HASH := $(shell git rev-parse --short HEAD)
VERSION := $(shell cat module.prop | grep version= | sed "s/version=//")

zip:
	make clean || true
	zip -x .git\* Makefile README.md CONTRIBUTING.md -r9 ktweak-$(VERSION)_$(HASH).zip .

clean:
	rm *.zip || true
