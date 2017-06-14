# Use phusion
FROM phusion/baseimage
MAINTAINER creation

# Install wget & Java runtime environment
RUN apt-get clean && \
	apt-get update && \
	apt-get -qy install \
				wget \
				default-jre-headless \
				telnet \
				iputils-ping \
				unzip

# Install jmeter and download the latest plugins manager
RUN   mkdir /jmeter \
      && cd /jmeter/ \
      && wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-3.2.tgz \
      && tar -xzf apache-jmeter-3.2.tgz \
      && rm apache-jmeter-3.2.tgz \
          && cd /jmeter/apache-jmeter-3.2/lib/ext/ \
	  && wget https://repo1.maven.org/maven2/kg/apc/jmeter-plugins-manager/0.13/jmeter-plugins-manager-0.13.jar \
          && java -cp /jmeter/apache-jmeter-3.2/lib/ext/jmeter-plugins-manager-0.13.jar org.jmeterplugins.repository.PluginManagerCMDInstaller \
          # Download the cmdrunner.jar which is needed to use plugins manager
          && cd /jmeter/apache-jmeter-3.2/lib/ \
          && wget https://repo1.maven.org/maven2/kg/apc/cmdrunner/2.0/cmdrunner-2.0.jar \
          # install graph command line tool
          && /jmeter/apache-jmeter-3.2/bin/PluginsManagerCMD.sh install jpgc-cmd \
          # install the responses over time graph
          && /jmeter/apache-jmeter-3.2/bin/PluginsManagerCMD.sh install jpgc-graphs-dist \
          && /jmeter/apache-jmeter-3.2/bin/PluginsManagerCMD.sh install jpgc-graphs-basic \
          && /jmeter/apache-jmeter-3.2/bin/PluginsManagerCMD.sh install jpgc-graphs-additional \
          && /jmeter/apache-jmeter-3.2/bin/PluginsManagerCMD.sh install jpgc-graphs-composite \
          && /jmeter/apache-jmeter-3.2/bin/PluginsManagerCMD.sh install jpgc-graphs-vs \
          && /jmeter/apache-jmeter-3.2/bin/PluginsManagerCMD.sh install jpgc-graphs-basic \
          && /jmeter/apache-jmeter-3.2/bin/PluginsManagerCMD.sh install jpgc-ggl \
          && /jmeter/apache-jmeter-3.2/bin/PluginsManagerCMD.sh install jpgc-synthesis \
          && /jmeter/apache-jmeter-3.2/bin/PluginsManagerCMD.sh install jpgc-synthesis

# Copy any tests to the jmeter directory
ADD jmetertests /jmeter/apache-jmeter-3.2/bin/jmetertests

# Set Jmeter Home
ENV JMETER_HOME /jmeter/apache-jmeter-3.2/

# Add Jmeter to the Path
ENV PATH $JMETER_HOME/bin:$PATH
