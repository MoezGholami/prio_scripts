#!/bin/bash

scripts_repo_url="https://github.com/MoezGholami/prio_scripts"
target_repo_url="TARGET_RERPOSITORY_URL"
target_commit_hash="TARGET_COMMIT_HASH"

main()
{
	set -e

	git clone $target_repo_url
	cd $(basename $target_repo_url)
	git reset --hard $target_commit_hash
	git clone $scripts_repo_url
	./$(basename $scripts_repo_url)/get_mutants_for_this.sh
	cd ..

	set +e
}

main
