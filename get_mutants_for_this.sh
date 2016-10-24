#!/bin/bash

#In order to make this work, the folder prio_scripts must exist in project root directory

pom_manipulator_python_file_path="./prio_scripts/pom_editor_for_pitest.py"
result_repo="https://github.com/MoezGholami/prio_results"
result_repo_commiter_name="prioresultposter"
result_repo_commiter_email="prioresultposte@30mail.ir"
result_repo_commiter_pass="abcdefg1234567"

get_plugins()
{
	echo "cloning necessary pitest plugins ..."
	git clone https://github.com/szpak/pitest-plugins > /dev/null 2>&1
	echo "done!"
}

manipulate_pom()
{
	echo "manipulating pom.xml"
	python "$pom_manipulator_python_file_path"
	echo "done!"
}

install_plugin()
{
	echo "installing plugins ..."
	cd pitest-plugins
	mvn install > /dev/null 2>&1
	cd ..
	rm -rf pitest-plugins
	echo "done!"
}

generate_mutation_table()
{
	echo "generating mutation table ..."
	rm -rf target
	mvn test > /dev/null
	mvn org.pitest:pitest-maven:mutationCoverage || echo "error"
	echo "done!"
}

handle_necessary_plugins()
{
	echo "looking for pitest plugins..."
	if [ -d ~/.m2/repository/org/pitest/plugins/pitest-all-tests-plugin ]
	then
		echo "already installed"
	else
		get_plugins
		install_plugin
	fi
}

send_result()
{
	local this_commit_hash=$(git rev-parse HEAD)
	local this_project_name=$(basename $(git remote -v | head -n1 | awk '{print $2}' | sed -e 's,.*:\(.*/\)\?,,' -e 's/\.git$//'))
	local result_file_name=$this_project_name"_"$this_commit_hash".csv"
	local results_dir=$(basename "$result_repo")

	git clone "$result_repo"
	mv $(find target/pit-reports -name mutations.csv) $results_dir/$result_file_name
	cd $results_dir
	git config --local user.name $result_repo_commiter_name
	git config --local user.email $result_repo_commiter_email
	git config --local user.password $result_repo_commiter_pass
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
	handle_necessary_plugins
	generate_mutation_table
	send_result

	set +e
}

main
