#!/bin/bash

DATE=$(date +"%d-%m-%Y_%H%M")
OUT_DIR=output
NEWS_DATA="$OUT_DIR/news_$DATE.json"
NEWS_LOG="$OUT_DIR/news_$DATE.log"

coffee hn.coffee /news > $NEWS_DATA 2> $NEWS_LOG

