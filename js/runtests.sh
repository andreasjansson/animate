#!/bin/bash
rm app/model/*.js 2> /dev/null
rm app/view/*.js 2> /dev/null
./node_modules/jasmine-node/bin/jasmine-node --coffee test/
