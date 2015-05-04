#include <gtest/gtest.h>

#include "stl.hpp"
#include "src/db/persist.hpp"
#include <iostream>


using std::cout;
using std::endl;


TEST(SQLiteCpp, findWordsTest1) {
    
    Play2::Persist db(":memory:");
    

    EXPECT_EQ(db.test(), 1);
    
//    vector<github::User> users;
//    db.findWords(users, "", "", 0, INT16_MAX);
    
}
