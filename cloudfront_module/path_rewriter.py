import re


def lambda_handler(event, context):
    """
    Handles an AWS Lambda@Edge function to modify incoming CloudFront request URIs. This function rewrites
    URIs by removing specific region prefixes (e.g., /eu/, /us/, /ap/) to standardize the request paths.
    It processes requests based on the event data provided by CloudFront.

    :param event: The AWS Lambda event object structured as expected for Lambda@Edge,
                  specifically containing CloudFront request data.
    :param context: The AWS Lambda context object, which provides runtime information.
    :return: The modified CloudFront request object with the rewritten URI.
    """
    region_shortcodes = ["eu", "us", "ap", "af"]
    request = event["Records"][0]["cf"]["request"]
    pattern = r"^/(" + "|".join(region_shortcodes) + ")/"
    request["uri"] = re.sub(
        pattern=pattern,
        repl="/",
        string=request["uri"],
    )
    return request
