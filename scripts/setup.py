#!/usr/bin/env python3
# coding:utf-8

import os
import sys
import shutil
import argparse
import re
import enquiries

PACKAGE_SEPARATOR = "."
ANDROID_MODULE = "app"  # only app module now


class JsonSerializable:
	def __init__(self, field_rename):
		self.field_rename = field_rename

class Project:
	def __init__(self, project_path, new_package, new_app_name, new_project_name, app_version, build_number):
		self.project_path = project_path
		self.new_package = new_package
		self.new_app_name = new_app_name
		self.new_project_name = new_project_name
		self.app_version = app_version
		self.build_number = build_number
		self.json_serializable = None


class Android:
    def __init__(self, p):
        self.project = p
        self.initial_folder = p.project_path + os.sep + "android"

    def get_current_package_name(self):
        build_file = self.initial_folder + os.sep + ANDROID_MODULE + os.sep + "build.gradle"
        f = open(build_file, "r")
        file_text = f.read()
        f.close()
        for line in file_text.split("\n"):
            if "applicationId" in line.strip():
                return line.strip().split(" ")[1].strip().replace("\"", "")
        return None

    def get_current_app_name(self):
        string_res_file = self.initial_folder + os.sep + ANDROID_MODULE + os.sep + "src" + \
            os.sep + "main" + os.sep + "res" + os.sep + "values" + os.sep + "strings.xml"
        f = open(string_res_file, "r")
        file_text = f.read()
        f.close()
        for line in file_text.split("\n"):
            if "app_name" in line.strip():
                return line.strip().replace("<string name=\"app_name\">",
                                            "").replace("</string>", "")
        return None

    def check_original_route(self, old_package):
        print("Checking original package...")
        original_route = self.initial_folder + os.sep + ANDROID_MODULE + os.sep + "src" + os.sep + \
            "main" + os.sep + "kotlin" + os.sep + old_package.replace(PACKAGE_SEPARATOR, os.sep)
        if os.path.isdir(original_route):
            print("Original package exists! Updating package...")
        else:
            print(
                "❌ Original package not found, please write a correct original package!"
            )
            sys.exit()

    def move_code_folder(self, folder_name, old_package):
        original_route = self.initial_folder + os.sep + ANDROID_MODULE + os.sep + "src" + os.sep + \
            folder_name + os.sep + "kotlin" + os.sep + \
            old_package.replace(PACKAGE_SEPARATOR, os.sep)
        destiny_route = self.initial_folder + os.sep + ANDROID_MODULE + os.sep + "src" + os.sep + \
            folder_name + os.sep + "kotlin" + os.sep + \
            self.project.new_package.replace(PACKAGE_SEPARATOR, os.sep)
        shutil.move(original_route, self.initial_folder + os.sep +
                    ANDROID_MODULE + os.sep + "my_temporal_folder")
        shutil.rmtree(self.initial_folder + os.sep + ANDROID_MODULE + os.sep +
                      "src" + os.sep + folder_name + os.sep + "kotlin" + os.sep)
        shutil.move(self.initial_folder + os.sep + ANDROID_MODULE +
                    os.sep + "my_temporal_folder", destiny_route)

    def move_folders(self, old_package):
        path_folder = self.initial_folder + os.sep + ANDROID_MODULE + os.sep + "src"
        for f in os.listdir(path_folder):
            # Only rename package in main
            if os.path.isdir(path_folder + os.sep + f) and f == 'main':
                self.move_code_folder(str(f), old_package)

    def repackage(self):
        old_package = self.get_current_package_name()
        if old_package is not None and old_package != self.project.new_package:
            self.check_original_route(old_package)
            self.update_name(self.initial_folder, old_package, self.project.new_package)
            self.move_folders(old_package)
            print("✅ Update package name for Android successfully!")
        elif old_package is None:
            print("❌ applicationId not found in app/build.gradle... Exiting!")
            sys.exit()
        else:
            print("Reusing old package name in Android!")

    def rename_app(self):
        old_app_name = self.get_current_app_name()
        if old_app_name is not None and old_app_name != self.project.new_app_name:
            self.update_name(self.initial_folder, old_app_name, self.project.new_app_name)
            print("✅ Rename Android app successfully!")
        elif old_app_name is None:
            print("❌ Unable to find the old app name for Android!")
            sys.exit()
        else:
            print("Reusing old app name in Android!")

    def replace_text(self, path_file, old_text, new_text):
        f = open(path_file, "r")
        try:
            file_text = f.read()
            f.close()
            t = file_text.replace(old_text, new_text)
            f = open(path_file, "w")
            f.write(t)
            f.close()
        except UnicodeDecodeError:  # This file is not text plain
            f.close()

    def update_name(self, path_folder, old_name, new_name):
        for f in os.listdir(path_folder):
            # is a folder
            if os.path.isdir(path_folder + os.sep + f):
                abs_path = os.path.abspath(path_folder + os.sep + str(f))
                # ignore build folder
                if str(f) != "build":
                    self.update_name(abs_path, old_name, new_name)
            # is a file
            else:
                self.replace_text(path_folder + os.sep + str(f), old_name, new_name)

    def run(self):
        self.rename_app()
        self.repackage()


class Ios:
    def __init__(self, p):
        self.project = p
        self.project_file = p.project_path + os.sep + "ios" + \
            os.sep + "Runner.xcodeproj" + os.sep + "project.pbxproj"
        self.info_file = p.project_path + os.sep + "ios" + os.sep + "Runner" + os.sep + "Info.plist"

    def get_current_package_name(self):
        f = open(self.project_file, "r")
        file_text = f.read()
        f.close()
        for line in file_text.split("\n"):
            if "PRODUCT_BUNDLE_IDENTIFIER" in line.strip():
                return line.strip().split(" = ")[1].strip().replace(";", "").replace(".staging", "")
        return None

    def get_current_app_name(self):
        f = open(self.project_file, "r")
        file_text = f.read()
        f.close()
        for line in file_text.split("\n"):
            if "APP_DISPLAY_NAME" in line.strip():
                return line.strip().split(" = ")[1].strip().replace("\"", "")\
                    .replace(";", "").replace(" Staging", "").replace(" Production", "")
        return None

    def get_current_project_name(self):
        f = open(self.info_file, "r")
        file_text = f.read()
        f.close()
        file_text_list = file_text.split("\n")
        for index, line in enumerate(file_text_list):
            if "CFBundleName" in line.strip():
                return file_text_list[index + 1].strip().replace("<string>", "").replace("</string>", "")
        return None

    def replace_text_in_file(self, file_path, contain_text, old_text, new_text):
        f = open(file_path, "r")
        try:
            file_text = f.read()
            f.close()
            new_content = ""
            for line in file_text.split("\n"):
                if contain_text in line.strip():
                    new_content += "\n" + line.replace(old_text, new_text)
                else:
                    new_content += "\n" + line
            f = open(file_path, "w")
            f.write(new_content)
            f.close()
        except UnicodeDecodeError:  # This file is not text plain
            f.close()

    def repackage(self):
        old_package = self.get_current_package_name()
        # To follow iOS identifier rules, we need to replace underscore (_) with hyphen (-)
        # Read more: https://developer.apple.com/documentation/bundleresources/information_property_list/cfbundleidentifier
        new_package = self.project.new_package.replace("_", "-")
        if old_package is not None and old_package != new_package:
            self.replace_text_in_file(file_path=self.project_file, contain_text="PRODUCT_BUNDLE_IDENTIFIER",
                                      old_text=old_package, new_text=new_package)
            print("✅ Update package name for iOS successfully!")
        elif old_package is None:
            print("❌ Bundle identifier not found in Runner.xcodeproj/project.pbxproj!")
        else:
            print("Reusing old package name in iOS!")

    def rename_app(self):
        old_app_name = self.get_current_app_name()
        if old_app_name is not None and old_app_name != self.project.new_app_name:
            self.replace_text_in_file(file_path=self.project_file, contain_text="APP_DISPLAY_NAME",
                                      old_text=old_app_name, new_text=self.project.new_app_name)
            print("✅ Rename iOS app successully!")
        elif old_app_name is None:
            print("❌ Unable to find the old app name for iOS!")
            sys.exit()
        else:
            print("Reusing old app name in iOS!")

    def rename_project(self):
        old_project_name = self.get_current_project_name()
        if old_project_name is not None and old_project_name != self.project.new_project_name:
            self.replace_text_in_file(file_path=self.project_file, contain_text=old_project_name,
                                      old_text=old_project_name, new_text=self.project.new_project_name)
            self.replace_text_in_file(file_path=self.info_file, contain_text=old_project_name,
                                      old_text=old_project_name, new_text=self.project.new_project_name)
            print(f'✅ Renamed to {self.project.new_project_name} in iOS succesfully!')
        elif old_project_name is None:
            print("❌ Unable to update project name in iOS! Please check again!")
            sys.exit()
        else:
            print("Reusing old project name in iOS!")

    def run(self):
        self.rename_app()
        self.rename_project()
        self.repackage()


class Flutter:
    def __init__(self, p):
        self.project = p
        self.includes = ['lib', 'test', 'test_driver',
                         'integration_test', 'pubspec.yaml', 'README.md']

    def get_value_in_yaml_file(self, filename, key):
        yaml_file = self.project.project_path + os.sep + filename
        f = open(yaml_file, "r")
        file_text = f.read()
        f.close()
        for line in file_text.split("\n"):
            if key in line.strip():
                return line.strip().replace(key, "").strip()
        return None

    def get_value_in_pubspec_file(self, key):
        return self.get_value_in_yaml_file("pubspec.yaml", key)

    def get_value_in_build_file(self, key):
        return self.get_value_in_yaml_file("build.yaml", key)

    def get_old_project_name(self):
        return self.get_value_in_pubspec_file("name:")

    def get_current_project_version(self):
        return self.get_value_in_pubspec_file("version:")

	# TODO: Write unit test
    def get_json_serializable_field_rename(self):
        return self.get_value_in_build_file("field_rename:")

    def replace_text(self, path_file, old_text, new_text):
        f = open(path_file, "r")
        try:
            file_text = f.read()
            f.close()
            t = file_text.replace(old_text, new_text)
            f = open(path_file, "w")
            f.write(t)
            f.close()
        except UnicodeDecodeError:  # This file is not text plain
            f.close()

    def rename_project(self):
        old_project_name = self.get_old_project_name()
        if old_project_name is not None and old_project_name != self.project.new_project_name:
            for root in self.includes:
                path = os.path.join(self.project.project_path, root)
                if os.path.isdir(path):
                    for current, dirs, files in os.walk(path):
                        for name in files:
                            self.replace_text(os.path.join(current, name),
                                              old_project_name, self.project.new_project_name)
                else:
                    self.replace_text(path, old_project_name, self.project.new_project_name)
            print(f'✅ Renamed to {self.project.new_project_name} in Flutter succesfully!')
        elif old_project_name is None:
            print("❌ Unable to update project name in Flutter! Please check again!")
            sys.exit()
        else:
            print("Reusing old project name in Flutter!")

    def update_project_version(self):
        current_project_version = self.get_current_project_version()
        new_project_version = f"{self.project.app_version}+{self.project.build_number}"
        if current_project_version is not None and current_project_version != new_project_version:
            pubspec_file = self.project.project_path + os.sep + "pubspec.yaml"
            self.replace_text(pubspec_file, current_project_version, new_project_version)
            print(
                f'✅ Updated project version to {new_project_version} in Flutter succesfully!')
        elif current_project_version is None:
            print("❌ Unable to update project version in Flutter! Please check again!")
            sys.exit()
        else:
            print("Reusing old project version in Flutter!")

    def update_json_serializable_field_rename(self):
        current_field_rename = self.get_json_serializable_field_rename()
        new_field_rename = f'"{self.project.json_serializable.field_rename}"'
        if current_field_rename is not None and current_field_rename != new_field_rename:
            build_file = self.project.project_path + os.sep + "build.yaml"
            self.replace_text(build_file, current_field_rename, new_field_rename)
            print(
                f'✅ Updated json_serializable.field_rename to {new_field_rename} in build.yaml succesfully!')
        elif current_field_rename is None:
            print("❌ Unable to update json_serializable.field_rename in build.yaml! Please check again!")
            sys.exit()
        else:
            print("Reusing old json_serializable.field_rename in build.yaml!")

    def run(self):
        self.rename_project()
        self.update_project_version()
        self.update_json_serializable_field_rename()


def handleParameters():
    parser = argparse.ArgumentParser(
        description='The necessary arguments for initializing the project.'
    )
    parser.add_argument('--project_path',
                        type=str,
                        required=True,
                        help='The project path')
    parser.add_argument('--package_name',
                        type=str,
                        required=True,
                        help='The new package name')
    parser.add_argument('--app_name',
                        type=str,
                        required=True,
                        help='The app name')
    parser.add_argument('--project_name',
                        type=str,
                        required=True,
                        help='The project name')
    parser.add_argument('--app_version',
                        type=str,
                        default='0.1.0',
                        help='The app version')
    parser.add_argument('--build_number',
                        type=str,
                        default='1',
                        help='The build number')

    return parser.parse_args()


def validate_parameters(project):
    # Check the mandatory fields should not be empty
    if not project.new_package or not project.new_project_name or not project.new_app_name:
        print("❌ PACKAGE_NAME, PROJECT_NAME and APP_NAME are required. Please fill the missing variables and try again!")
        sys.exit()
    # Then validate them
    if re.match(r'^[a-z][a-z0-9_]*(\.[a-z0-9_]+)+[0-9a-z_]$', project.new_package) is None:
        print(
            f"❌ Invalid Package Name: {project.new_package} (needs to follow standard pattern `com.your.package`)")
        sys.exit()
    if re.match(r'^[a-z]*([a-z0-9_]+)*[a-z0-9]$', project.new_project_name) is None:
        print(
            f"❌ Invalid Project Name: {project.new_project_name} (needs to follow standard pattern `lowercase_with_underscores`)")
        sys.exit()
    if re.match(r'^[0-9]\d*(\.[0-9]\d*){1,2}\+[0-9]\d*$', f"{project.app_version}+{project.build_number}") is None:
        print(
            f"❌ Invalid App Version or Build Number: {project.app_version}+{project.build_number} (needs to follow standard pattern `app_version+build_number`. Eg: `1.0+1` or `0.1.0+1`)")
        sys.exit()

def move_project_to_root(project):
    cur_dir = os.getcwd()
    shutil.copytree(project.project_path, cur_dir, copy_function=shutil.move, dirs_exist_ok=True)

def clean_up(files):
    cur_dir = os.getcwd()
    for file in files:
        file_path = cur_dir + os.sep + file
        if os.path.exists(file_path):
            if (os.path.isdir(file_path)):
                shutil.rmtree(file_path)
            else:
                os.remove(file_path)

if __name__ == "__main__":
    try:
        args = handleParameters()

        project = Project(
            args.project_path,
            args.package_name,
            args.app_name,
            args.project_name,
            args.app_version,
            args.build_number
        )
        validate_parameters(project)

        if os.environ.get("CI") != "true":
            options = {
                'none': 'none',
                'kebab (kebab-case)': 'kebab',
                'snake (snake_case)': 'snake',
                'pascal (PascalCase)': 'pascal'
            }
            choice = enquiries.choose('Choose default json_serializable.field_rename: ', options.keys())
            project.json_serializable = JsonSerializable(options[choice])
        else:
            # Skip enquiries on CI
            project.json_serializable = JsonSerializable('snake')

        print(f"=> 🐢 Starting init {project.new_project_name} with {project.new_package}...")
        android = Android(project)
        android.run()
        ios = Ios(project)
        ios.run()
        flutter = Flutter(project)
        flutter.run()
        print('🤖 Generating project...')
        # Remove the `.github` folder to avoid redundant workflow
        clean_up(['.github'])
        move_project_to_root(project)
        clean_up(['template', 'LICENSE', 'Makefile'])
        print("=> 🚀 Done! Project is ready for the next development 🙌")
    except:
        print("❌ There is something wrong! Please try again.")
        sys.exit()
