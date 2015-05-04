#pragma once
#include "../stl.hpp"

namespace Play2 {

class Persist  {
  public:
    Persist(const string& db_path);
    
    int test();
    
    protected:
    std::string mDbFullPath;
};

}
