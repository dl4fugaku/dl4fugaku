#!/bin/bash
find down -maxdepth 2 -name config.log -exec grep 'Fujitsu Compiler: Licensed number of users already reached.' {} \;
