#!/bin/bash
find down -name '*.log' -exec grep -H 'Fujitsu Compiler: Licensed number of users already reached.' {} \;
