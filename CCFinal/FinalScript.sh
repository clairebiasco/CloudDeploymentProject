#!/bin/bash
#Claire Biasco
# Final Script

echo "Hello! Please login to begin..."
echo
#gcloud auth login

echo "Enter your Project ID: (ex- cisc5550-346407)"
read projectID  #(for testing: cisc5550-346407)
gcloud config set project $projectID
gcloud config set compute/zone us-central1-a
#gcloud services enable compute.googleapis.com

while true
do
  echo
  echo "Please select an action:"
  echo
  echo "1. View all instances"
  echo "2. Create a new VM instance"
  echo "3. Deploy app files to an instance"
  echo "4. Create and deploy container to GCP"
  echo "5. Delete a VM and firewall rules"
  echo "6. Delete a cluster"
  echo "7. Exit"
  echo
  echo "Enter number 1-7: "
  read answer
  echo

  case $answer in
    1)
        gcloud compute instances list
        echo
    ;;
    2)
        echo "Name your instance: "
        read instance
        echo
        gcloud compute instances create $instance --project=$projectID \
        --machine-type=e2-medium \
        --image-project=debian-cloud \
        --image-family=debian-10 \

        echo
        echo "Name the firewall rule for instance: "
        read namerule
        echo
        gcloud compute firewall-rules create $namerule --source-ranges 0.0.0.0/0 --target-tags http-server --allow tcp:5000

        echo
    ;;
    3)
        echo "Name of instance: "
        read instancen
        echo "Local directory path of folder: "
        #read origin
        echo "Destination path: "
        #read dest
        echo "GCP username and instance (ex- cbiasco2@trial2): "
        read username
        gcloud compute scp --recurse $origin $username:$dest
        echo
        echo "Installing all necessary packages..."
        echo
        gcloud compute ssh "$instancen"  --tunnel-through-iap --project "$projectID" --command 'sudo apt install python3-pip
        pip3 install flask
        pip3 install requests'
        echo "Done"
        echo
    ;;
    4)
        gcloud auth configure-docker
        export TODO_API_IP=`gcloud compute instances list --filter="name=$projectID" --format="value(EXTERNAL_IP)"`

        echo "Please log in to docker: "
        docker login
        echo
        echo "Name of docker image to build: (ex- cbiasco2/docktrial2)"
        read dockname
        docker build -t $dockname --build-arg api_ip=${TODO_API_IP} .
        docker push $dockname
        echo
        echo "Name of cluster: (ex- cisc555-cluster)"
        read clustname
        gcloud container clusters create clustname

        echo "Name for deployment: (ex- cc555)"
        read deployname
        kubectl create deployment deployname --image=$dockname --port=5000
        kubectl expose deployment deployname --type="LoadBalancer"

        kubectl get service deployname

    ;;
    5)
        echo "Name of instance to delete: "
        read iname
        gcloud compute instances delete $iname
        echo
        gcloud compute firewall-rules list
        echo "Name of firewall rule to delete: "
        read fire
        gcloud compute firewall-rules delete $fire
    ;;
    6)
        gcloud container clusters list
        echo
        echo "Name of cluster to delete: "
        read clname
        gcloud container clusters delete $clname


    ;;
    7)
        break
    ;;
    *)
        echo "Invalid number. Try again."
        echo
    ;;
  esac
  echo "Press <Enter> to continue..."
  read ent

done


#gcloud compute scp --recurse /Users/claireb/Desktop/Cloud-HW4 claireb@trial2:~/HW4

#gcloud compute ssh --zone "us-central1-a" "trial2"  --tunnel-through-iap --project "cisc5550-346407"
