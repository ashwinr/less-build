# less-build

An Atom builder plugin for LESS files. On save in a given project, all less files specified will be compiled and the results saved to one or more destination files.

## Configuration

In config.cson, add a less-build config object. See the example object below.

For a given project, use the options object to specify one or more source files as keys. The value of that key can be either a string or an array of strings representing file path[s] for destinations for the compiled less files.
```cson
"less-build":
    "project": "project-folder-name"
    "options":
      "app/src/app.less": "app/build/src/app.css"
      "lib/src/lib.less": "lib/build/src/lib.css"
      "lib/src/multipleDestinations.less": [
        "lib/build/src/multipleDestinations.css"
        "second/target/path/multipleDestinations.css"
      ]        
```