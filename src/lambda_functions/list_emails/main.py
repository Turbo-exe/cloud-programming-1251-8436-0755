import json
from datetime import datetime


def list_emails(event, context):
    iso_string = datetime.now().isoformat()
    body = [
        {
            "id": "1", "from": "sender@example.com", "to": "recipient@example.com", "subject": "Meeting Tomorrow",
            "date": iso_string, "body": "Hi, Let\'s meet tomorrow to discuss the project."
        }, {
            "id": "2", "from": "marketing@company.com", "to": "recipient@example.com", "subject": "Special Offer!",
            "date": iso_string, "body": "Don\'t miss our exclusive deals this week."
        }, {
            "id": "3", "from": "notifications@service.com", "to": "recipient@example.com", "subject": "Account Update",
            "date": iso_string, "body": "Your account has been successfully updated."
        }
    ]
    return {
        'statusCode': 200,
        'body': json.dumps(body)
    }
