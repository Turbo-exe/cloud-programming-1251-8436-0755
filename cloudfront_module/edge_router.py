import re


def lambda_handler(event, context):
    """
    Lambda@Edge function to:
    1. Route users to the closest region based on their location
    2. Rewrite API paths for API Gateway compatibility
    This function is triggered by CloudFront origin-request events.
    """
    request = event["Records"][0]["cf"]["request"]
    headers = request["headers"]
    uri = request["uri"]

    # Get viewer"s country from CloudFront-Viewer-Country header
    viewer_country = "US"  # Fallback to US if we don't know user"s country
    if "cloudfront-viewer-country" in headers:
        viewer_country = headers["cloudfront-viewer-country"][0]["value"]

    # Map countries to regions
    # In a productive setting, this should be replaced by a more robust country to region mapping
    eu_countries = [
        "AT", "BE", "BG", "HR", "CY", "CZ", "DK", "EE", "FI", "FR", "DE", "GR", "HU",
        "IE", "IT", "LV", "LT", "LU", "MT", "NL", "PL", "PT", "RO", "SK", "SI", "ES", "SE"
    ]
    ap_countries = ["CN", "JP", "KR", "IN", "AU", "NZ", "SG", "MY", "TH", "VN", "PH", "ID", "HK"]
    af_countries = ["ZA", "NG", "EG", "KE", "MA", "GH", "TZ", "DZ", "TN", "ET"]

    # Determine region based on country
    if viewer_country in eu_countries:
        region = "eu"
    elif viewer_country in ap_countries:
        region = "ap"
    elif viewer_country in af_countries:
        region = "af"
    else:
        region = "us"  # Default to US

    # Check if this is already a regional path
    parts = uri.split("/")
    current_region = parts[1] if len(parts) > 1 else None

    if current_region not in ["eu", "us", "ap", "af"]:
        # No region in path, add it
        if uri == "/":
            new_uri = f"/{region}/"
        else:
            new_uri = f"/{region}{uri}"

        # Create a redirect response
        return {
            "status": "302",
            "statusDescription": "Found",
            "headers": {
                "location": [{"key": "Location", "value": new_uri}],
                "cache-control": [{"key": "Cache-Control","value": "max-age=3600"}]
            }
        }

    return request



