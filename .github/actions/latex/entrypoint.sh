#!/bin/bash
set -eux

# build pdf (change if necessary)
# latexmk -pvc thesis/thesis.tex
latexmk thesis/thesis.tex

# create release
res=`curl -H "Authorization: token $GITHUB_TOKEN" -X POST https://api.github.com/repos/$GITHUB_REPOSITORY/releases \
-d "
{
  \"tag_name\": \"v$GITHUB_SHA\",
  \"target_commitish\": \"$GITHUB_SHA\",
  \"name\": \"v$GITHUB_SHA\",
  \"draft\": false,
  \"prerelease\": false
}"`

# extract release id
rel_id=`echo ${res} | python3 -c 'import json,sys;print(json.load(sys.stdin)["id"])'`

# upload built pdf
curl -H "Authorization: token $GITHUB_TOKEN" -X POST https://uploads.github.com/repos/$GITHUB_REPOSITORY/releases/${rel_id}/assets?name=thesis.pdf\
  --header 'Content-Type: application/pdf'\
  --upload-file thesis.pdf

####################
  
# build pdf (change if necessary)
# latexmk -pvc abst/abst.tex
latexmk abst/abst.tex


# upload built pdf
curl -H "Authorization: token $GITHUB_TOKEN" -X POST https://uploads.github.com/repos/$GITHUB_REPOSITORY/releases/${rel_id}/assets?name=abst.pdf\
  --header 'Content-Type: application/pdf'\
  --upload-file abst.pdf
