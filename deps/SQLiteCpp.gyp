{ 'targets': [
    {
      'target_name': 'SQLiteCpp',
      'type': 'static_library',
      'xcode_settings': {
          'DEAD_CODE_STRIPPING': 'YES',
          'SKIP_INSTALL': 'YES',
      },
      'sources': [
        "SQLiteCpp/src/Column.cpp",      
        "SQLiteCpp/src/Database.cpp",
        "SQLiteCpp/src/Statement.cpp",
        "SQLiteCpp/src/Transaction.cpp",
      ],
      'cflags': [
      ],
      'all_dependent_settings': {
        'include_dirs': [
          '.',
          './sqlite3',
        ]
      },
      'include_dirs': [
        '.',
        './sqlite3',      
        'SQLiteCpp/include',
      ],
    },
  ]
}
