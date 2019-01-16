# frozen_string_literal: true

RSpec.describe BingAdsRubySdk::Preprocessors::Order do

  def action
    new_params = described_class.new(wrapper, unordered_params).call
    expect(new_params.to_json).to eq(ordered_params.to_json)
  end

  context "nested hashes" do
    let(:wrapper) do
      SpecHelpers.wrapper(:customer_management, "SignupCustomer")
    end

    let(:unordered_params) {{
      "Account" => {
        "Name" => "test account",
        "CurrencyCode" => "EUR",
        "ParentCustomerId" => "1234"
      },
      "Customer" => {
        "CustomerAddress" => "address",
        "Industry" => "industry",
        "MarketCountry" => "country"
      },
      "ParentCustomerId" => "1234"
    }}

    let(:ordered_params) {{
      "Customer" => {
        "Industry" => "industry",
        "MarketCountry" => "country",
        "CustomerAddress" => "address"
      },
      "Account" => {
        "CurrencyCode" => "EUR",
        "Name" => "test account",
        "ParentCustomerId" => "1234"
      },
      "ParentCustomerId" => "1234"
    }}

    it("orders") { action }
  end

  context "arrays" do
    let(:wrapper) do
      SpecHelpers.wrapper(:campaign_management, "UpdateUetTags")
    end

    let(:unordered_params) {{
      "UetTags" => [
        {
          "UetTag" => {
            "Name" => 'mofo2',
            "Description" => nil,
            "Id" => '26034398'
          }
        }
      ]
    }}

    let(:ordered_params) {{
      "UetTags" => [
        {
          "UetTag" => {
            "Description" => nil,
            "Id" => '26034398',
            "Name" => 'mofo2'
          }
        }
      ]
    }}

    it("orders") { action }
  end

  context "abstract types" do
    let(:wrapper) do
      SpecHelpers.wrapper(:campaign_management, "AddConversionGoals")
    end

    let(:unordered_params) {{
      "ConversionGoals" => [
        {
          "ConversionGoal" => {
            "@type" => "EventGoal",
            "ActionExpression" => 'contact_form',
            "ActionOperator" => 'Equals',
            "ConversionWindowInMinutes" => 43200,
            "CountType" => "Unique",
            "Name" => "contact_form",
            "Revenue" => { "Type" => "NoValue" },
            "Type" => "Event",
            "TagId" => 26003317
          }
        }
      ]
    }}

    let(:ordered_params) {{
      "ConversionGoals" => [
        {
          "ConversionGoal" => {
            "ConversionWindowInMinutes" => 43200,
            "CountType" => "Unique",
            "Name" => "contact_form",
            "Revenue" => { "Type" => "NoValue" },
            "TagId" => 26003317,
            "Type" => "Event",
            "ActionExpression" => 'contact_form',
            "ActionOperator" => 'Equals',
            "@type" => "EventGoal"
          }
        }
      ]
    }}

    it("orders") { action }
  end
end