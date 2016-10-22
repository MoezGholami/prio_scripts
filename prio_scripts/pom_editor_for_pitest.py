#!/usr/bin/python
# -*- coding: UTF-8 -*-


import xml.etree.ElementTree as ET

pitest_plugin=''
pom_path=''

def main():
	global pom_path

	init_constants()
	root = parse_and_get_root(pom_path)
	prefix_of_project = get_project_root_prefix(root)
	pitest_plugin_text = make_pitest_conf_text(prefix_of_project)
	insert_pitest_plugin(root, pitest_plugin_text)
	save_changes(root, pom_path)

def save_changes(root, pom_path):
	ET.ElementTree(root).write(pom_path)

def insert_pitest_plugin(root, pitest_plugin_text):
	build_tag = root.find('build')
	if build_tag is None:
		build_tag = ET.Element('build')
	plugins_tag = build_tag.find('plugins')
	if plugins_tag is None:
		plugins_tag = ET.Element('plugins')
	if 'org.pitest' not in ET.tostring(plugins_tag):
		plugins_tag.append(ET.fromstring(pitest_plugin_text))

def make_pitest_conf_text(prefix_of_project):
	global pitest_plugin
	return pitest_plugin.replace('ROOT_PREFIX_OF_PROJECT', prefix_of_project)

def get_project_root_prefix(root):
	return root.find('groupId').text.strip()

def parse_and_get_root(pom_path):
	it = ET.iterparse(pom_path)
	for _, el in it:
		if '}' in el.tag:
			el.tag = el.tag.split('}', 1)[1]  # strip all namespaces
	return it.root

def init_constants():
	global pitest_plugin
	global pom_path
	pom_path = 'pom.xml'
	pitest_plugin=									\
	'<plugin>									\n\
		<groupId>org.pitest</groupId>						\n\
		<artifactId>pitest-maven</artifactId>					\n\
		<version>1.0.0</version>						\n\
		<configuration>								\n\
			<targetClasses>							\n\
				<param>ROOT_PREFIX_OF_PROJECT.*</param>			\n\
			</targetClasses>						\n\
			<targetTests>							\n\
				<param>ROOT_PREFIX_OF_PROJECT.*</param>			\n\
			</targetTests>							\n\
			<outputFormats>							\n\
				<outputFormat>CSV</outputFormat>			\n\
				<outputFormat>HTML</outputFormat>			\n\
			</outputFormats>						\n\
		</configuration>							\n\
		<dependencies>								\n\
			<dependency>							\n\
				<groupId>org.pitest.plugins</groupId>			\n\
				<artifactId>pitest-all-tests-plugin</artifactId>	\n\
				<version>0.1-SNAPSHOT</version>				\n\
			</dependency>							\n\
		</dependencies>								\n\
	</plugin>'

main()
