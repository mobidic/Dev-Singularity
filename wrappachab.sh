#!/usr/bin/bash

###########################################################
#
# Bash wrapper to launch wdl workflow from SINGULARITY 
#
###########################################################

# ---------------------------------------------------------

###########################################################
# Extracting arguments ...
###########################################################

WITHCONF=false
WITHOPTION=false 


for FILENAME in $@
do 
  echo "Fichier est ${FILENAME}"
  echo "EXTENSION EST ${FILENAME##*\.}"
  case "${FILENAME##*\.}" in
    conf) 
      CONFFILE=${FILENAME}
      WITHCONF=true 
      ;;
    json)
      if [ ${FILENAME##*_} == "inputs.json" ]
      then 
        INPUTSFILE=${FILENAME}
        echo "Le fichier input est : ${FILENAME} ${FILENAME##*_}"
      else 
        OPTIONFILE=${FILENAME}
        WITHOPTION=true 
      fi
      ;;
    jar)
      CROMWELLFILE=${FILENAME}
      ;;
    wdl)
      WORKFLOWFILE=${FILENAME}
      ;;
  esac
done 


###########################################################
# Lauching WDL command ... 
###########################################################

if [ ${WITHCONF} == true ]
then
  if [ ${WITHOPTION} == true ]
  then 
    echo "java -Dconfig.file=${CONFFILE} -jar ${CROMWELLFILE} run  ${WORKFLOWFILE} -i ${INPUTSFILE} -o ${OPTIONFILE}"
  else 
    echo "java -Dconfig.file=${CONFFILE} -jar ${CROMWELLFILE} run ${WORKFLOWFILE} -i ${INPUTSFILE}"
  fi
else
  if [ ${WITHOPTION} ==true ] 
  then 
    echo "java -jar ${CROMWELLFILE} run ${WORKFLOWFILE} -i ${INPUTSFILE} -o ${OPTIONFILE}"
  else 
    echo "java -jar ${CROMWELLFILE} run ${WORKFLOWFILE} -i ${INPUTSFILE}"
  fi
fi




    


