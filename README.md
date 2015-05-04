## Play2
Play2 is a template for creating iOS and Android apps sharing a common non-UI core.

Base your new iOS and Android apps off Play2 infrastructure to maximize code reuse and save development time.

You get the maximum benefit if you develop app on both platforms at the same time. 
About 50% of app's functionality (conceptually) can be reused, but your milage may vary.

### Technology
The project is based on several open source technologies that work together to create a tremendous value.

* [djinni](https://github.com/dropbox/djinni) from Dropbox

* [gyp](https://code.google.com/p/gyp/) from Google

* [gtest](https://code.google.com/p/googletest/) from Google

### Credits
Play2 is a rouge fork of [mx3](https://github.com/libmx3/mx3) by Steven Kabbes.
The folder and makefile structure is mostly unchanged, but dependencies and code of the actual starter apps have diverged significantly.

### Toolchain
* Latest Xcode with [Command Line Tools](https://developer.apple.com/xcode/downloads/)
* [Android NDK](https://developer.android.com/tools/sdk/ndk)

### Starter apps
The bundled starter iOS and Android apps are type of "pull to refresh" that display results in UITableView and ListView.
The functionality where code is shared across platforms:

* Making HTTPS request and downloading JSON response
* Unpacking JSON response and saving it into sqlite3 database
* Pulling data from local sqlite3 database in form of a local API
* Some business logic, mostly around data

### Unit tests
Since the focus of this project is sharing of non-UI code across platforms the opportunities for useful unit tests are abound. The project includes some fairly useful starter unit tests as well as Xcode and Jenkins friendly options to invoke them.

### Getting started
1. Run `git clone https://github.com/yevgenyk/Play2.git`
1. Run `cd Play2`
1. Run `sh subs.sh` to set up and pull submodules
1. Optionally run `sudo gem install xcpretty` to beautify the output of `xcodebuild` 
1. Run `make mac`	.
1. Run `make tests`	.
	This builds and runs a series of *gtest* unit tests that are ran inside mac shell.
	The last test downloads some JSON data from a remote site, updates a local database and pulls back the results. This means every time you run it the final
	`Updated count` value will be different.
1. Run `make ios`
1. The iOS app in app-ios should run, pick the target called 'app'


If you have gotten this far you should proceed to the actual starter apps!


### iOS app
1.	Run `make ios` to generate objective-c proxies used by the actual app.
1.	The actual app is located in `app-ios/app` folder. It should just load and run. Pull to refresh to see numbers change!
	Updated numbers will show up in blue!


### Android app
1.	Make sure you have [Android NDK](https://developer.android.com/tools/sdk/ndk) installed on your mac. Make sure its folder is in PATH.
Something like this:
`export PATH=$PATH:/Users/yevgeny/android-ndk-r10d
export ANDROID_NDK=/Users/yevgeny/android-ndk-r10d`
1. Run `ndk-build` and you should see this error `Android NDK: Could not find application project directory !`. This is what you want.
Run `make android` to build the example android application
1. Run `make androidNdk` to build JNI libraries. This will produce the shared shared libraries needed by the Android app.
1. Run `make androidJava` to build Android app using gradle. The app is located in `app-android` folder. You can open this project in Android Studio by choosing `app-android/app` folder and importing it as gradle project.


### Make targets
* `make clean` - cleans all generated files
* `make tests` - runs the unit tests
* `make ios` - builds a static library for ios
* `make mac` - builds a static library for mac
* `make androidNdk` - builds JNI shared library for the Android app
* `make androidJava` - builds the Android app using the `app-android/app/build.gradle` script

### Where things are

* Play2.gyp - gyp definition file which spcifies targets and dependencies
* Application.mk - the android make file, you should modify this file to specify things like APP_ABI which is curently set only to x86 to speed up compilation
* Makefile - helper for interacting with gyp, and using command line builds (no xcode!!)
* deps/ - third party dependencies
* objc/ - objective-c code for iOS/OSX implementation, and also generated objective-c files
* src/ - shared implementation code
* test/ - gtest tests


### Screenshots

![iOS](https://raw.githubusercontent.com/yevgenyk/Play2/master/deps/screens/ios.png)

![Android](https://github.com/yevgenyk/Play2/blob/master/deps/screens/android2.png)

