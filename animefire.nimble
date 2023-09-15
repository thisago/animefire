# Package

version       = "0.1.1"
author        = "Thiago Navarro"
description   = "AnimeFire downloader"
license       = "GPL-3.0-or-later"
srcDir        = "src"
bin           = @["animefire"]
binDir = "build"


# Dependencies

requires "nim >= 1.6.4"

requires "nimquery"
requires "cligen"

requires "unifetch >= 0.2.0"
requires "util >= 3.1.0"
