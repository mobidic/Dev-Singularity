#!/usr/bin/bash 

###########################################################
#
# Bash wrapper to launch wdl workflow from SINGULARITY 
#
# By Nicolas SOIRAT - nicolas.soirat@etu.umontpellier.fr
#           Version 0.0.1
#
###########################################################

# ---------------------------------------------------------

###########################################################
# Global 
###########################################################


###########################################################
# Help 
###########################################################

help() {
  echo "CromWrap is a wrapper allowing you to start wdl workflow"
  echo "Usage : cromwrap.sh"
  echo "Mandatory arguments : "
  echo "        -e | --exec <cromwell[version].jar> : path to cromwell"
  echo "        -w | --wdl <workflowfile.wdl> : wdl file input"
  echo "        -i | --input <yourinpunts_inputs.json> : select your input file"
  echo " "
  echo "Optional arguments : "
  echo "        -c | --conf <file.conf> : If you want to use Database for Cromwell for example"
  echo "        -o | --option <options.json> : File to add in the command if you have specific options for cromwell"
  echo " "
  echo "General arguments : "
  echo "        -h | --help : show this help message"
  echo " "
  exit 1
}

###########################################################
# Extracting arguments ... 
###########################################################

# -- Variables 

CONFFILE=""
INPUTSFILE=""
OPTIONFILE=""
CROMWELLFILE=""
WORKFLOWFILE=""

CONFCOUNTER=0
INPUTSCOUNTER=0
OPTIONCOUNTER=0
CROMCOUNTER=0
WORKFLOWCOUNTER=0

# -- Extraction 

while [ "$1" != "" ]
do 
  case "$1" in 
    -c | --conf) shift
      CONFFILE=$1
      ((CONFCOUNTER++))
      #echo "CONF COUNTER=${CONFCOUNTER}"
      ;;

    -i | --input) shift 
      INPUTSFILE=$1
      ((INPUTSCOUNTER++))
      #echo "INPUT COUNTER=${INPUTSCOUNTER}"
      ;;
    
    -o | --option) shift
      OPTIONFILE=$1
      ((OPTIONCOUNTER++))
      #echo "OPTION COUNTER=${OPTIONCOUNTER}"
      ;;

    -e | --exec) shift 
      CROMWELLFILE=$1
      ((CROMCOUNTER++))
      #echo "CROMCOUNTER=${CROMCOUNTER}"
      ;;
    
    -w | --wdl) shift 
      WORKFLOWFILE=$1
      ((WORKFLOWCOUNTER++))
      #echo "WF COUNTER=${WORKFLOWCOUNTER}"
      ;;

    -h | --help)
      help 
      exit
      ;;

    *)
      echo "Unknow option encounter : \"$1\""
      echo " "
      help 
      ;;
  esac
  shift 
done 

# -- TEST 

#echo "CONF = ${CONFFILE}"
#echo "INPUT = ${INPUTSFILE}"
#echo "OPTION = ${OPTIONFILE}"
#echo "CROM = ${CROMWELLFILE}"
#echo "WF = ${WORKFLOWFILE}"

################################################@##########
# Variable checking
###########################################################

# -- Check if there isn't more than one file for each option 

if [ ${CONFCOUNTER} -gt 1 ]
then 
  echo "Can't use more than one configuration file !"
  echo " "
  help 
fi 

if [ ${INPUTSCOUNTER} -ne 1 ]
then 
  echo "You have to use only one input file !"
  echo " "
  help 
fi 

if [ ${OPTIONCOUNTER} -gt 1 ]
then 
  echo "Can't use more than one option file !"
  echo " "
  help 
fi

if [ ${CROMCOUNTER} -ne 1 ]
then 
  echo "Please enter only one path to cromwell.jar  !"
  echo " "
  help 
fi 

if [ ${WORKFLOWCOUNTER} -ne 1 ]
then 
  echo "You have to select ONE workflow file"
  echo " "
  help 
fi 


# -- Check if files exist 

if [ ! -f ${CONFFILE} ]
then 
  echo "\"${CONFFILE}\" does not exist !"
  echo " "
  help 
fi 

if [ ! -f ${INPUTSFILE} ]
then
  echo "\"${INPUTSFILE}\" file does not exist !"
  echo " "
  help 
fi 

if [ ! -f ${OPTIONFILE} ]
then 
  echo "\"${OPTIONFILE}\" does not exist !"
  echo " "
  help 
fi

if [ ! -f  ${CROMWELLFILE} ]
then 
  echo "\"${CROMWELLFILE}\" is not valid !"
  echo " "
  help 
fi 

if [ ! -f ${WORKFLOWFILE} ]
then 
  echo "\"${WORKFLOWFILE}\" does not exist !"
  echo " "
  help 
fi

# -- Check file extensions

if [[ ${CONFCOUNTER} -eq 1 && ${CONFFILE##*\.} != "conf" ]]
then 
  echo "\"${CONFFILE}\" must be .conf file !"
  echo " "
  help 
fi 

if [ ${INPUTSFILE##*_} != "inputs.json" ]
then
  echo "\"${INPUTSFILE}\" must be _inputs.json file !"
  echo " "
  help 
fi 

if [[ ${OPTIONCOUNTER} -eq 1 && ${OPTIONFILE##*\.} !=  "json" ]]
then 
  echo "\"${OPTIONFILE}\" must be .json file !"
  echo " "
  help 
fi

if [ ${CROMWELLFILE##*\.} != "jar" ]
then 
  echo "\"${CROMWELLFILE}\" must be .jar file !"
  echo " "
  help  
fi 

if [ ${WORKFLOWFILE##*\.} != "wdl" ]
then 
  echo "\"${WORKFLOWFILE}\" must be .wdl file !"
  echo " "
  help 
fi 



###########################################################
# Launching WDL command ... 
###########################################################

# -- Preparation 
if [ ${CONFCOUNTER} -eq 1 ]
then 
  CONF="-Dconfig.file=${CONFFILE}"
fi

if [ ${OPTIONCOUNTER} -eq 1 ]
then 
  OPTION="-o ${OPTIONFILE}"
fi 

# -- Start

echo "java ${CONF} -jar ${CROMWELLFILE} run ${WORKFLOWFILE} -i ${INPUTSFILE} ${OPTION}"


###########################################################
# TRASH 
###########################################################


#if [ ${CONFCOUNTER} == 1 ]
#then 
#  if [ ${OPTIONCOUNTER} == 1 ]
#  then 
#    echo "java -Dconfig.file=${CONFFILE} -jar ${CROMWELLFILE} run ${WORKFLOWFILE} -i ${INPUTSFILE} -o ${OPTIONFILE}"
#  elif [ ${OPTIONCOUNTER} == 0 ]
#  then 
#    echo "java -Dconfig.file=${CONFFILE} -jar ${CROMWELLFILE} run ${WORKFLOWFILE} -i ${INPUTSFILE}"
#  else 
#    echo "Can't use more than one configuration file !"
#  fi 

#elif [ ${CONFCOUNTER} == 0 ]
#then 
#  if [ ${OPTIONCOUNTER} == 1 ]
#  then 
#    echo "java ${DECONF} -jar ${CROMWELLFILE} run ${WORKFLOWFILE} -i ${INPUTSFILE} -o ${OPTIONFILE}"
#  elif [ ${OPTIONCOUNTER} == 0 ]
