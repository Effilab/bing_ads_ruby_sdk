# frozen_string_literal: true

require "bing_ads_ruby_sdk/services/json/base"

module BingAdsRubySdk
  module Services
    module Json
      # Helper class containing some useful helper methods, but not all the ones available
      # on the API. You can still use the #post and #delete methods to make requests to the API.
      # For information the API documentation can be found here:
      #   https://learn.microsoft.com/en-us/advertising/campaign-management-service/
      class CampaignManagement < Base
        # @param payload [Hash]
        # @option payload [Hash] :shared_entity
        # @option payload [Array<Hash>] :list_items
        # @option payload [String] :shared_entity_scope
        # @example
        #  bing_api.campaign_management.add_shared_entity(
        #    shared_entity: {
        #      name: "List Name",
        #      type: "PlacementExclusionList"
        #    },
        #    shared_entity_scope: "Customer"
        #  )
        # @return [Hash]
        # @example
        # {
        #   SharedEntityId: "123456789",
        #   ListItemIds: [],
        #   PartialErrors: []
        # }
        def add_shared_entity(payload)
          post("SharedEntity", payload)
        end

        # @param payload [Hash]
        # @example:
        # bing_api.campaign_management.get_shared_entities(
        #  shared_entity_scope: "Customer",
        #  shared_entity_type: "PlacementExclusionList"
        # )
        # @return [Hash]
        # @example:
        # {
        #   SharedEntities: [
        #     {
        #       ItemCount: 90,
        #       Id: "123456789",
        #       Name: "Name of the list",
        #       Type: "PlacementExclusionList",
        #       AssociationCount: 12345,
        #       ForwardCompatibilityMap: []
        #     },
        #     ...
        #   ]
        # }
        def get_shared_entities(payload)
          post("SharedEntities/Query", payload)
        end

        def get_list_items_by_shared_list(payload)
          post("ListItems/QueryBySharedList", payload)
        end

        def add_list_items_to_shared_list(payload)
          post("ListItems", payload)
        end

        def delete_list_items_from_shared_list(payload)
          delete("ListItems", payload)
        end
      end
    end
  end
end
