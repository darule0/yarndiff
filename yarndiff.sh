#!/bin/bash

#
# For documentation and license see https://github.com/darule0/yarndiff/
#

if [ $# -lt 2 ]; then
    echo "Usage: yarndiff <yarn container log 1> <yarn container log 2>"
    exit 1
fi
CONTAINER_LOG_1=$1
CONTAINER_LOG_2=$2



getLog4JFootprints () {
 CONTAINER_LOG=$1
 cat ${CONTAINER_LOG} | egrep 'CRIT|ERROR|WARN|INFO|DEBUG|TRACE' | grep -v "has been replaced by"| tr '0123456789^$*+-?()[]{}|—/\\' "." |  cut -c-80 | sort | uniq
}
specialEntries () {
 CONTAINER_LOG=$1
 {
   echo "container.log.file: ${1}"
   echo "container.count: "`cat ${CONTAINER_LOG} | grep "^Container: " | wc -l`
 }
} 

rm -fr ~/.yarndiff
mkdir ~/.yarndiff

specialEntries ${CONTAINER_LOG_1} >> ~/.yarndiff/log4j1.Footprint
specialEntries ${CONTAINER_LOG_2} >> ~/.yarndiff/log4j2.Footprint

getLog4JFootprints ${CONTAINER_LOG_1} >> ~/.yarndiff/log4j1.Footprint
getLog4JFootprints ${CONTAINER_LOG_2} >> ~/.yarndiff/log4j2.Footprint


diff ~/.yarndiff/log4j1.Footprint ~/.yarndiff/log4j2.Footprint > ~/.yarndiff/yarn.diff

echo `cat ~/.yarndiff/yarn.diff | grep "< container.log.file: "`" CRIT/ERROR/WARN/INFO/DEBUG/TRACE"
echo `cat ~/.yarndiff/yarn.diff | grep "< container.count: "`" CRIT/ERROR/WARN/INFO/DEBUG/TRACE"
LT_RAW_CONTAINER_LOG=`cat ~/.yarndiff/yarn.diff | grep "< container.log.file: " | awk '{print $3}'`
cat ~/.yarndiff/yarn.diff | grep "^<" | egrep "CRIT|ERROR|WARN|INFO|DEBUG|TRACE" | while read CONTAINER_DIFF_LINE
do
  CONTAINER_LINE_SIGNATURE=`echo ${CONTAINER_DIFF_LINE} | cut -c 3-`
  CONTAINER_LINE_RAW=`cat ${LT_RAW_CONTAINER_LOG} | grep "${CONTAINER_LINE_SIGNATURE}" | head -1 | cut -c-120`
  CONTAINER_LINE_COUNT=`cat ${LT_RAW_CONTAINER_LOG} | grep "${CONTAINER_LINE_SIGNATURE}" | wc -l`
  if [[ ( "$CONTAINER_LINE_COUNT" > 0 ) ]] ; then
   CONTAINER_LINE_DIFF="   < count=${CONTAINER_LINE_COUNT} sample=${CONTAINER_LINE_RAW}..."
   CONTAINER_LINE_DIFF=`echo "${CONTAINER_LINE_DIFF}" | sed 's/CRIT/\\\e[101mCRIT\\\e[49m/g'`
   CONTAINER_LINE_DIFF=`echo "${CONTAINER_LINE_DIFF}" | sed 's/ERROR/\\\e[91mERROR\\\e[39m/g'`
   CONTAINER_LINE_DIFF=`echo "${CONTAINER_LINE_DIFF}" | sed 's/WARN/\\\e[93mWARN\\\e[39m/g'`
   CONTAINER_LINE_DIFF=`echo "${CONTAINER_LINE_DIFF}" | sed 's/INFO/\\\e[96mINFO\\\e[39m/g'`
   CONTAINER_LINE_DIFF=`echo "${CONTAINER_LINE_DIFF}" | sed 's/DEBUG/\\\e[92mDEBUG\\\e[39m/g'`
   CONTAINER_LINE_DIFF=`echo "${CONTAINER_LINE_DIFF}" | sed 's/TRACE/\\\e[32mTRACE\\\e[39m/g'`
   echo -e "${CONTAINER_LINE_DIFF}"
  fi
done

echo `cat ~/.yarndiff/yarn.diff | grep "> container.log.file: "`" CRIT/ERROR/WARN/INFO/DEBUG/TRACE"
echo `cat ~/.yarndiff/yarn.diff | grep "> container.count: "`" CRIT/ERROR/WARN/INFO/DEBUG/TRACE"
GT_RAW_CONTAINER_LOG=`cat ~/.yarndiff/yarn.diff | grep "> container.log.file: " | awk '{print $3}'`
cat ~/.yarndiff/yarn.diff | grep "^>" | egrep "CRIT|ERROR|WARN|INFO|DEBUG|TRACE" | while read CONTAINER_DIFF_LINE
do
  CONTAINER_LINE_SIGNATURE=`echo ${CONTAINER_DIFF_LINE} | cut -c 3-`
  CONTAINER_LINE_RAW=`cat ${GT_RAW_CONTAINER_LOG} | grep "${CONTAINER_LINE_SIGNATURE}" | head -1 | cut -c-120`
  CONTAINER_LINE_COUNT=`cat ${GT_RAW_CONTAINER_LOG} | grep "${CONTAINER_LINE_SIGNATURE}" | wc -l`
  if [[ ( "$CONTAINER_LINE_COUNT" > 0 ) ]] ; then
   CONTAINER_LINE_DIFF="   > count=${CONTAINER_LINE_COUNT} sample=${CONTAINER_LINE_RAW}..."
   CONTAINER_LINE_DIFF=`echo "${CONTAINER_LINE_DIFF}" | sed 's/CRIT/\\\e[101mCRIT\\\e[49m/g'`
   CONTAINER_LINE_DIFF=`echo "${CONTAINER_LINE_DIFF}" | sed 's/ERROR/\\\e[91mERROR\\\e[39m/g'`
   CONTAINER_LINE_DIFF=`echo "${CONTAINER_LINE_DIFF}" | sed 's/WARN/\\\e[93mWARN\\\e[39m/g'`
   CONTAINER_LINE_DIFF=`echo "${CONTAINER_LINE_DIFF}" | sed 's/INFO/\\\e[96mINFO\\\e[39m/g'`
   CONTAINER_LINE_DIFF=`echo "${CONTAINER_LINE_DIFF}" | sed 's/DEBUG/\\\e[92mDEBUG\\\e[39m/g'`
   CONTAINER_LINE_DIFF=`echo "${CONTAINER_LINE_DIFF}" | sed 's/TRACE/\\\e[32mTRACE\\\e[39m/g'`
   echo -e "${CONTAINER_LINE_DIFF}"
  fi
done



