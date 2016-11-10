#!/bin/bash

#This is the heart of mutation table calculation
#It calculates the mutation table for the current project
#Then based on the constant parameters, the results will be pushed to results repository on github
#In order to make this work, the folder prio_scripts must exist in project root directory
#Running this script recuires internet connection, git command and maven (mvn) command, and in fact jdk
#It gets an optional main parameter indicating the name of the experiment.
#
#The result file will be pushed with name containing experiment name, target project name,
#and SHA of desired snapshot of the project.

#Redundancy:
#In send result function we are using some parts of url of results repo

. $(find . -name constant_values.sh)

experiment_name="defaultExperimentName"
if [ -n "$1" ]; then experiment_name=$1; fi

echo $experiment_name

get_desired_pitest()
{
	echo "cloning desired pitest version ..."
	git clone $desired_pitest_repo_url > /dev/null 2>&1
	echo "done!"
}

manipulate_pom()
{
	echo "manipulating pom.xml"
	local project_name=$(basename "$PWD")
	cp prio_scripts/pom_files/$project_name.xml ./pom.xml
	echo "done!"
}

install_desired_pitest()
{
	echo "installing desired pitest version ..."
	cd pitest
	mvn install -DskipTests > /dev/null 2>&1
	cd ..
	rm -rf pitest
	echo "done!"
}

generate_mutation_table()
{
	echo "generating mutation table ..."
	rm -rf target
	mvn test || echo "test error"
	mvn org.pitest:pitest-maven:mutationCoverage || echo "error"
	echo "done!"
}

handle_desired_pitest()
{
	echo "looking for desired pitest..."
	if [ -d ~/.m2/repository/org/pitest/pitest/$desired_pitest_version ]
	then
		echo "already installed"
	else
		get_desired_pitest
		install_desired_pitest
	fi
}

send_result()
{
	local this_commit_hash=$(git rev-parse HEAD)
	local this_project_name=$(basename $(git remote -v | head -n1 | awk '{print $2}' | sed -e 's,.*:\(.*/\)\?,,' -e 's/\.git$//'))
	local result_file_name=$experiment_name"_"$this_project_name"_"$this_commit_hash".csv"
	local results_dir=$(basename "$result_repo")

	git clone "$result_repo"
	mv $(find target/pit-reports -name mutations.csv) $results_dir/$result_file_name
	cd $results_dir
	git config --local user.name $result_repo_commiter_name
	git config --local user.email $result_repo_commiter_email
	git config --local user.password $result_repo_commiter_pass
	git config remote.origin.url https://$result_repo_commiter_name:$result_repo_commiter_pass@github.com/Moezgholami/$results_dir.git
	git add $result_file_name
	git commit -am "$result_file_name"
	git push origin master
	cd ..
	rm -rf $results_dir
}

main()
{
	set -e

	manipulate_pom
	handle_desired_pitest
	generate_mutation_table
	send_result

	set +e
}

main
