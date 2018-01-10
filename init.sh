#!/bin/sh 
DEMO="Cloud Travel Agency Acquisition Demo"
AUTHORS="Niraj Patel, Shepherd Chengeta, Van Halbert,"
AUTHORS2="Andrew Block, Eric D. Schabell"
PROJECT="git@github.com:redhatdemocentral/rhcs-travel-agency-acquisition-demo.git"
SRC_DIR=./installs
BPMS=jboss-bpmsuite-6.4.0.GA-deployable-eap7.x.zip
EAP=jboss-eap-7.0.0-installer.jar
DV=jboss-dv-6.3.0-1-installer.jar

# Adjust these variables to point to an OCP instance.
OPENSHIFT_USER=openshift-dev
OPENSHIFT_PWD=devel
HOST_IP=yourhost.com
OCP_DESCRIPTION="Travel Agency Acquisition"
OCP_PRJ=appdev-in-cloud
OCP_APP=travel-booking-acquisition
OCP_APP_DV=travel-booking-dv

# prints the documentation for this script.
function print_docs()
{
	echo "This project can be installed on any OpenShift platform, such as the OpenShift Container"
  echo "Platform (OCP). It is possible to install it on any available installation, just point"
  echo "this installer at your installation by passing an IP of your OpenShift installation:"
	echo
	echo "   $ ./init.sh IP"
	echo
	echo "If using Red Hat OCP, IP should look like: 192.168.99.100"
	echo
}

# check for a valid passed IP address.
function valid_ip()
{
	local  ip=$1
	local  stat=1

	if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
		OIFS=$IFS
		IFS='.'
		ip=($ip)
		IFS=$OIFS
		[[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
		stat=$?
	fi

	return $stat
}

# wipe screen.
clear 

echo
echo "################################################################################"
echo "##                                                                            ##"   
echo "##  Setting up the ${DEMO}                       ##"
echo "##                                                                            ##"   
echo "##     ####  ####   #   #      ### #   # ##### ##### #####                    ##"
echo "##     #   # #   # # # # #    #    #   #   #     #   #                        ##"
echo "##     ####  ####  #  #  #     ##  #   #   #     #   ###                      ##"
echo "##     #   # #     #     #       # #   #   #     #   #                        ##"
echo "##     ####  #     #     #    ###  ##### #####   #   #####                    ##"
echo "##                                                                            ##" 
echo "##            ####  #   #            ###   #### #####                         ##"
echo "##       #    #   # #   #     #     #   # #     #                             ##"
echo "##      ###   #   # #   #    ###    #   #  ###  ###                           ##"
echo "##       #    #   #  # #      #     #   #     # #                             ##"
echo "##            ####    #              ###  ####  #####                         ##"
echo "##                                                                            ##"   
echo "##  brought to you by,                                                        ##"   
echo "##                     ${AUTHORS}           ##"
echo "##                     ${AUTHORS2}                         ##"
echo "##                                                                            ##"   
echo "##  ${PROJECT}  ##"
echo "##                                                                            ##"   
echo "################################################################################"
echo

# validate OpenShift host IP.
if [ $# -eq 1 ]; then
	if valid_ip "$1" || [ "$1" == "$HOST_IP" ]; then
		echo "OpenShift host given is a valid IP..."
		HOST_IP=$1
		echo
		echo "Proceeding with OpenShift host: $HOST_IP..."
		echo
	else
		# bad argument passed.
		echo "Please provide a valid IP that points to an OpenShift installation..."
		echo
		print_docs
		echo
		exit
	fi
elif [ $# -gt 1 ]; then
	print_docs
	echo
	exit
else
	# no arguments, prodeed with default host.
	print_docs
	echo
	exit
fi

# make some checks first before proceeding.	
command -v oc -v >/dev/null 2>&1 || { echo >&2 "OpenShift command line tooling is required but not installed yet... download here: https://access.redhat.com/downloads/content/290"; exit 1; }

# make some checks first before proceeding.	
if [ -r $SRC_DIR/$EAP ] || [ -L $SRC_DIR/$EAP ]; then
	echo "EAP product sources are present..."
	echo
else
	echo "Need to download $EAP package from from https://developers.redhat.com/products/eap/download"
	echo "and place it in the $SRC_DIR directory to proceed..."
	echo
	exit
fi

if [ -r $SRC_DIR/$BPMS ] || [ -L $SRC_DIR/$BPMS ]; then
		echo "BPM Suite product sources are present..."
		echo
else
		echo "Need to download $BPMS package from https://developers.redhat.com/products/bpmsuite/download"
		echo "and place it in the $SRC_DIR directory to proceed..."
		echo
		exit
fi

if [ -r $SRC_DIR/$DV ] || [ -L $SRC_DIR/$DV ]; then
	echo "DV product sources, present..."
	echo
else
	echo "Need to download $DV package from from https://developers.redhat.com/products/datavirt/download"
	echo "and place it in the $SRC_DIR directory to proceed..."
	echo
	exit
fi

echo "OpenShift commandline tooling is installed..."
echo 
echo "Logging in to OpenShift as $OPENSHIFT_USER..."
echo
oc login $HOST_IP:8443 --password=$OPENSHIFT_PWD --username=$OPENSHIFT_USER

if [ "$?" -ne "0" ]; then
	echo
	echo "Error occurred during 'oc login' command!"
	exit
fi

echo
echo "Creating a new project..."
echo
oc new-project "$OCP_PRJ" --display-name="$OCP_DESCRIPTION" --description="Travel agency booking application solution for data issues after acquisition of sister agency during bookings season."

echo "Setup for DataVirt container..."
echo
cp support/Dockerfile-dv Dockerfile

echo
echo "Setting up a new $OCP_APP_DV build..."
echo
oc delete bc "$OCP_APP_DV" -n "$OCP_PRJ" >/dev/null 2>&1
oc delete imagestreams "developer" >/dev/null 2>&1
oc delete imagestreams "$OCP_APP_DV" >/dev/null 2>&1
oc new-build "jbossdemocentral/developer" --name=$OCP_APP_DV --binary=true 
			
if [ "$?" -ne "0" ]; then
	echo
	echo "Error occurred during 'oc new-build' command!"
	exit
fi

# need to wait a bit for new build to finish with developer image.
sleep 10

echo
echo "Importing developer image..."
echo
oc import-image developer
												
if [ $? -ne 0 ]; then
	echo
	echo "Error occurred during 'oc import-image' commanda!"
	exit
fi
																		
echo
echo "Starting a $OCP_APP_DV build, this takes some time to upload all of the product sources for build..."
echo
oc start-build $OCP_APP_DV --from-dir=. --follow=true --wait=true
																		
if [ $? -ne 0 ]; then
	echo
	echo "Error occurred during 'oc start-build' command!"
	exit
fi

echo
echo "Creating a new $OCP_APP_DV application..."
echo
oc new-app $OCP_APP_DV
																				
if [ $? -ne 0 ]; then
	echo
	echo "Error occurred during 'oc new-app' command!"
	exit
fi
																				
echo
echo "Creating an externally facing route for $OCP_APP_DV by exposing a service..."
echo
oc expose service $OCP_APP_DV --port=8080
																				
if [ $? -ne 0 ]; then
	echo
	echo "Error occurred during 'oc expose service' command!"
	exit
fi

echo "Setup for BPM container..."
echo
cp support/Dockerfile-bpms Dockerfile

echo
echo "Setting up a new $OCP_APP build..."
echo
oc delete bc "$OCP_APP" -n "$OCP_PRJ" >/dev/null 2>&1
oc delete imagestreams "developer" >/dev/null 2>&1
oc delete imagestreams "$OCP_APP" >/dev/null 2>&1
oc new-build "jbossdemocentral/developer" --name=$OCP_APP --binary=true 
			
if [ "$?" -ne "0" ]; then
	echo
	echo "Error occurred during 'oc new-build' command!"
	exit
fi

# need to wait a bit for new build to finish with developer image.
sleep 10

echo
echo "Importing developer image..."
echo
oc import-image developer
												
if [ $? -ne 0 ]; then
	echo
	echo "Error occurred during 'oc import-image' commanda!"
	exit
fi
																		
echo
echo "Starting a $OCP_APP build, this takes some time to upload all of the product sources for build..."
echo
oc start-build $OCP_APP --from-dir=. --follow=true --wait=true
																		
if [ $? -ne 0 ]; then
	echo
	echo "Error occurred during 'oc start-build' command!"
	exit
fi
																								
echo
echo "Creating a new $OCP_APP application..."
echo
oc new-app $OCP_APP
																								
if [ $? -ne 0 ]; then
	echo
	echo "Error occurred during 'oc new-app' command!"
	exit
fi
																														
echo
echo "Creating an externally facing route for $OCP_APP by exposing a service..."
echo
oc expose service $OCP_APP --port=8080
																														
if [ $? -ne 0 ]; then
	echo
	echo "Error occurred during 'oc expose service' command!"
	exit
fi

echo
echo "=================================================================================="
echo "=                                                                                ="
echo "=  For instructions on how to demo this example, see the Readme.md file.         ="
echo "=                                                                                ="
echo "=  Login to start exploring the Travel Agency Acquisition project:               ="
echo "=                                                                                ="
echo "=    http://$OCP_APP-$OCP_PRJ.$HOST_IP.nip.io/business-central  ="
echo "=                                                                                ="
echo "=    [ u:erics / p:jbossbpm1! ]                                                  ="
echo "=                                                                                ="
echo "=                                                                                ="
echo "=  Access the online Travel Agency booking web application at:                   ="
echo "=                                                                                ="
echo "=    http://$OCP_APP-$OCP_PRJ.$HOST_IP.nip.io/external-client-ui-form-1.0  ="
echo "=                                                                                ="
echo "=  Note: it takes a few minutes to expose these routes                           ="
echo "=                                                                                ="
echo "=================================================================================="

