  #!/bin/bash

if [ "$1" == "--help" ]; then
  echo "To use this script run ./build.sh jmetertests/test.jmx number_of_slaves(optional)"
  exit 0
fi

#Check if there are any arguements, if not then exit
if [ $# -eq 0 ];
  then
    echo "No arguments supplied, please use --help to find usage"
    exit 0
fi

# Create a new folder and move all of the results into it

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

NEWFOLDER=$1

NEWFOLDER=${NEWFOLDER%????}

NEWFOLDER=${NEWFOLDER#????????????}

NEWFOLDER=$NEWFOLDER-$timestamp

NEWFILE=$NEWFOLDER.jtl

cd jmeterresults

mkdir $NEWFOLDER

cp output.txt $NEWFOLDER/output.txt
cp errors.txt $NEWFOLDER/errors.txt

cd ../jmetertests

sed -i '' -e "s/\$jmeter_results_dir/$NEWFOLDER/g" Graph_Report_Generator.jmx

sed -i '' -e "s/\$jmeter_results_file/$NEWFILE/g" Graph_Report_Generator.jmx

cd ../

#Tidy up the old container if one is running
docker rm -f masterjmeter

if [ -z "$2" ]
  then
    echo "No argument supplied for number of slaves, continuing with just master"
    #If not running slaves you can just use the arguments originally passed in to run on master
    docker run --name=masterjmeter -v $(pwd)/jmeterresults:/jmeter/apache-jmeter-3.2/bin/jmeterresults -v $(pwd)/jmetertests/:/jmeter/apache-jmeter-3.2/bin/jmetertests jmetermaster bash /jmeter/apache-jmeter-3.2/bin/jmeter -n -t /jmeter/apache-jmeter-3.2/bin/$1 -l /jmeter/apache-jmeter-3.2/bin/jmeterresults/$NEWFOLDER/$NEWFILE > $(pwd)/jmeterresults/$NEWFOLDER/output.txt 2> $(pwd)/jmeterresults/$NEWFOLDER/errors.txt
    #Remove the container so that we can start another to create the reports & graphs
    docker rm -f masterjmeter
    #Run the graph & report generator test on the results file from the first test
    docker run  --name=masterjmeter -v $(pwd)/jmeterresults:/jmeter/apache-jmeter-3.2/bin/jmeterresults -v $(pwd)/jmetertests/:/jmeter/apache-jmeter-3.2/bin/jmetertests jmetermaster bash /jmeter/apache-jmeter-3.2/bin/jmeter -n -t /jmeter/apache-jmeter-3.2/bin/jmetertests/Graph_Report_Generator.jmx
else

  #get the number of slaves currently running in docker.
  slaves=`docker ps | grep jmeterslave | wc -l`

  #Pass the amount of slaves to for loop so that can incrementally stop and remove them
  for (( i = 1; i <= $slaves; i++ )); do
    #remove the old slave containers if there are any
    echo "removing any running slave containers"
    docker stop slave0$i && docker rm slave0$i
  done

  amount=$2

#Set the variable to grab all the ip addresses of the slaves to pass into the docker run command to master
SLAVEIP=""
SLAVEIPS=""

  #Loop through the count of slaves and create them as well as store their ipaddresses in one variable
  for (( i = 1; i <= $amount; i++ )); do
    #build the slave images
    docker run -dit --name=slave0$i jmeterslave /bin/bash
    #build up the comma separated list of ip's to feed into the command to run on master
    SLAVEIP+=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' slave0$i),
  done

  #Ensure the last comma is taken from the list of ip addresses when passing into the command.
  SLAVEIPS=${SLAVEIP%?}
  #Run the docker command to master to run the test and pass in the ipaddresses of the slaves to ensure a distributed test is run.
  docker run --name=masterjmeter -v $(pwd)/jmeterresults:/jmeter/apache-jmeter-3.2/bin/jmeterresults -v $(pwd)/jmetertests/:/jmeter/apache-jmeter-3.2/bin/jmetertests jmetermaster bash /jmeter/apache-jmeter-3.2/bin/jmeter -n -t /jmeter/apache-jmeter-3.2/bin/$1 -R$SLAVEIPS -l /jmeter/apache-jmeter-3.2/bin/jmeterresults/$NEWFOLDER/$NEWFILE > $(pwd)/jmeterresults/$NEWFOLDER/output.txt 2> $(pwd)/jmeterresults/$NEWFOLDER/errors.txt
  #Remove the container so that we can start another to create the reports & graphs
  docker rm -f masterjmeter
  #Run the graph & report generator test on the results file from the first test
  docker run  --name=masterjmeter -v $(pwd)/jmeterresults:/jmeter/apache-jmeter-3.2/bin/jmeterresults -v $(pwd)/jmetertests/:/jmeter/apache-jmeter-3.2/bin/jmetertests jmetermaster bash /jmeter/apache-jmeter-3.2/bin/jmeter -n -t /jmeter/apache-jmeter-3.2/bin/jmetertests/Graph_Report_Generator.jmx

fi

cd jmetertests

sed -i '' -e "s/$NEWFOLDER/\$jmeter_results_dir/g" Graph_Report_Generator.jmx

sed -i '' -e "s/$NEWFILE/\$jmeter_results_file/g" Graph_Report_Generator.jmx

cd ../

#if you just want to run the container and then run the tests inside it you can run the following command
#docker run -dit --name=masterjmeter jmetermaster /bin/bash

#REMEMBER THAT IF YOU'RE USING THE GRAPHS GENERATOR LISTENER IN YOUR TEST YOU NEED TO MAKE SURE THE OUTPUT FILE AND PATH IS THE SAME IN THE TEST
