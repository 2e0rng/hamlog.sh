# hamlog.sh

An Amateur Radio logbook written in bash

## About

hamlog.sh is an amauter radio logbook written in bash. Why does it exist
you ask? I'm one of these people who spends most of their time in a
terminal. There are many pieces of amatuer radio logging software but
many of the only run on windows and none of the ones I have tried work
exactly how I'd like. So what did I do? I wrote one.

## Usage

hamlog.sh is (currently) a single shell script. It has within it sub
commands that are accessed by running `hamlog.sh <command>`. There are a
consitant set of options that can be passed to any command (see
`hamlog.sh --help` or `hamlog help` for more info).

```
$ hamlog.sh help
Usage: ./hamlog.sh [COMMAND] [OPTIONS]...

An Amateur Radio Logbook written in bash

Commands
    help           view this help text
    view           view the logbook
    new            create new logbook entry
    interactive    shows the logbook then reqeusts new input (repeatedly)
    conditions     show current band conditions (from
                   http://www.hamqsl.com/solarxml.php)

Options
    -h --help           view this help text
    -d --date-format    output date format (passed to 'date')
    -l --logbook        logbook file
```
## Conditions

The bands conditions feature uses the API from
[hamqsl](https://www.hamqsl.com/solar.html). Check out
[hamqsl.com](https://www.hamqsl.com) for more information.
