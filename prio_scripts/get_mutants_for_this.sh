#!/bin/bash

#In order to make this work, the folder prio_scripts must exist in project root directory

pom_manipulator_python_file_path="./prio_scripts/pom_editor_for_pitest.py"

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
	echo "installing plugins (idempotent) ..."
	cd pitest-plugins
	mvn install > /dev/null 2>&1
	cd ..
	rm -rf pitest-plugins
	echo "done!"
}

generate_mutation_table()
{
	echo "generating mutation table ..."
	mvn org.pitest:pitest-maven:mutationCoverage
	echo "done!"
}

handle_necessary_plugins()
{
	get_plugins
	install_plugin
}

main()
{
	set -e

	manipulate_pom
	handle_necessary_plugins
	generate_mutation_table

	set +e
}

main
