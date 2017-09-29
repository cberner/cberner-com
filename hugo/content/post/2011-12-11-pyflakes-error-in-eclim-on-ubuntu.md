---
title: Pyflakes error in Eclim on Ubuntu
author: Christopher Berner
type: post
date: 2011-12-12T03:58:52+00:00
url: /2011/12/11/pyflakes-error-in-eclim-on-ubuntu/
categories:
  - Python
  - Vim

---
I started using Eclim a couple days ago, and kept running into `Error running command: pyflakes <path to my code>`, when my files contained more than one syntax error/warning. After a bit of googling I discovered [this bug][1], which suggests that the version of pyflakes in Debian isn't compatible with Eclim. Sure enough, removing the the .deb package (apt-get remove pyflakes) and installing it from pip (pip install pyflakes), fixed it.

 [1]: https://github.com/ervandew/eclim/issues/33
