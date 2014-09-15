#!/bin/bash

# fail if anything errors
set -e
# fail if a function call is missing an argument
set -u

rm -rf en

./generate-chapters.rb

echo "build - Starting PDF Generation -----------------------------------------------"
./makepdfs.sh en
echo "build - Finshed PDF Generation - see team-book.en.pdf --------------------------"

echo "build - Starting mobi Generation ----------------------------------------------"
export FORMAT=mobi
./makeebooks.rb en
echo "build - Finished mobi Generation - see team-book.en.mobi -----------------------"

echo "build - Starting epub Generation ----------------------------------------------"
export FORMAT=epub
./makeebooks.rb en
echo "build - Finished epub Generation - see team-book.en.epub -----------------------"

# We dont' want to keep this around
rm team-book.en.html

mv team-book.en.epub team/team.epub
mv team-book.en.mobi team/team.mobi
mv team-book.en.pdf team/team.pdf

