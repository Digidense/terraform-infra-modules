import json

def generate_policy(principal_id, effect, resource):
    auth_response = {
        'principalId': principal_id
    }

    if effect and resource:
        policy_document = {
            'Version': '2012-10-17',
            'Statement': [
                {
                    'Action': 'execute-api:invoke',
                    'Effect': effect,
                    'Resource': resource
                }
            ]
        }
        auth_response['policyDocument'] = policy_document

    return auth_response


def lambda_handler(event, context):
    token = event.get('authorizationToken', '')

    valid_token = 'xyz987'

    if token == valid_token:
        return generate_policy('user', 'Allow', event.get('methodArn', ''))
    else:
        return generate_policy('user', 'Deny', event.get('methodArn', ''))
