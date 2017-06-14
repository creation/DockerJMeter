# DockerJMeter
JMeter distributed load testing in docker (inspired by vinsdocker)

First off build the images:


```
#!bash

./build_images.sh
```

Then you can build the docker container and run it:

```
#!bash

./build.sh path/to/test/test.jmx name_of_output.jtl
```

(remember if using a graph listener you need call the output file the same
 name that you have specified in the listener)

Specifically in this case you can run:

```
#!bash

./build.sh jmetertests/Drupal7RandomWalk_GraphGeneratorListener.jmx myresults.jtl
```

Then you should see that once its all finished inside your jmeterresults folder are the graphs and .jtl results file.

THIS NEXT PART IS FOR IF YOU WANT TO RUN JMETER INSIDE A CONTAINER AND THEN ENTER THE CONTAINER TO RUN THE TEST MANUALLY:

Build the container in a different way:

```
#!bash

docker run -dit --name=masterjmeter jmetermaster /bin/bash
```

To run a test in master use the following command inside the master docker container:


```
#!bash

./jmeter -n -t jmeter-test-file.jmx -f myresults.jtl
```


To run a distributed load test first find the ip addresses of the slaves you have started up:


```
#!bash

docker inspect --format '{{ .Name }} => {{ .NetworkSettings.IPAddress }}' $(docker ps -a -q)
```


To run a run the actual distributed load test use the following command in the master docker container:


```
#!bash

./jmeter -n -t jmeter-test-file.jmx -Ripaddress1,ipaddress2,ipaddress3 -f myresults.jtl
```


Once you have a graph installed and the results file from a test you can run the following command to generate a graph:


```
#!bash

./JMeterPluginsCMD.sh --tool Reporter --generate-png test.png --input-jtl /jmeter/apache-jmeter-2.13/bin/myresults_2.jtl --plugin-type ResponseTimesOverTime --width 800 --height 600
```


This will generate an output file called test.png which will have your graphed results