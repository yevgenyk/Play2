#include "persist.hpp"
#include <SQLiteCpp/SQLiteCpp.h>

using json11::Json;

namespace Play2 {

namespace {
} //anon namespace

Persist::Persist(const string& db_path)
{
    this->mDbFullPath = db_path;
}
    
int Persist::test() {
    
    int count = 0;
    string name = "my_table";
    string sql = "CREATE TABLE " + name + " (table_id INTEGER, name TEXT NOT NULL, data BLOB, price FLOAT DEFAULT 1.4, PRIMARY KEY (table_id))";
    

    SQLite::Database db(mDbFullPath, SQLITE_OPEN_READWRITE);
    
    SQLite::Statement query(db, sql);
    query.exec();
    
    SQLite::Statement queryInsert(db, "insert into " + name + " (table_id,name) values (123, 'qwewe')");
    queryInsert.exec();
    
    SQLite::Statement sel(db, "select * from " + name + "");
    while (sel.executeStep())
    {
        count ++ ;
    }

    return count;
}

} // end namespace Play2
