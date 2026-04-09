curl -X POST \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  -d "@rest-request.json" \
  "https://compute.googleapis.com/compute/v1/projects/seir-1/zones/us-east1-b/instances"