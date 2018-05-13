# Toys

[![Travis-CI Build Status](https://travis-ci.org/dazuma/toys.svg)](https://travis-ci.org/dazuma/toys/)

Toys is a command line binary that lets you build your own suite of command
line tools (with commands and subcommands) using a Ruby DSL. Commands can be
defined globally or scoped to directories.

This repository includes the source for the **toys** gem, which provides the
`toys` binary itself, and the **toys-core** gem, which includes the underlying
command line framework.

## Contributing

While we appreciate contributions, please note that this software is currently
highly experimental, and the code is evolving very rapidly. Please contact the
author before embarking on a major pull request. More detailed contribution
guidelines will be provided when the software stabilizes further.

The source can be found on Github at
[https://github.com/dazuma/toys](https://github.com/dazuma/toys)

### TODO items

* Providing an accept: should automatically force a value label
* Investigate required flags and flag groups
* --short-help or --usage?
* toys help
* Pipe long help into less?
* Expand set_default_descriptions to include flags/args
* Figure out why subtools with no desc don't pick up the set_default_descriptions
* Consider a helper method for wrappable strings.
* Flesh out long descriptions for our standard tools and stuff

* Improve test coverage
* Write user's guide
* Investigate middleware and/or templates for output formats
* Investigate system paths tool
* Investigate group clearing/locking

## License

Copyright 2018 Daniel Azuma

This software is licensed under the 3-clause BSD license.

See the LICENSE.md file for more information.
