#!/bin/bash

# bitbucket credentials
USER=test     #Username not e-mail
PASS=DTb2VEBe # Access token

#Git credentials
GitUser=test  					 #Username not e-mail
GitPass=ghp_CIFeHypbjC28KrRwW2OK #Access token

# space to void this getting into history. If there are better options to anonymize the password I would like to know

# source: https://stackoverflow.com/a/51142042


for i in {1..2}; do
        curl --user $USER:$PASS "https://api.bitbucket.org/2.0/repositories/$USER?pagelen=100&page=${i}" > repoinfo.page${i}.json
done

## [0].href will return the https link and [1].href the ssh link
cat repoinfo.*.json | jq -r '.values[] | .links.clone[1].href' > repos.txt

# source: https://stackoverflow.com/questions/40429610/bitbucket-clone-all-team-repositories
for repo in `cat repos.txt`; do
        projectname=`basename ${repo}`

        # Set comma as delimiter
        IFS='.'

        #Read the split words into an array based on comma delimiter
        read -a strarr <<< $projectname

        project=${strarr[0]}
        unset IFS

        echo ${strarr[0]}
        echo ${projectname}

        curl -u $GitUser:$GitPass https://api.github.com/user/repos -d '{"name":"'${strarr[0]}'"}'
        git clone --mirror https://$USER@bitbucket.org/$USER/$projectname
        cd $projectname
        git remote set-url origin https://$GitUser:$GitPass@github.com/$GitUser/$projectname
        git push --mirror

done
