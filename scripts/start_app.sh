#!/bin/bash

BASE_DIR=`dirname $0`/../

mongod --dbpath $BASE_DIR"db" &
node $BASE_DIR"web.js" 
