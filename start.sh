#!/bin/bash
mkdir -p /tmp/vendor/bundle
docker run --rm -v .:/srv/jekyll -v /tmp/vendor/bundle:/usr/local/bundle -p 4000:4000 -it jekyll/jekyll:3.8  jekyll serve --watch
