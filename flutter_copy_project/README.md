# Copying flutter project


>Copy whole project to another. Enter the conversion keyword to convert it.
<br>

## How to copy flutter project
---
**1. get this project to your folder**
```sh
git clone "https://github.com/enoosoft/flutter_copy_project.git"
```
<br>

**2. Run fcpy.dart in root directory with arguments**
```sh
# Windows
dart bin/fcpy.dart --converter to-be.txt --source C:\Works\smmy --destination C:\Works\dmmy

# iOS
dart bin/fcpy.dart --converter to-be.txt --source  ~/Works/smmy --destination  ~/Works/dmmy
```
<br>

**3. Go to copied project root, get pub and install Pods**
```sh
# Windows, iOS
flutter clean
flutter pub get

# iOS
cd ios
pod install
```
<br>



 - **Arguments**

Arguments|Example|Description
|--|--|--|
converter|`to-be.txt`|Define conversion rules
source|~/Works/existing_project|Source template project folder
destination|~/Works/new_project|New project folder to create
<br>

- **How converter(`to-be.txt`) file works**

Basically, replace the keyword contained in the source file.<br> 
Conversion rules are expressed as `before` -> `after`<br> 
Define conversion rules what ever you need.<br> 
eg. **`package name`**, **`app name`**, **`package directory`**, **`Admob IDs`**, etc.

```sh
# app name or keyword
smmy -> dmmy

# package name
com.example.smmy->com.example.dmmy

# package directory(windows) 
# start with slash and do not end with slash  
\com\example\smmy->\com\example\dmmy

# package directory(ios) 
# start with slash and do not end with slash
/com/example/smmy->/com/example/dmmy

# Admob IDs
ca-app-pub-ADMOBaXXX~XXXXXXXXXXXX->ca-app-pub-ad_app_id~XXXXXXXXXXXX
ca-app-pub-ADMOBbXXX/XXXXXXXXXXXX->ca-app-pub-ad_banner_id~XXXXXXXXXXXX
ca-app-pub-ADMOBcXXX/XXXXXXXXXXXX->ca-app-pub-ad_intstl_id~XXXXXXXXXXXX
 ```
`package directory` converts and creates a folder structure that creates a directory with a package name, such as `Java`, `Kotlin`.

## Updates
---

* 0.0.1 
  * Create project 2021-08-22


## About
---

* Developer: EnooSoft
* Email: [as.enoosoft@gmail.com](mailto:as.enoosoft@gmail.com)
* Last modify: 2022-03-03
