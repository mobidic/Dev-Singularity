#!/usr/bin/bash 

###########################################################
#
# Bash wrapper to launch wdl workflow from SINGULARITY 
#
# By Nicolas SOIRAT - nicolas.soirat@etu.umontpellier.fr
#           Version 0.0.2
#
###########################################################
#     MoBiDiC
# ---------------------------------------------------------

###########################################################
# Global 
###########################################################

RED='\033[0;31m'
LIGHTRED='\033[1;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

VERSION="0.0.2"

# -- Script log 

VERBOSITY=4
#exec 3>&2

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
  echo "        -l | --log <log leve> : log level [DEBUG, INFO, WARNING, ERROR, CRITICAL] (default INFO)"
  echo " "
  echo "        -v | --verbosity <integer> : decrease or increase verbosity level (ERROR : 1 | WARNING : 2 | INFO [default] : 3 | DEBUG : 4)"
  echo " "
  echo "General arguments : "
  echo "        -h | --help : show this help message"
  echo " "
  exit 1
}

###########################################################
# Log
###########################################################

# -- Log variables 

ERROR=1
WARNING=2
INFO=3
DEBUG=4

# -- Log functions 

error() { log ${ERROR} "${RED}ERROR${NC} : $1" ; }
warning() { log ${WARNING} "${YELLOW}WARNING${NC} : $1" ; }
info() { log ${INFO} "${BLUE}INFO${NC} : $1" ; }
debug() { log ${DEBUG} "${LIGHTRED}DEBUG${NC} : $1" ; }

# -- Print log 

echoerr() { echo -e "$@" 1>&2 ; }

log() {

  if [ ${VERBOSITY} -ge $1 ]
  then
    #DATE= date +'%Y-%m-%d %H:%M:%S'
    echoerr "[`date +'%Y-%m-%d %H:%M:%S'`] - CromWrap version : ${VERSION} - $2"
  fi
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
VERBOSITYCOUNTER=0

# -- Extraction 

while [ "$1" != "" ]
do 
  case "$1" in 
    -c | --conf) shift
      CONFFILE=$1
      ((CONFCOUNTER++))
      ;;

    -i | --input) shift 
      INPUTSFILE=$1
      ((INPUTSCOUNTER++))
      ;;
    
    -o | --option) shift
      OPTIONFILE=$1
      ((OPTIONCOUNTER++))
      ;;

    -e | --exec) shift 
      CROMWELLFILE=$1
      ((CROMCOUNTER++))
      ;;
    
    -w | --wdl) shift 
      WORKFLOWFILE=$1
      ((WORKFLOWCOUNTER++))
      ;;

    -v | --verbosity) shift 
      VERBOSITY=$1
      ((VERBOSITYCOUNTER++))
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

# -- DEBUG 
debug "CONF COUNTER=${CONFCOUNTER}"
debug "INPUT COUNTER=${INPUTSCOUNTER}"
debug "CROMCOUNTER=${CROMCOUNTER}"
debug "OPTION COUNTER=${OPTIONCOUNTER}"
debug "WF COUNTER=${WORKFLOWCOUNTER}"
debug "VERBOSITYCOUNTER=${VERBOSITYCOUNTER}"
debug "CONF = ${CONFFILE}"
debug "INPUT = ${INPUTSFILE}"
debug "OPTION = ${OPTIONFILE}"
debug "CROM = ${CROMWELLFILE}"
debug "WF = ${WORKFLOWFILE}"


################################################@##########
# Variable checking
###########################################################

# -- Check if there isn't more than one file for each option 

info "Argument checking..."

if [ ${CONFCOUNTER} -gt 1 ]
then 
  echo "Can't use more than one configuration file !"
  echo " "
  help 
fi 

if [ ${INPUTSCOUNTER} -ne 1 ]
then 
  error "You have to use only one input file !"
  echo " "
  help 
fi 

if [ ${OPTIONCOUNTER} -gt 1 ]
then 
  error "Can't use more than one option file !"
  echo " "
  help 
fi

if [ ${CROMCOUNTER} -ne 1 ]
then 
  error "Please enter only one path to cromwell.jar  !"
  echo " "
  help 
fi 

if [ ${WORKFLOWCOUNTER} -ne 1 ]
then 
  error "You have to select ONE workflow file !"
  echo " "
  help 
fi 

if [ ${VERBOSITYCOUNTER} -gt 1 ]
then 
  error "You have to use only one time -s option !"
  echo " "
  help 
fi 

info "Arguments per option : OK !"

# -- Check if files exist 

if [ ! -f ${CONFFILE} ]
then 
  error "\"${CONFFILE}\" does not exist !"
  echo " "
  help 
fi 

if [ ! -f ${INPUTSFILE} ]
then
  error "\"${INPUTSFILE}\" file does not exist !"
  echo " "
  help 
fi 

if [ ! -f ${OPTIONFILE} ]
then 
  error "\"${OPTIONFILE}\" does not exist !"
  echo " "
  help 
fi

if [ ! -f  ${CROMWELLFILE} ]
then 
  error "\"${CROMWELLFILE}\" is not valid !"
  echo " "
  help 
fi 

if [ ! -f ${WORKFLOWFILE} ]
then 
  error "\"${WORKFLOWFILE}\" does not exist !"
  echo " "
  help 
fi

info "Files exist !"

# -- Check file extensions

if [[ ${CONFCOUNTER} -eq 1 && ${CONFFILE##*\.} != "conf" ]]
then 
  error "\"${CONFFILE}\" must be .conf file !"
  echo " "
  help 
fi 

if [ ${INPUTSFILE##*_} != "inputs.json" ]
then
  error "\"${INPUTSFILE}\" must be _inputs.json file !"
  echo " "
  help 
fi 

if [[ ${OPTIONCOUNTER} -eq 1 && ${OPTIONFILE##*\.} !=  "json" ]]
then 
  error "\"${OPTIONFILE}\" must be .json file !"
  echo " "
  help 
fi

if [ ${CROMWELLFILE##*\.} != "jar" ]
then 
  error "\"${CROMWELLFILE}\" must be .jar file !"
  echo " "
  help  
fi 

if [ ${WORKFLOWFILE##*\.} != "wdl" ]
then 
  error "\"${WORKFLOWFILE}\" must be .wdl file !"
  echo " "
  help 
fi 

info "File extension : OK !"
info "Argument checking finished"

# -- Check value of VERBOSITY LEVEL 

if [ ${VERBOSITY} -gt 4 ] || [ ${VERBOSITY} -lt 1 ]
then
  error "\"${VERBOSITY}\" is not a correct value for verbosity level !"
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
else
  warning "CromWrap will launch cromwell command without configuration file !"
fi

if [ ${OPTIONCOUNTER} -eq 1 ]
then 
  OPTION="-o ${OPTIONFILE}"
else
  warning "CromWrap will launch cromwell command without option file !"
fi 

# -- Start

info "Launching wdl command ..."
echo "java ${CONF} -jar ${CROMWELLFILE} run ${WORKFLOWFILE} -i ${INPUTSFILE} ${OPTION}"
info "... Done !"

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
