---
title: Git revision numbers for setuptools packages
author: Christopher Berner
type: post
date: 2012-02-26T22:16:03+00:00
url: /2012/02/26/git-revision-numbers-for-setuptools-packages/
categories:
  - Python
comments: false

---
Add snapshot versions to your setuptools packages from SVN is easy, using the `tag_svn_revision = true` options in setup.cfg. However, getting this working for GIT proved to be more difficult, as there's no built in support. However, I finally settled on a bash script that does the job quite nicely.

```bash
now=`date +%s`

gitversion=`git describe --long --dirty=-$now | sed 's/.\*(\[-\]\[0-9\]\[0-9]\*[-\]\[a-z0-9\]*)/1/'`

python setup.py setopt -o tag_build -s $gitversion -c egg_info

python setup.py sdist
```

First we generate a unique version string, based on the number of commits since the last GIT tag:
```bash
now=`date +%s`
  
gitversion=`git describe --long --dirty=-$now | sed 's/.\*(\[-\]\[0-9\]\[0-9]\*[-\]\[a-z0-9\]*)/1/'`
```

Then we just apply it as an option before building the release:

```bash
python setup.py setopt -o tag_build -s $gitversion -c egg_info
python setup.py sdist
```
