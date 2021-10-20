#!/usr/bin/env python3
# coding:utf-8

import os
import unittest

from setup import Android, Project, Ios, Flutter

project = Project()
project.project_path = os.path.curdir
project.new_package = 'com.example'
project.new_app_name = ''
project.new_project_name = 'example_project'


class AndroidTest(unittest.TestCase):
    def setUp(self):
        self.android = Android(project)

    def test_get_old_package(self):
        self.assertEqual(self.android.get_old_package(), 'co.nimblehq.flutter.template')

    def test_get_old_app_name(self):
        self.assertEqual(self.android.get_old_app_name(), 'Flutter Templates')

    def test_check_original_route(self):
        old_package = self.android.get_old_package()
        self.assertEqual(self.android.check_original_route(old_package), None)


class IosTest(unittest.TestCase):
    def setUp(self):
        self.ios = Ios(project)

    def test_get_old_package(self):
        self.assertEqual(self.ios.get_old_package(), 'co.nimblehq.flutter.template')

    def test_get_old_app_name(self):
        self.assertEqual(self.ios.get_old_app_name(), 'Flutter Templates')

    def test_get_old_project_name(self):
        self.assertEqual(self.ios.get_old_project_name(), 'flutter_templates')


class FlutterTest(unittest.TestCase):
    def setUp(self):
        self.flutter = Flutter(project)

    def test_get_old_project_name(self):
        self.assertEqual(self.flutter.get_old_project_name(), 'flutter_templates')


if __name__ == '__main__':
    unittest.main()
