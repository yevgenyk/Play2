#include <gtest/gtest.h>

#include "stl.hpp"
#include "src/api.hpp"

#include <iostream>
#include <string>
#include <fstream>
#include <streambuf>
#include <time.h>

using std::cout;
using std::endl;


TEST(api, updateItems1) {

    std::ifstream t("numbers.json");
    std::string json((std::istreambuf_iterator<char>(t)),
                    std::istreambuf_iterator<char>());
    
    time_t seconds_past_epoch = time(0);

    shared_ptr<Play2_gen::Api> a = Play2_gen::Api::create("numbers.sqlite");
    
    int count = a->updateItems(json, seconds_past_epoch);
    
    EXPECT_GT(count, 0);
}

