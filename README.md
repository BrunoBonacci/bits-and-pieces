blog.brunobonacci.com
======================

bits and pieces (blogging website)

See my blog at: [blog.brunobonacci.com](http://blog.brunobonacci.com)

Jekyll theme based on the [Jekyll Uno](https://github.com/joshgerdes/jekyll-uno).

## Start locally

You can start locally with

``` bash
bundle install
bundle exec jekyll serve --watch

# build static site
bundle exec jekyll build
```
Then you can browse [http://localhost:4000/](http://localhost:4000/).


## Docker start

``` bash
mkdir -p /tmp/vendor/bundle
docker run --rm -v .:/srv/jekyll -v /tmp/vendor/bundle:/usr/local/bundle -p 4000:4000 -it jekyll/jekyll:3.8  jekyll serve --watch
```
