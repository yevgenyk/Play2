#pragma once
#include "stl.hpp"
#include <json11/json11.hpp>
#include "interface/api.hpp"

namespace Play2 {

class Api final : public Play2_gen::Api {
  public:
    Api(
        const string & dbFile
    );

    Play2_gen::ParsedItems download(const std::unordered_map<Play2_gen::network_params, std::string> & params, const std::shared_ptr<Play2_gen::Network> & impl);
    std::vector<Play2_gen::Item> items(const std::string & filter);
    std::vector<Play2_gen::Item> itemsGroupedByCount(const std::string & filter);
    int32_t updateItems(const std::string & json, int64_t stamp);
    int32_t updateItemsFromList(const std::vector<Play2_gen::Item> & new_items, int64_t stamp);

  protected:

    std::string mdbFile;
};

}
