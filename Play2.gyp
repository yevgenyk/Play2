{
  'targets': [
    {
      'target_name': 'libPlay2',
      'type': 'static_library',
      'conditions': [],
      'dependencies': [
        'deps/json11.gyp:json11',
        'deps/sqlite3.gyp:sqlite3',
        'deps/SQLiteCpp.gyp:SQLiteCpp',
      ],
      'sources': [
        # just automatically include all cpp and hpp files in src/ (for now)
        # '<!' is shell expand
        # '@' is to splat the arguments into list items
        "<!@(python glob.py src/ *.cpp *.hpp)",
      ],
      'include_dirs': [
        'include',
        'deps/SQLiteCpp/include',
      ],
      'all_dependent_settings': {
        'include_dirs': [
          'include',
          'deps',
        ],
      },
    },
    {
      'target_name': 'libPlay2_objc',
      'type': 'static_library',
      'conditions': [],
      'dependencies': [
        'deps/djinni/support-lib/support_lib.gyp:djinni_objc',
        'libPlay2',
      ],
      'sources': [
        '<!@(python glob.py objc *.mm *.h *.m)',
      ],
      'sources!': ['play.mm'],
      'include_dirs': [
        'include',
        'objc',
      ],
      'all_dependent_settings': {
        'include_dirs': [
          'include',
          'objc',
        ],
      },
    },
    {
      'target_name': 'libPlay2_android',
      'android_unmangled_name': 1,
      'type': 'shared_library',
      'dependencies': [
        'deps/djinni/support-lib/support_lib.gyp:djinni_jni',
        'libPlay2',
      ],
      'ldflags' : [ '-llog' ],
      'sources': [
        '<!@(python glob.py android/jni *.cpp *.hpp)',
        '<!@(python glob.py android/jni_gen *.cpp *.hpp)',
      ],
      'include_dirs': [
        'include',
        # --- I dont think these are being picked up, the proper include in cpp impl is #include "interface/network.hpp" vs #include "network.hpp"
        'src/interface',
      ],
      'all_dependent_settings': {
        'include_dirs': [
          'include',
          'src/interface',
        ],
      },
    },
    {
      'target_name': 'play_objc', # ---command line testing for mac os
      'type': 'executable',
      'dependencies': ['libPlay2_objc'],
      'cflags_cc!': [ '-Wextra' ],
      'xcode_settings': {
        'MACOSX_DEPLOYMENT_TARGET': '10.9', # OS X Deployment Target: 10.9
        'OTHER_CPLUSPLUSFLAGS!' : ['-Wextra'],
        'OTHER_CFLAGS': [
          "-stdlib=libc++"
        ],        
      },      
      # I'm not sure why you have to specify libc++ when you build this :(
      'libraries': [
        'libc++.a',
      ],
      'sources': [
        'objc/play.mm',
      ],
    },
    {
      'target_name': 'test',
      'type': 'executable',
      'dependencies': [
        'libPlay2',
        'deps/gtest.gyp:gtest',
      ],
      'cflags_cc!': [ '-Wextra' ],
      'xcode_settings': {
        'MACOSX_DEPLOYMENT_TARGET': '10.9', # OS X Deployment Target: 10.9
        'OTHER_CPLUSPLUSFLAGS!' : ['-Wextra'],
        'OTHER_CFLAGS': [
          "-std=c++11",
          "-stdlib=libc++"
        ],        
      },
      'include_dirs': [
        '.',
        'test',
      ],
      'sources': [
        '<!@(python glob.py test *.cpp *.hpp)',
      ]
    },
  ],
}
