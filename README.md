This repo contains command-line utilities that I end up using constantly.

![Swift 5](https://img.shields.io/badge/Swift-5-orange.svg) ![platforms](https://img.shields.io/badge/platforms-macOS-lightgrey.svg) [![License](http://img.shields.io/:license-mit-blue.svg)](http://doge.mit-license.org)

## Utilities

- **Git update**.
  `git pull --tags` in all projects under the given path (or the working directory if no path is provided). It can be used as following:
  ```bash
  # Pull on all projects under the current working directory.
  git-update
  # Pull on all projects under the given path.
  git-update ~/Workspace/Code/Swift
  ```
- **Template Query**.
  Small command line tool to query all Xcode templates.  
