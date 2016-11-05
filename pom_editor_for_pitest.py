#!/usr/bin/python
# -*- coding: UTF-8 -*-

import os
import shutil

pitest_plugin=''

def main():
	this_dir = os.path.relpath(".","..")
	shutil.copyfile('prio_scripts/pom_files/'+this_dir+'.xml', 'pom.xml')

main()
