#include <gtest/gtest.h>

#include "stl.hpp"
#include "src/db/persist.hpp"
#include "src/api.hpp"

#include <iostream>
#include <unistd.h>


using std::cout;
using std::endl;



TEST(api, savedItems1) {
    
    char cCurrentPath[FILENAME_MAX];
    
    if (!getcwd(cCurrentPath, sizeof(cCurrentPath)))
    {
        EXPECT_GT(0, 0);
    }
    
    printf ("===Current working directory is %s\r\n", cCurrentPath);
    
    shared_ptr<Play2_gen::Api> a = Play2_gen::Api::create("numbers.sqlite");
    
    std::vector<Play2_gen::Item> v = a->items("");
    
    EXPECT_GE(v.size(), 0);
}


TEST(api, savedItems2) {
    
    char cCurrentPath[FILENAME_MAX];
    
    if (!getcwd(cCurrentPath, sizeof(cCurrentPath)))
    {
        EXPECT_GT(0, 0);
    }
    
    printf ("===Current working directory is %s\r\n", cCurrentPath);

    shared_ptr<Play2_gen::Api> a = Play2_gen::Api::create("numbers.sqlite");
    
    std::vector<Play2_gen::Item> v = a->itemsGroupedByCount("");
    
    EXPECT_GE(v.size(), 0);
}
