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
        def add_campaigns(payload)
          post("Campaigns", payload)
        end

        def get_campaigns_by_account_id(payload)
          post("Campaigns/QueryByAccountId", payload)
        end

        def get_campaigns_by_ids(payload)
          post("Campaigns/QueryByIds", payload)
        end

        def update_campaigns(payload)
          put("Campaigns", payload)
        end

        def delete_campaigns(payload)
          delete("Campaigns", payload)
        end

        def add_budgets(payload)
          post("Budgets", payload)
        end

        def update_budgets(payload)
          put("Budgets", payload)
        end

        def delete_budgets(payload)
          delete("Budgets", payload)
        end

        def add_ad_groups(payload)
          post("AdGroups", payload)
        end

        def update_ad_groups(payload)
          put("AdGroups", payload)
        end

        def delete_ad_groups(payload)
          delete("AdGroups", payload)
        end

        def add_ads(payload)
          post("Ads", payload)
        end

        def add_responsive_search_ads(ad_group_id:, headlines:, descriptions:, final_urls:, path1: nil, path2: nil, status: "Paused")
          add_ads(
            ad_group_id: ad_group_id,
            ads: [{
              type: "ResponsiveSearch",
              status: status,
              final_urls: final_urls,
              headlines: headlines.map { |text| {asset: {type: "TextAsset", text: text}} },
              descriptions: descriptions.map { |text| {asset: {type: "TextAsset", text: text}} },
              path1: path1,
              path2: path2
            }]
          )
        end

        def update_ads(payload)
          put("Ads", payload)
        end

        def delete_ads(payload)
          delete("Ads", payload)
        end

        def add_keywords(payload)
          post("Keywords", payload)
        end

        def update_keywords(payload)
          put("Keywords", payload)
        end

        def delete_keywords(payload)
          delete("Keywords", payload)
        end

        def add_campaign_criterions(payload)
          post("CampaignCriterions", payload)
        end

        def delete_campaign_criterions(payload)
          delete("CampaignCriterions", payload)
        end

        def set_shared_entity_associations(payload)
          post("SharedEntityAssociations/Set", payload)
        end

        def get_shared_entity_associations_by_entity_ids(payload)
          post("SharedEntityAssociations/QueryByEntityIds", payload)
        end

        def add_ad_extensions(payload)
          post("AdExtensions", payload)
        end

        def get_ad_extension_ids_by_account_id(payload)
          post("AdExtensionIds/QueryByAccountId", payload)
        end

        def get_ad_extensions_by_ids(payload)
          post("AdExtensions/QueryByIds", payload)
        end

        def get_ad_extensions_associations(payload)
          post("AdExtensionsAssociations/Query", payload)
        end

        def set_ad_extensions_associations(payload)
          post("AdExtensionsAssociations/Set", payload)
        end

        def delete_ad_extensions_associations(payload)
          delete("AdExtensionsAssociations", payload)
        end

        def delete_ad_extensions(payload)
          delete("AdExtensions", payload)
        end

        def add_conversion_goals(payload)
          post("ConversionGoals", payload)
        end

        def get_conversion_goals_by_ids(payload)
          post("ConversionGoals/QueryByIds", payload)
        end

        def get_conversion_goals_by_tag_ids(payload)
          post("ConversionGoals/QueryByTagIds", payload)
        end

        def update_conversion_goals(payload)
          put("ConversionGoals", payload)
        end

        def add_uet_tags(payload)
          post("UetTags", payload)
        end

        def get_uet_tags_by_ids(payload)
          post("UetTags/QueryByIds", payload)
        end

        def update_uet_tags(payload)
          put("UetTags", payload)
        end

        def get_ad_groups_by_ids(payload)
          post("AdGroups/QueryByIds", payload)
        end

        def get_ad_groups_by_campaign_id(payload)
          post("AdGroups/QueryByCampaignId", payload)
        end

        def get_ads_by_ad_group_id(payload)
          post("Ads/QueryByAdGroupId", payload)
        end

        def get_budgets_by_ids(payload)
          post("Budgets/QueryByIds", payload)
        end

        def get_campaign_criterions_by_ids(payload)
          post("CampaignCriterions/QueryByIds", payload)
        end

        def get_keywords_by_ad_group_id(payload)
          post("Keywords/QueryByAdGroupId", payload)
        end

        def get_keywords_by_editorial_status(payload)
          post("Keywords/QueryByEditorialStatus", payload)
        end

        def get_keywords_by_ids(payload)
          post("Keywords/QueryByIds", payload)
        end

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

        def delete_shared_entities(payload)
          delete("SharedEntities", payload)
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

        def get_shared_entities_by_account_id(payload)
          post("SharedEntities/QueryByAccountId", payload)
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
