git rm -rf deps/optional
git rm -rf deps/djinni
git rm -rf deps/json11
git rm -rf deps/SQLiteCpp

git submodule add https://github.com/akrzemi1/Optional.git deps/optional
git submodule add https://github.com/dropbox/djinni.git deps/djinni
git submodule add https://github.com/libmx3/json11.git deps/json11
git submodule add https://github.com/SRombauts/SQLiteCpp.git deps/SQLiteCpp
