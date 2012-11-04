gaetk-template
==============

Template for Applications build with [gaetk](https://github.com/hudora/appengine-toolkit).


How to run it
-------------

1. Replace `%APPNAME%` in `app.yaml` and `Makefile` with the desired Name of your app.
2. Type `make deploy` - this should set up a new version on App Engine.


How to include libraries from Github
------------------------------------


    git submodule add ghttps://github.com/sixohsix/twitter.git lib/twitter-toolkit
    echo "./twitter-toolkit" >> lib/submodules.pth

Note: Submodule Directories should not be named like the library itself. It is
good practice to name the directory `libname*-something*`.


How to include libraries directly in your repository
----------------------------------------------------

Just copy them into `./lib` and add them to submodules.pth

