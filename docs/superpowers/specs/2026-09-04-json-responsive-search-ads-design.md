# JSON Responsive Search Ads Design

## Goal

Replicate the SOAP `AddAds` workflow for the currently supported Microsoft Advertising ad type, `ResponsiveSearchAd`, through the JSON API without breaking the existing generic `add_ads(payload)` method.

## Design

Add a convenience method to the JSON Campaign Management service:

```ruby
add_responsive_search_ads(ad_group_id:, headlines:, descriptions:, final_urls:, path1: nil, path2: nil, status: "Paused")
```

The method will build the REST `AddAds` payload with:

- `AdGroupId` at the request root
- one `Ad` object per request item
- `Type: "ResponsiveSearchAd"`
- `Headlines` and `Descriptions` as `AssetLink` objects containing `TextAsset` objects
- common fields such as `FinalUrls`, `Status`, `Path1`, and `Path2`

The existing `add_ads(payload)` remains the low-level escape hatch and continues to accept caller-supplied payloads unchanged.

## Validation

- Unit coverage will assert the helper delegates to `post("Ads", ...)` with the expected snake_case payload.
- JSON service coverage will continue to verify recursive camelization, producing `AdGroupId`, `ResponsiveSearchAd`, `TextAsset`, `FinalUrls`, and other REST field names.
- A live validation will create a paused campaign and ad group, call the new helper, verify the returned ad ID, and delete the ad group and campaign in child-before-parent order.

## Compatibility

Expanded text ad creation will not be used for live validation because Microsoft retired new `ExpandedTextAd` creation. The SOAP derived type is `ResponsiveSearchAd`, while the REST JSON discriminator is `ResponsiveSearch`, matching the existing ad responses. SOAP support remains unchanged.
