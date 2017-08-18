# e0-lpr
*Print on printers in MZH floor 0*

[![Build Status](https://travis-ci.org/michel-zimmer/e0-lpr.svg?branch=master)](https://travis-ci.org/michel-zimmer/e0-lpr)

The [script](e0-lpr.sh) asks for printing options, copies the file over SSH, prints it and deletes it afterwards.

`HOST=... e0-lpr ...` can be used to specify the host running `lpr`.
