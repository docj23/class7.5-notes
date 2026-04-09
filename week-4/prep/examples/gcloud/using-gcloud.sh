gcloud compute instances create chewbacca-web-server-gcloud \
    --project=seir-1 \
    --zone=us-central1-b \
    --machine-type=e2-medium \
    --image-family=debian-12 \
    --image-project=debian-cloud \
    --metadata=student_name=aaron-mcdonald \
    --metadata-from-file=startup-script=./startup-test.sh