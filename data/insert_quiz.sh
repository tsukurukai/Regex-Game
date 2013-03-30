#!/bin/bash

mongo regex --eval "db.dropDatabase()"
ruby yml2json.rb
mongoimport -d regex -c study -type json -file study.js -headerline
rm study.js
