import json
from datetime import datetime


def send_email(event, context):
    iso_string = datetime.now().isoformat()
    body = {
        "status": "success",
        "message": f"This could have been an email - literally. This backend demonstrates, "
                   f"how a backend service could be implemented for an actual company site. Received at {iso_string}."
    }
    return {
        'statusCode': 200,
        'body': json.dumps(body)
    }
