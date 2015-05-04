all: mac ios android

clean:
	-rm -rf build/
	-rm -rf deps/build/
	-rm -rf mac_xcode/
	-rm -rf build_ios/
	-rm -rf obj/
	-rm -rf libs/
	-rm GypAndroid.mk
	-rm *.target.mk
	-rm deps/*.target.mk
	-rm -rf test_ldb
	-rm test.sqlite
	-rm play

gyp: ./deps/gyp

./deps/gyp:
	git clone --depth 1 https://chromium.googlesource.com/external/gyp.git ./deps/gyp

./deps/djinni:
	git submodule update --init

djinni-output-temp/gen.stamp Play2.cidl:
	./run_djinni.sh

djinni: djinni-output-temp/gen.stamp Play2.cidl

# instruct gyp to build using the "xcode" build generator, also specify the OS
# (so we can conditionally compile using that var later)
mac_xcode/Play2.xcodeproj: deps/gyp deps/json11 Play2.gyp djinni
	deps/gyp/gyp Play2.gyp -DOS=mac --depth=. -f xcode --generator-output=./mac_xcode -Icommon.gypi

build_ios/Play2.xcodeproj: deps/gyp deps/json11 Play2.gyp djinni
	deps/gyp/gyp Play2.gyp -DOS=ios --depth=. -f xcode --generator-output=./build_ios -Icommon.gypi

GypAndroid.mk: deps/gyp deps/json11 Play2.gyp djinni
	ANDROID_BUILD_TOP=dirname $(which ndk-build) deps/gyp/gyp --depth=. -f android -DOS=android --root-target libPlay2_android -Icommon.gypi Play2.gyp

xb-prettifier := $(shell command -v xcpretty >/dev/null 2>&1 && echo "xcpretty -c" || echo "cat")

mac: mac_xcode/Play2.xcodeproj
	xcodebuild -project mac_xcode/Play2.xcodeproj -configuration Release -target libPlay2_objc | ${xb-prettifier}

ios: build_ios/Play2.xcodeproj
	xcodebuild -project build_ios/Play2.xcodeproj -configuration Release -target libPlay2_objc | ${xb-prettifier}

androidJava: 
	cd app-android && ./gradlew app:assembleDebug && cd ..

androidNdk: GypAndroid.mk
	cd app-android && ./gradlew app:ndkBuild && cd ..

android: androidNdk androidJava	

copyInput: 
	mkdir -p ./build/Debug
	cp ./numbers.sqlite ./build/Debug #no longer needed. tests are being ran from current folder
	cp ./numbers.json ./build/Debug

testsCompile: copyInput mac_xcode/Play2.xcodeproj
	xcodebuild -project mac_xcode/Play2.xcodeproj -configuration Debug -target test
	xcodebuild -project mac_xcode/Play2.xcodeproj -configuration Debug -target play_objc	

tests: testsCompile
	./build/Debug/test
	./build/Debug/play_objc

cleanup_gyp: ./deps/gyp Play2.gyp common.gypi
	deps/gyp/tools/pretty_gyp.py deps/gtest.gyp > gtest_temp.gyp && mv gtest_temp.gyp deps/gtest.gyp
	deps/gyp/tools/pretty_gyp.py deps/json11.gyp > json11_temp.gyp && mv json11_temp.gyp deps/json11.gyp
	deps/gyp/tools/pretty_gyp.py deps/sqlite3.gyp > sqlite3_temp.gyp && mv sqlite3_temp.gyp deps/sqlite3.gyp
	deps/gyp/tools/pretty_gyp.py Play2.gyp > Play2_temp.gyp && mv Play2_temp.gyp Play2.gyp
	deps/gyp/tools/pretty_gyp.py common.gypi > common_temp.gypi && mv common_temp.gypi common.gypi

.PHONY: djinni
