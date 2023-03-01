#!/usr/bin/env python3
# coding:utf-8

import os
import unittest

from setup import Android, Project, Ios, Flutter

# After creating a new project, the new project will be created in the current directory.
expected_project_path = os.environ.get("PROJECT_PATH").replace("/template", "") if os.environ.get("RUNNING_TEST_MODE") == "0" else os.environ.get("PROJECT_PATH")
expected_package_name = os.environ.get("PACKAGE_NAME") if bool(os.environ.get("PACKAGE_NAME")) else "co.nimblehq.flutter.template"
expected_app_name = os.environ.get("APP_NAME") if bool(os.environ.get("APP_NAME")) else "Flutter Templates"
expected_project_name = os.environ.get("PROJECT_NAME") if bool(os.environ.get("PROJECT_NAME")) else "flutter_templates"
expected_app_version = os.environ.get("APP_VERSION") if bool(os.environ.get("APP_VERSION")) else "0.1.0"
expected_build_number = os.environ.get("BUILD_NUMBER") if bool(os.environ.get("BUILD_NUMBER")) else "1"

project = Project(
    expected_project_path,
    expected_package_name,
    expected_app_name,
    expected_project_name,
    expected_app_version,
    expected_build_number
)

class AndroidTest(unittest.TestCase):
    def setUp(self):
        self.android = Android(project)

    def test_get_old_package(self):
        self.assertEqual(self.android.get_current_package_name(), expected_package_name)

    def test_get_old_app_name(self):
        self.assertEqual(self.android.get_current_app_name(), expected_app_name)

    def test_check_original_route(self):
        old_package = self.android.get_current_package_name()
        self.assertEqual(self.android.check_original_route(old_package), None)


class IosTest(unittest.TestCase):
    def setUp(self):
        self.ios = Ios(project)

    def test_get_old_package(self):
        self.assertEqual(self.ios.get_current_package_name(), expected_package_name.replace("_", "-"))

    def test_get_old_app_name(self):
        self.assertEqual(self.ios.get_current_app_name(), expected_app_name)

    def test_get_old_project_name(self):
        self.assertEqual(self.ios.get_current_project_name(), expected_project_name)


class FlutterTest(unittest.TestCase):
    def setUp(self):
        self.flutter = Flutter(project)

    def test_get_old_project_name(self):
        self.assertEqual(self.flutter.get_old_project_name(), expected_project_name)


if __name__ == '__main__':
    unittest.main()
