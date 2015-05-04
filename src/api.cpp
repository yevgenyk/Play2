#include "api.hpp"
#include "stl.hpp"
#include <SQLiteCpp/SQLiteCpp.h>
#include "interface/network.hpp"
#include "interface/network_params.hpp"

using Play2::Api;
using json11::Json;


shared_ptr<Play2_gen::Api> Play2_gen::Api::create(const string& path)
{
    return make_shared<Play2::Api>(path);
}

Api::Api(
    const string& db_path
) :
    mdbFile (db_path)
{
//YK: This statement does nothing. It makes this project link with sqlite3.
//If we don't make direct calls the make is not smart enough to figure out dependency chain and there may be linker errors failing to find sqlite3
   sqlite3_free(0);
}

std::vector<Play2_gen::Item> Api::items(const std::string & filter)
{
    std::vector<Play2_gen::Item> a;
    
    SQLite::Database db(mdbFile, SQLITE_OPEN_READONLY);
    
    SQLite::Statement sel(db, "select * from numbers order by time desc");
    while (sel.executeStep())
    {
        int64_t id = sel.getColumn(0);
        int64_t value = sel.getColumn(1);
        sqlite3_int64 time = sel.getColumn(2);
        std::experimental::optional<std::string> v;
        Play2_gen::Item a0(id, value, v, time, 0);
        a.push_back(a0);
    }
    
    return a;
}

std::vector<Play2_gen::Item> Api::itemsGroupedByCount(const std::string & filter)
{
    std::vector<Play2_gen::Item> a;
    
    SQLite::Database db(mdbFile, SQLITE_OPEN_READONLY);
    
    SQLite::Statement sel(db, "select value, count(*), time from numbers group by value order by count(value) desc");
    while (sel.executeStep())
    {
        int64_t value = sel.getColumn(0);
        int32_t count = sel.getColumn(1);
        sqlite3_int64 time = sel.getColumn(2);
        std::experimental::optional<std::string> v;
        Play2_gen::Item a0(0, value, v, time, count);
        a.push_back(a0);
    }
    
    return a;
}

int32_t Api::updateItems(const std::string & json, int64_t stamp)
{
    int count = 0;
    
    vector<Play2_gen::Item> items;
    string error;
    auto json_response = Json::parse(json, error);
    if (!error.empty()) {
        throw error;
    } else {
        if (json_response.is_object()) {
            auto result = json_response["result"];
            if (result.is_object()) {
                auto random = result["random"];
                if (random.is_object()) {
                    auto data = random["data"];
                    if (data.is_array()) {
                        for (const auto& item : data.array_items()) {
                            int64_t value = item.number_value();
                            std::string name;
                            Play2_gen::Item i(0, value, std::experimental::nullopt, 0, 0);
                            items.emplace_back( i );
                        }
                    }
                }
            }
        }
    }

    
    SQLite::Database db(mdbFile, SQLITE_OPEN_READWRITE);

    for (const auto& user : items) {
        SQLite::Statement insert(db, "insert into numbers (value, time) values (?, ?)");
        insert.bind(1, user.value);
        insert.bind(2, stamp);
        insert.exec();
        count ++ ;
    }
    
    return count;
}

int32_t Api::updateItemsFromList(const std::vector<Play2_gen::Item> & new_items, int64_t stamp)
{
    int count = 0;
    
    SQLite::Database db(mdbFile, SQLITE_OPEN_READWRITE);
    
    for (const auto& user : new_items) {
        SQLite::Statement insert(db, "insert into numbers (value, time) values (?, ?)");
        insert.bind(1, user.value);
        insert.bind(2, stamp);
        insert.exec();
        count ++ ;
    }
    
    return count;
}

Play2_gen::ParsedItems Api::download(const std::unordered_map<Play2_gen::network_params, std::string> & params, const std::shared_ptr<Play2_gen::Network> & impl) {

    Play2_gen::HttpResponse response = impl->download(params);
    
    std::vector<Play2_gen::Item> items;
    if (response.http_code != 200) {
        Play2_gen::ParsedItems e(response.http_code, response.error,items);
        return e;
    }
    
    string error;
    auto json_response = Json::parse(response.data, error);
    if (!error.empty()) {
        throw error;
    } else {
        if (json_response.is_object()) {
            auto result = json_response["result"];
            if (result.is_object()) {
                auto random = result["random"];
                if (random.is_object()) {
                    auto data = random["data"];
                    if (data.is_array()) {
                        for (const auto& item : data.array_items()) {
                            int64_t value = item.number_value();
                            std::string name;
                            Play2_gen::Item i(0, value, std::experimental::nullopt, 0, 0);
                            items.emplace_back( i );
                        }
                    }
                }
            }
        }
    }
    
    //TEST:
    //sleep(20);

    Play2_gen::ParsedItems values(response.http_code, response.error,items);
    
    return values;
}

