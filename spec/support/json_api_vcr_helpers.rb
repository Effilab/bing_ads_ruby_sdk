# frozen_string_literal: true

require "date"
require "json"
require "securerandom"

RSpec.shared_context "json api with vcr" do
  let(:account_id) { ENV.fetch("BING_SANDBOX_ACCOUNT_ID") }
  let(:customer_id) { ENV.fetch("BING_SANDBOX_CUSTOMER_ID") }
  let(:api) do
    BingAdsRubySdk::JsonApi.new(
      developer_token: ENV.fetch("BING_DEVELOPER_TOKEN"),
      client_id: ENV.fetch("BING_CLIENT_ID"),
      client_secret: ENV.fetch("BING_CLIENT_SECRET"),
      oauth_store: BingAdsRubySdk::OAuth2::FsStore.new(ENV.fetch("BING_STORE_FILENAME", "sandbox_token.json")),
      version: :v13,
      environment: :production
    ).tap do |client|
      client.set_customer(customer_id: customer_id, account_id: account_id)
    end
  end

  def use_json_api_cassette(name, &block)
    VCR.use_cassette("JSON_API/#{name}", &block)
  end

  def exercise_json_endpoint(service_name, method_name, payload = {})
    response = api.public_send(service_name).public_send(method_name, payload)
    expect(response).to be_a(Hash)
  end

  def with_paused_campaign
    with_campaign do |campaign_id|
      yield campaign_id
    end
  end

  def with_campaign
    campaign_name = "SDK VCR Campaign #{SecureRandom.hex(4)}"
    response = api.campaign_management.add_campaigns(
      account_id: account_id,
      campaigns: [{
        name: campaign_name,
        daily_budget: 1,
        budget_type: "DailyBudgetStandard",
        time_zone: "BrusselsCopenhagenMadridParis",
        status: "Paused"
      }]
    )
    campaign_id = response.fetch(:CampaignIds).first

    yield campaign_id, response, campaign_name
  ensure
    if campaign_id && !@campaign_deleted
      api.campaign_management.delete_campaigns(
        account_id: account_id,
        campaign_ids: [campaign_id]
      )
    end
  end

  def with_campaign_and_ad_group
    ad_group_id = nil
    with_campaign do |campaign_id|
      response = api.campaign_management.add_ad_groups(
        campaign_id: campaign_id,
        ad_groups: [{name: "SDK VCR Ad Group #{SecureRandom.hex(4)}", status: "Paused", language: "English"}]
      )
      ad_group_id = response.fetch(:AdGroupIds).first

      begin
        yield campaign_id, ad_group_id
      ensure
        if ad_group_id && !@ad_group_deleted
          api.campaign_management.delete_ad_groups(
            campaign_id: campaign_id,
            ad_group_ids: [ad_group_id]
          )
        end
      end
    end
  end

  def with_budget
    budget_name = "SDK VCR Budget #{SecureRandom.hex(4)}"
    response = api.campaign_management.add_budgets(
      budgets: [{name: budget_name, amount: 1, budget_type: "DailyBudgetStandard"}]
    )
    budget_id = response.fetch(:BudgetIds).first

    yield budget_id, response
  ensure
    unless @budget_deleted
      api.campaign_management.delete_budgets(budget_ids: [budget_id]) if budget_id
    end
  end

  def with_campaign_criterion
    with_campaign do |campaign_id|
      response = api.campaign_management.add_campaign_criterions(
        campaign_criterions: [{
          campaign_id: campaign_id,
          criterion: {type: "LocationCriterion", location_id: 190},
          status: "Active",
          type: "NegativeCampaignCriterion"
        }],
        criterion_type: "Targets"
      )
      criterion_id = response.fetch(:CampaignCriterionIds).first

      begin
        yield criterion_id, campaign_id, response
      ensure
        unless @criterion_deleted
          api.campaign_management.delete_campaign_criterions(
            campaign_criterion_ids: [criterion_id],
            campaign_id: campaign_id,
            criterion_type: "Targets"
          )
        end
      end
    end
  end

  def with_shared_list
    list_name = "SDK VCR Shared List #{SecureRandom.hex(4)}"
    response = api.campaign_management.add_shared_entity(
      shared_entity: {name: list_name, type: "NegativeKeywordList"},
      list_items: [{type: "NegativeKeyword", text: "sdk-vcr-shared-keyword", match_type: "Exact"}],
      shared_entity_scope: "Account"
    )
    shared_entity_id = response.fetch(:SharedEntityId)

    yield shared_entity_id, response
  ensure
    unless @shared_entity_deleted
      if shared_entity_id
        api.campaign_management.delete_shared_entities(
          shared_entities: [{id: shared_entity_id, type: "NegativeKeywordList"}],
          shared_entity_scope: "Account"
        )
      end
    end
  end

  def with_ad_extension(extension: {type: "CalloutAdExtension", text: "SDK VCR Callout"})
    response = api.campaign_management.add_ad_extensions(
      account_id: account_id,
      ad_extensions: [extension]
    )
    extension_id = response.fetch(:AdExtensionIdentities).first.fetch(:Id)

    yield extension_id, response
  ensure
    unless @ad_extension_deleted
      if extension_id
        api.campaign_management.delete_ad_extensions(
          account_id: account_id,
          ad_extension_ids: [extension_id]
        )
      end
    end
  end

  def with_bulk_hierarchy
    campaign_name = "SDK VCR Hierarchy"
    ad_group_name = "SDK VCR Ad Group"
    upload = api.bulk.get_bulk_upload_url(
      account_id: account_id,
      compress_upload: false,
      account_upload_scope: "Customer",
      entities: ["Campaigns"]
    )
    content = BingAdsRubySdk::BulkFileBuilder.new
      .add_campaign(name: campaign_name, status: "Paused", budget: 1)
      .add_record(
        "Ad Group",
        "Campaign" => campaign_name,
        "Ad Group" => ad_group_name,
        "Status" => "Paused",
        "Ad Group Type" => "SearchStandard",
        "Language" => "English"
      )
      .add_record(
        "Keyword",
        "Campaign" => campaign_name,
        "Ad Group" => ad_group_name,
        "Status" => "Paused",
        "Keyword" => "sdk vcr keyword",
        "Bid" => 0.1,
        "Match Type" => "Exact"
      )
      .to_s
    upload_result = JSON.parse(
      api.bulk.upload_file(
        upload_url: upload.fetch(:UploadUrl),
        content: content,
        filename: "sdk-vcr-hierarchy.csv"
      ),
      symbolize_names: true
    )

    status = nil
    20.times do
      status = api.bulk.get_bulk_upload_status(request_id: upload_result.fetch(:RequestId))
      break unless status[:RequestStatus].to_s == "InProgress"
    end
    raise "Bulk hierarchy upload did not complete" unless status[:RequestStatus].to_s == "Completed"

    campaign = nil
    20.times do
      campaigns = api.campaign_management.get_campaigns_by_account_id(
        account_id: account_id,
        fields: ["Id", "Name"]
      )
      campaign = (campaigns[:Campaigns] || []).find { |item| item[:Name] == campaign_name }
      break if campaign
    end
    raise "Bulk hierarchy campaign was not created" unless campaign

    groups = api.campaign_management.get_ad_groups_by_campaign_id(
      account_id: account_id,
      campaign_id: campaign.fetch(:Id),
      fields: ["Id", "Name"]
    )
    group = (groups[:AdGroups] || []).find { |item| item[:Name] == ad_group_name }
    raise "Bulk hierarchy ad group was not created" unless group

    keywords = api.campaign_management.get_keywords_by_ad_group_id(
      account_id: account_id,
      ad_group_id: group.fetch(:Id),
      fields: ["Id", "Keyword", "Status"]
    )
    keyword = (keywords[:Keywords] || []).first
    raise "Bulk hierarchy keyword was not created" unless keyword

    yield campaign.fetch(:Id), group.fetch(:Id), keyword.fetch(:Id)
  ensure
    if campaign
      api.campaign_management.delete_campaigns(
        account_id: account_id,
        campaign_ids: [campaign.fetch(:Id)]
      )
    end
  end
end
