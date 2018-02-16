# BashMe

**BashMe** is my personal collection of commands and scripts for Bash 4+.

It's primitive to a fault, and comprises the minimal set of utilities that
I find I use on a near-daily basis.

## Installation

1. Check out a clone of this repo to a location of your choice, such as
   `git clone https://github.com/rusnyder/bashme.git ~/.bashme`
2. Load BashMe from your environment via `~/.bash_profile` or `~/.bashrc`
    * _NOTE: I recommend loading BashMe from `~/.bashrc`, then source `~/.bashrc`
      from `~/.bash_profile` for the most consistent Bash experience._

    ```bash
    # ~/.bashrc
    . "$HOME/.bashme/bashme.sh"

    # ~/.bash_profile
    if [ -f $HOME/.bashrc ]; then
      source $HOME/.bashrc
    fi
    ```
3. Add any customizations as shell scripts to the `~/.bashme/modules` directory
   (files must be named using `*.sh` pattern to be loaded)

## Notes

This has only been tested on my machine on OSX.  It's not intended to be generally
useful, which I attribute to my selfishness or because there are a billion tools
that do much more than this already (take a look at [Bash-It][bashit] if you're
reading this!)

The only reason I wrote this instead of using Bash-It was because of some slowness
out-of-the-box with that tool, most of which I attribute to the git function
implementations there, and none of which I've had time to dig into thus far.

[bashit]: https://github.com/Bash-it/bash-it


## Contributors

* [List of contributors](https://github.com/rusnyder/bashme/contributors)
