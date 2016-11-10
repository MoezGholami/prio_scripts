#!/bin/bash

#This script asynchronously calculates mutation table for a git project at specific commit on Travis CI
#Result will be pushed to a github repository.
#In order to have less redundancy, please read the constant_values.sh file.
#
#This script gets three arguments in command line.
#
#First one is the experiment name; which should not contain any white space
#
#Second one is the URL (ssh/http) of target git project.
#It should be accessible from Travis server (e.g. not local server).
#
#Third is the prefix of SHA of desired commit of target project to calculate its mutation table.
#
#This script presumes that git and travis are available as commands. Also it needs internet connection.

. $(find . -name constant_values.sh)

experiment_name=$1
target_repo_url=$2
target_commit_hash=$3

temp_repo_name=$experiment_name"_"$( echo $(date) $(date +%s%N) | tr -cd '[[:alnum:]]._-' )

travis_login()
{
	expect -c '
	spawn travis login
	set prompt ":|#|\\\$"
	expect "Username: "
	send "'$result_repo_commiter_name'\r"
	expect "Password for '$result_repo_commiter_name': "
	send "'$result_repo_commiter_pass'\r"
	interact -o -nobuffer -re $prompt return
	'
}

create_github_repo()
{
	expect -c '
		spawn curl -u "'$result_repo_commiter_name'" https://api.github.com/user/repos -d "{\"name\":\"'$temp_repo_name'\"}" > /dev/null
		set prompt ":|#|\\\$"
		expect "*?assword*"
		send "'$result_repo_commiter_pass'\r"
		interact -o -nobuffer -re $prompt return
	'
}

make_travis_run()
{
	git clone https://github.com/$result_repo_commiter_name/$temp_repo_name

	sed "s/TARGET_RERPOSITORY_URL/${target_repo_url//\//\\/}/g" travis_run.sh |
		sed -e "s/SCRIPTS_REPO_URL/${scripts_repo_url//\//\\/}/g" |
		sed -e "s%DEFAULT_EXPERIMENT_NAME%$experiment_name%g" |
		sed -e "s%TARGET_COMMIT_HASH%$target_commit_hash%g" > $temp_repo_name/travis_run.sh

	cp the_dot_travis_for_travis_temp_repo.yml $temp_repo_name/.travis.yml
	cd $temp_repo_name
	git add .
	git config --local user.name $result_repo_commiter_name
	git config --local user.email $result_repo_commiter_email
	git config --local user.password $result_repo_commiter_pass
	git config remote.origin.url \
		https://$result_repo_commiter_name:$result_repo_commiter_pass@github.com/$result_repo_commiter_name/$temp_repo_name.git
	git commit -am "run travis"
	git push origin master
	cd ..
	rm -rf $temp_repo_name
}

sync_travis()
{
	local travis_ret_val=0
	set +e

	travis sync
	travis_ret_val=$?
	while [[ $travis_ret_val -ne 0 ]]
	do
		sleep 1
		echo "travis sync failed, retrying ..."
		travis sync
		travis_ret_val=$?
	done

	set -e
}

main()
{
	set -e

	travis_login
	create_github_repo
	sync_travis
	travis enable -r $result_repo_commiter_name/$temp_repo_name
	make_travis_run
	travis logout

	set +e
}

main
