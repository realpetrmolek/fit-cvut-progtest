# AutoTest

## What this does
AutoTest is a tool which automatically tests your program, like a small progtest.
Currently it supports:
- Compiler errors and warnings
- Sample data testing
- Fuzzing with [radamsa](https://gitlab.com/akihe/radamsa)

I also included a `crashme.c` program with sample data `crashme.tgz`. This program is **intended** to crash and throw errors!


## How to use:
run `./autotest.sh`.
It will automatically download all dependencies.

After dependencies are downloaded, put in your source code and sample data (can be downloaded from progtest) and AutoTest will do the rest.
Here is an example output of a program which works as intended (no errors):
![alt text](https://raw.githubusercontent.com/realpetrmolek/fit-cvut-progtest/main/AutoTest/autotest_screenshot.png "AutoTest")
