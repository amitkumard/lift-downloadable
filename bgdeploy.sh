#!/bin/bash

appStatusCheck(){
  RETURN=1
  echo "Checking Health of ${1}"
  GUID=$(cf app ${1} --guid)
  SUMMARY=$(cf curl "v2/apps/${GUID}/summary")
   NUM_INSTANCES=$(echo ${SUMMARY} | python -c 'import sys, json; print json.load(sys.stdin)["instances"]')
   n=0
  while [ ${RETURN} = "1" ] && [ ${n} -lt 10 ] ; do
    n=$(expr ${n} + 1)
    echo "Trying : ${n}/10 "
    RETURN=0
    STATS=$(cf curl "v2/apps/${GUID}/stats")
    if [[ ${STATS} == *\"error_code\"* ]] ; then
      echo ${STATS} | python -c 'import sys, json ; print json.load(sys.stdin)["description"]'
      RETURN=1
      sleep 2
    else
      for ((i=0;i<${NUM_INSTANCES};i++)) ; do
        STATUS=$(echo ${STATS} | python -c 'import sys, json ; print json.load(sys.stdin)['\"${i}\"']["state"]')
        echo ${i} : ${STATUS}
        if [ ${STATUS} != "RUNNING" ] ; then
          RETURN=1
          sleep 2
        fi
      done
    fi
  done
  return ${RETURN}
}


appIdleCheck(){
  RETURN=1
  echo "Checking ${1} is idle or not"
  GUID=$(cf app ${1} --guid)
  SUMMARY=$(cf curl "v2/apps/${GUID}/summary")
  NUM_INSTANCES=$(echo ${SUMMARY} | python -c 'import sys, json; print json.load(sys.stdin)["instances"]')
  n=0
  while [ ${RETURN} = "1" ] && [ ${n} -lt 10 ] ; do
    n=$(expr ${n} + 1)
    echo "Trying : ${n}/10 "
    OLD_LOG=$(cf logs ${1} --recent | grep RTR | tail -n 1)
    echo ${OLD_LOG} | awk '{print "1st Log timestamp : " $1}'
    RETURN=0
    for ((i=0;i<${NUM_INSTANCES};i++)) ; do
      ESTABLISHED=$(cf ssh ${1} -i ${i} -c "netstat -an | grep 8080 | grep ESTABLISHED | wc -l")
      if [ ${ESTABLISHED} != "0" ] ; then
        RETURN=1
        echo "${ESTABLISHED} established connection(s) is(are) exist"
      fi
    done
    if [ ${RETURN} = "0" ] ; then
      NEW_LOG=$(cf logs ${1} --recent | grep RTR | tail -n 1)
      echo ${NEW_LOG} | awk '{print "2nd Log timestamp : " $1}'
      if [ "${OLD_LOG}" != "${NEW_LOG}" ] ; then
        RETURN=1
        echo "New Log is generated. App is not IDLE yet"
      fi
    fi
  done
echo "RETURN : ${RETURN}"
  return ${RETURN};
}

echo "######################################################################################"
echo "##########################   Check if first time deployment    #######################"
echo "######################################################################################"
blue_app=`cf apps | grep $1 | wc -l`
green_app=`cf apps | grep $4 | wc -l`

if [ $blue_app != 1 ] && [ $green_app != 1 ]; then
  first_deployment='true'
else
  first_deployment='false'
fi

if [ $first_deployment == 'true' ]; then
  echo
  echo "######################################################################################"
  echo "#############################   First Time Deployment   ##############################"
  echo "######################################################################################"
  echo ""
  echo ""
  echo "######################################################################################"
  echo "################################### Push Blue App ####################################"
  echo "######################################################################################"
  echo
  cf push -f $3
  appStatusCheck $1
  if [ $? != "0" ] ; then
    echo "Failed to push APP. Exit with 1"
    exit 1
  fi
  echo
  echo "######################################################################################"
  echo "########################### Map Server 1 to Blue App #################################"
  echo "######################################################################################"
  echo
  cf map-route $1 mybluemix.net -n $2

  echo
  echo "######################################################################################"
  echo "################################### Push Green App ###################################"
  echo "######################################################################################"
  echo
  cf push -f $5
  appStatusCheck $4
  if [ $? != "0" ] ; then
    echo "Failed to push APP. Exit with 1"
    exit 1
  fi

  echo
  echo "######################################################################################"
  echo "########################### Map Server 2 to Green App ################################"
  echo "######################################################################################"
  echo
  cf map-route $4 mybluemix.net -n $2

else
  echo
  echo "######################################################################################"
  echo "################################### Unmap Server 1 ###################################"
  echo "######################################################################################"
  echo
  cf unmap-route $1 mybluemix.net -n $2
  appIdleCheck $1
  if [ $? != "0" ] ; then
    echo "Failed to stop APP. Exit with 1"
    exit 1
  fi

  echo
  echo "######################################################################################"
  echo "################################### Push Blue App ####################################"
  echo "######################################################################################"
  echo
  cf push -f $3
  appStatusCheck $1
  if [ $? != "0" ] ; then
    echo "Failed to push APP. Exit with 1"
    exit 1
  fi

  ############################################################################
        ####  Below is a dummy echo statement for Pulling latest Jars
        ###   Replace with actual logic to pull latest golden copy of
        ###  dependent jars
  ############################################################################

  echo
  echo "######################################################################################"
  echo "####################### Pulling Latest Golden copy of Jars ###########################"
  echo "######################################################################################"
  echo

  ############################################################################
        ####  This is a place holder for running integration tests #######
        ####  hook up your tests at this place ####
  ############################################################################

  #### Hook start

  echo "######################################################################################"
  echo "################################### Running Test #####################################"
  echo "######################################################################################"
  echo
  echo ""
  echo ""
  mvn -Dtest=Test* test
  #### Hook end
  rc=$?
  if [[ $rc -ne 0 ]] ; then
    echo "######################################################################################"
    echo 'Tests failed ... Rolling back update to Blue App'
    echo "######################################################################################"
    echo ""
    echo ""
    sleep 10
    echo "######################################################################################"
    echo "############################ Copy Green App to Blue App ##############################"
    echo "######################################################################################"
    cf copy-source $4 $1
    echo
    echo "######################################################################################"
    echo "########################### Map Server 1 to Blue App #################################"
    echo "######################################################################################"
    echo
    cf map-route $1 mybluemix.net -n $2
  else
    echo
    echo "######################################################################################"
    echo "########################### Map Server 1 to Blue App #################################"
    echo "######################################################################################"
    echo
    cf map-route $1 mybluemix.net -n $2
    echo
    echo "######################################################################################"
    echo "################################### Unmap Server 2 ###################################"
    echo "######################################################################################"
    echo
    cf unmap-route $4 mybluemix.net -n $2
    appIdleCheck $4
    if [ $? != 0 ] ; then
      echo "Failed to stop APP. Push app anyway!"
    fi

    echo
    echo "######################################################################################"
    echo "################################### Push Green App ###################################"
    echo "######################################################################################"
    echo
    cf push -f $5
    appStatusCheck $4
    if [ $? != "0" ] ; then
      echo "Failed to push APP. Exit with 1"
      exit 1
    fi

    echo
    echo "######################################################################################"
    echo "########################## Map Server 2 to Green App #################################"
    echo "######################################################################################"
    echo
    cf map-route $4 mybluemix.net -n $2
  fi
fi
