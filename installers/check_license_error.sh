#!/bin/bash
find . -name config.log -exec grep 'Fujitsu Compiler: Licensed number of users already reached.' {} \;
