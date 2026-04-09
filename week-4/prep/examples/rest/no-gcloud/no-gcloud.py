import json
import requests
from google.oauth2 import service_account
from google.auth.transport.requests import Request

# 1. Paths
# Hardcoded credentials and configuration paths
KEY_FILE = "../../../../../032326-tf-key.json"
REST_JSON = "rest-request.json"
LOG_FILE = "create-vm.log"

with open(LOG_FILE, "w") as log:
    # 2. Get Token
    # Authenticates the service account to generate a bearer token
    creds = service_account.Credentials.from_service_account_file(
        KEY_FILE, scopes=["https://www.googleapis.com/auth/cloud-platform"])
    creds.refresh(Request())

    log.write(f"--- AUTHENTICATION ---\n")
    log.write(f"Service Account: {creds.service_account_email}\n")
    log.write(f"Token (First 50 chars): {creds.token[:50]}...\n\n")

    # 3. Load Data
    # Loads the VM specification from the local JSON file
    with open(REST_JSON, 'r') as f:
        data = json.load(f)

    log.write(f"--- DATA LOAD ---\n")
    log.write("\n".join(json.dumps(data, indent=2).splitlines()[:5]) + "\n...\n\n")

    # 4. Request
    # Prepares the API endpoint for the us-east1-b zone
    url = f"https://compute.googleapis.com/compute/v1/projects/seir-1/zones/us-east1-b/instances"
    headers = {"Authorization": f"Bearer {creds.token}", "Content-Type": "application/json"}

    log.write(f"--- REQUEST PREP ---\nURL: {url}\n\n")

    # 5. Result
    # Sends the POST request to Google Cloud and captures the full response
    response = requests.post(url, json=data, headers=headers)

    log.write(f"--- API RESPONSE ---\nStatus: {response.status_code}\n")
    log.write(response.text)

# Console Output
if response.status_code == 200:
    print("Success: VM creation initiated. Check create-vm.log for details.")
else:
    print(f"Error: Status {response.status_code}. Check create-vm.log for the full error.")