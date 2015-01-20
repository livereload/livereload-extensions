LiveReload Browser Extensions
=============================

Prerequsities:

* Node.js (0.10.x or later) with npm

Install dependencies:

* `npm install`

Build and package extensions:

    grunt chrome
    grunt firefox
    grunt all

(Safari extension must be built manually, using Safari's GUI packager tool.)

Build CoffeeScript modules, but don't pack:

    grunt build


Release checklist
-----------------

1. Bump version number in `package.json`, run `rake version`, commit.

1. `grunt all`

1. Package Safari extension.

1. Test, test, test.

1. `rake tag`

1. `rake upload:safari`, `rake upload:firefox` or `rake upload:all`

1. Download and verify that uploads worked.

1. `rake upload:manifest`

1. Publish Chrome extension on the Chrome Web Store.
