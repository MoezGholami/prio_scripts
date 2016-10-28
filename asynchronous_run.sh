#!/bin/bash

github_username="prioresultposter"
github_email="prioresultposte@30mail.ir"
github_password="abcdefg1234567"

temp_repo_name=$( echo $(date) $(date +%s%N) | tr -cd '[[:alnum:]]._-' )

target_repo_url=$1
target_commit_hash=$2

travis_login()
{
	expect -c '
	spawn travis login
	set prompt ":|#|\\\$"
	expect "Username: "
	send "'$github_username'\r"
	expect "Password for '$github_username': "
	send "'$github_password'\r"
	interact -o -nobuffer -re $prompt return
	'
}

create_github_repo()
{
	expect -c '
		spawn curl -u "'$github_username'" https://api.github.com/user/repos -d "{\"name\":\"'$temp_repo_name'\"}" > /dev/null
		set prompt ":|#|\\\$"
		expect "*?assword*"
		send "'$github_password'\r"
		interact -o -nobuffer -re $prompt return
	'
}

make_travis_run()
{
	git clone https://github.com/$github_username/$temp_repo_name
	sed "s%TARGET_RERPOSITORY_URL%$target_repo_url%g" travis_run.sh | sed "s%TARGET_COMMIT_HASH%$target_commit_hash%g" > $temp_repo_name/travis_run.sh
	cp .travis.yml $temp_repo_name/.travis.yml
	cd $temp_repo_name
	git add .
	git config --local user.name $github_username
	git config --local user.email $github_email
	git config --local user.password $github_password
	git config remote.origin.url https://$github_username:$github_password@github.com/$github_username/$temp_repo_name.git
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
	travis enable -r $github_username/$temp_repo_name
	make_travis_run
	travis logout

	set +e
}

main
