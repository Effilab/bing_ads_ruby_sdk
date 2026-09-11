# frozen_string_literal: true

RSpec.describe "JSON Reporting API" do
  include_context "json api with vcr"

  it "submits a Reporting request" do
    use_json_api_cassette("submits_a_Reporting_request") do
      response = api.reporting.submit_generate_report(
        report_request: {
          type: "AccountPerformanceReportRequest",
          format: "Csv",
          format_version: "2.0",
          report_name: "SDK VCR Integration Report",
          return_only_complete_data: true,
          aggregation: "Daily",
          columns: ["TimePeriod", "AccountId", "Impressions"],
          scope: {account_ids: [account_id]},
          time: {
            predefined_time: "Yesterday",
            report_time_zone: "PacificTimeUSCanadaTijuana"
          }
        }
      )

      request_id = response.fetch(:ReportRequestId)
      status = api.reporting.poll_generate_report(report_request_id: request_id)

      expect(status).to include(:ReportRequestStatus)
    end
  end

  it "downloads and parses an account performance report" do
    use_json_api_cassette("reporting_downloads_and_parses_account_performance_buffered") do
      rows = download_report(stream: false)

      expect_report_rows(rows)
    end
  end

  it "streams and parses an account performance report" do
    use_json_api_cassette("reporting_downloads_and_parses_account_performance_streamed") do
      rows = download_report(stream: true)

      expect_report_rows(rows)
    end
  end

  def download_report(stream:)
    request_id = api.reporting.submit_generate_report(
      report_request: {
        type: "AccountPerformanceReportRequest",
        format: "Csv",
        format_version: "2.0",
        report_name: "SDK VCR Account Performance Data",
        return_only_complete_data: true,
        aggregation: "Daily",
        columns: ["TimePeriod", "AccountId", "Impressions", "Clicks", "Spend"],
        scope: {account_ids: [account_id]},
        time: {
          custom_date_range_start: {year: 2026, month: 8, day: 1},
          custom_date_range_end: {year: 2026, month: 9, day: 3},
          report_time_zone: "PacificTimeUSCanadaTijuana"
        }
      }
    ).fetch(:ReportRequestId)

    status_response = nil
    20.times do
      status_response = api.reporting.poll_generate_report(report_request_id: request_id)
      break if %w[Success Error Failed].include?(status_response.dig(:ReportRequestStatus, :Status))
    end

    report_status = status_response.fetch(:ReportRequestStatus)
    expect(report_status.fetch(:Status)).to eq("Success")
    download_url = report_status.fetch(:ReportDownloadUrl)
    expect(download_url).not_to be_empty

    content = api.reporting.download_file(url: download_url, stream: stream)
    reader = BingAdsRubySdk::BulkFileReader.new(content)
    stream ? reader.each_row.to_a : reader.to_csv
  end

  def expect_report_rows(rows)
    expect(rows.first.headers).to eq(["TimePeriod", "AccountId", "Impressions", "Clicks", "Spend"]) if rows.is_a?(CSV::Table)
    expect(rows).not_to be_empty
    first_row = rows.first
    expect(first_row.to_h).to include(
      "TimePeriod" => a_string_matching(/\A\d{4}-\d{2}-\d{2}\z/),
      "AccountId" => a_string_matching(/\A\d+\z/),
      "Impressions" => a_string_matching(/\A\d+\z/),
      "Clicks" => a_string_matching(/\A\d+\z/),
      "Spend" => a_string_matching(/\A\d+(\.\d+)?\z/)
    )
  end
end
