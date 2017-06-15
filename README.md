# DockerJMeter
JMeter distributed load testing in docker (inspired by vinsdocker)

First off build the images (you only need to run this once), if you rerun it each time it will have more of an overhead:


```
#!/bin/bash

./build_images.sh
```

Then you can build the docker container and run a test which will generate a folder inside 'jmeterresults' timestamped and called the same name as the test. Inside the folder will be the results .jtl and all graphs generated from these test results:

```
#!/bin/bash

./build.sh jmeterresults/name_of_test.jmx
```

If you provide an argument for the number of slaves you want to create, you can run a distributed load test:

```
#!/bin/bash

./build.sh jmeterresults/name_of_test.jmx 3
```

This will do the same and run the Graph Generation test afterwards on the master results file which contains all the combined slave results.

## **THIS NEXT PART IS FOR IF YOU WANT TO RUN JMETER INSIDE A CONTAINER AND THEN ENTER THE CONTAINER TO RUN THE TEST MANUALLY:** ##

Build the container in a different way:

```
#!/bin/bash

docker run -dit --name=masterjmeter -v $(pwd)/jmeterresults:/jmeter/apache-jmeter-3.2/bin/jmeterresults -v $(pwd)/jmetertests/:/jmeter/apache-jmeter-3.2/bin/jmetertests jmetermaster /bin/bash
```

To run a test in master use the following command inside the master docker container:


```
#!/bin/bash

./jmeter -n -t jmetertests/jmeter-test-file.jmx -f jmeterresults/myresults.jtl
```

The test results will be inside the jmeterresults folder both in the container and locally.

To run a distributed load test first find the ip addresses of the slaves you have started up:


```
#!/bin/bash

docker inspect --format '{{ .Name }} => {{ .NetworkSettings.IPAddress }}' $(docker ps -a -q)
```


To run a run the actual distributed load test use the following command in the master docker container:


```
#!/bin/bash

./jmeter -n -t jmeter-test-file.jmx -Ripaddress1,ipaddress2,ipaddress3 -f myresults.jtl
```

## **RUNNING A GRAPH MANUALLY FROM THE RESULTS FILE** ##

Once you have a graph installed and the results file from a test you can run the following command to generate a graph:


```
#!/bin/bash

./JMeterPluginsCMD.sh --tool Reporter --generate-png test.png --input-jtl /jmeter/apache-jmeter-2.13/bin/myresults_2.jtl --plugin-type ResponseTimesOverTime --width 800 --height 600
```


This will generate an output file called test.png which will have your graphed results
