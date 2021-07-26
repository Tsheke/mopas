# Modules Packaging Script - mopas

This is a set of scripts for packaging/updating modules/plugins by using git submodule feature. Based on the `gitmodules` file provided, mopas will clone the core project and modules/plugins even if they were not added yet as submodules.

One can use it for moodle open source LMS (https://github.com/moodle/moodle) and plugins.

## How to use

- Edit mopas.sh to set the url of the core repository
- Provide a `gitsubmodule` that contains the plugins you need to add to the core.
>- mopas supports a standard `gitsubmodule` and somme additional features:
>>- branch: clone specified branc
>>- tag: clone given tag
>>- commit: clone specific commit 
- Run the script
- It will make a fresh clone of the core repository et clone also plugins even if they were not added previously as submodules to the project.
