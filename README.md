# baloo-clear-of-non-existing

A Shell-script-workaround for baloo file indexer to clean its database of non-existing files.

For now, baloo file indexer sometimes doesn't automatically remove deleted files from index, which is an old [known bug](https://bugs.kde.org/show_bug.cgi?id=353874).

This script will be a far faster and more resource-efficient solution than purging the entire index and rebuilding it.

Caveats:
- this script will misbehave when there are files with newline characters (\n) in their full path. It will try to delete them, regardless of if they are present on your disk or not.
  You shouldn't keep files with those characters in their names.
- it will not get rid of empty entries in the index, see #3. In this case, you should rebuild one from scratch.
