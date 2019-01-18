module BingAdsRubySdk
  module Services
    class CampaignManagement < Base

      def get_campaigns_by_account_id(message)
        call_wrapper(__method__, message, :campaigns, :campaign)
      end

      def get_budgets_by_ids(message= {})
        call_wrapper(__method__, message, :budgets, :budget)
      end

      def add_ad_extensions(message)
        call(__method__, message)
      end

      def get_ad_extension_ids_by_account_id(message)
        call_wrapper(__method__, message, :ad_extension_ids)
      end

      def add_shared_entity(message)
        call(__method__, message)
      end

      def get_shared_entities_by_account_id(message)
        call_wrapper(__method__, message, :shared_entities, :shared_entity)
      end

      def get_uet_tags_by_ids(message = {})
        call_wrapper(__method__, message, :uet_tags, :uet_tag)
      end

      def add_uet_tags(message)
        call(__method__, message)
      end

      def update_uet_tags(message)
        call(__method__, message)
      end

      def get_conversion_goals_by_ids(message)
        call_wrapper(__method__, message, :conversion_goals, :conversion_goal)
      end

      def add_conversion_goals(message)
        call(__method__, message)
      end

      def update_conversion_goals(message)
        call(__method__, message)
      end

      def set_ad_extensions_associations(message)
        call(__method__, message)
      end

      def get_ad_extensions_associations(message)
        wrap_array(
          call(__method__, message)
            .dig(:ad_extension_association_collection, :ad_extension_association_collection)
            .first
            .dig(:ad_extension_associations, :ad_extension_association)
        )
      rescue
        []
      end

      def get_shared_entity_associations_by_entity_ids(message)
        call_wrapper(__method__, message, :associations, :shared_entity_association)
      end

      def self.service
        :campaign_management
      end
    end
  end
end