# Changelog

## v0.1.5

Bug fixes:

* Fix an archive creation error that would result in an archive that would fail
  to unpack.
* Fix a segfault when passing an internal command line parameter to the archive

## v0.1.4

This release doesn't change much externally. Internally, we've started cleaning
up the code and adding tests to make Bakeware easier for us to maintain. If you
have existing Bakeware projects, you may also be interested in our example
updates to turn off Erlang distribution and remove the verbose mix release
instructions.

Bug fixes:

* Running the same Bakeware archive at or near the same time now works.
  Previously, it was possible for multiple instances to collide when
  extracting.

## v0.1.3

Bug fixes:

* Fix hex package to include zstd source.

## v0.1.2

Bug fixes:

* Fix script startup crash when testing locally (#66)

## v0.1.1

Initial release to hex.

This release is ok for experimentation, but it not intended for production use.
It has known issues with script and extraction cache handling.
