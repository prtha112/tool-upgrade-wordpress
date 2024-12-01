# tool-upgrade-wordpress
Tool for helm upgrade wordpress
## Input
```
Usage: ./upgrade.sh [-d directory] [-t upgrade type]
Options:
  -d    Directory wordpress
  -t    Upgrade type (all=all, plugin=only plugin, wordpress=only wordpress)
```
## Example
```
./upgrade.sh -d ./wordpress/blog -t all
```
