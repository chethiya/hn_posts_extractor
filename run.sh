#!/bin/bash

DATE=$(date +"%Y-%m-%d_%H%M")
OUT_DIR=output
NEWS_DATA="$OUT_DIR/$1_$DATE.json"
NEWS_LOG="$OUT_DIR/$1_$DATE.log"

coffee hn.coffee $2 > $NEWS_DATA 2> $NEWS_LOG

