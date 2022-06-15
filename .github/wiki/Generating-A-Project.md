# Generating a project

## The available configs
| Parameter name | Is mandatory | Description                                                                     |
| :------------- | :----------: | :------------------------------------------------------------------------------ |
| PACKAGE_NAME   |     Yes      | The application package name. The naming convention follows `com.your.package`  |
| PROJECT_NAME   |     Yes      | The application project name. The naming convention follows `your_project_name` |
| APP_NAME       |     Yes      | The application name.                                                           |
| APP_VERSION    |      No      | The app version that is set when initialize the project. Default is `0.1.0`     |
| BUILD_NUMBER   |      No      | The build number that is set when initialize the project. Default is `1`        |
| json_serializable.field_rename   |      No      | Defines the automatic naming strategy when converting class field names into JSON map keys. <br/>Available options: <br/> - `none`: Use the field name without changes.<br/> - `kebab`: Encodes a field named `kebabCase` with a JSON key `kebab-case`.<br/> - `snake`: Encodes a field named `snakeCase` with a JSON key `snake_case`.<br/> - `pascal`: Encodes a field named `pascalCase` with a JSON key `PascalCase`.        |
