#!/bin/bash

CONFIG=riscv
INPUT_TYPE=test

print_error() {
	echo "ERROR: bad options or arguments"
	echo " "
	echo "USAGE: ./run_sift.sh [--benchmark <bname>][--all]"
	echo " --benchmark <bname> : to run the specific benchmark"
	echo "      bname can be 400.perlbench, 401.bzip2, 403.gcc, 429.mcf, 445.gobmk, 456.hmmer, 458.sjeng, 462.libquantum, 464.h264ref, 471.omnetpp, 473.astar or 483.xalancbmk"
	echo " --all : to run all the benchmarks" 
	exit 1
}

if [ $# -gt 0 ]; then
	case "$1" in
		--all) 
			BENCHMARKS=(400.perlbench 401.bzip2 403.gcc 429.mcf 445.gobmk 456.hmmer 458.sjeng 462.libquantum 464.h264ref 471.omnetpp 473.astar 483.xalancbmk)
	    		;;
		--benchmark)
	     		if [ -z $2 ]; then
	      			print_error
			else
				BENCHMARKS=($2)
			fi
	        	;;
		--*) 	print_error
		    	;;
		*)	print_error 
		    	;;
	esac
else
	echo "ERROR: bad options $1"
	echo "  --benchmark [name] (run the specific benchmark) or --all (to run all the benchmarks)"
	exit 1
fi

echo $BENCHMARKS
BASE_DIR=$PWD/${CONFIG}-spec-${INPUT_TYPE}
for b in ${BENCHMARKS[@]}; do

   echo " -== ${b} ==-"
   mkdir -p ${BASE_DIR}/OUTPUT

   cd ${BASE_DIR}/${b}
   SHORT_EXE=${b##*.} # cut off the numbers ###.short_exe
   if [ $b == "483.xalancbmk" ]; then 
      SHORT_EXE=Xalan #WTF SPEC???
   fi
   
   # read the command file
   IFS=$'\n' read -d '' -r -a commands < ${BASE_DIR}/../commands/${b}.${INPUT_TYPE}.cmd

   # run each workload
   count=0
   for input in "${commands[@]}"; do
      if [[ ${input:0:1} != '#' ]]; then # allow us to comment out lines in the cmd files
	 RUN="spike --sift=${SHORT_EXE}-${count}.sift pk "
	 cmd="${RUN} ${SHORT_EXE} ${input} 2> ${BASE_DIR}/OUTPUT/${SHORT_EXE}-${count}.err  > ${BASE_DIR}/OUTPUT/${SHORT_EXE}-${count}.out"
         echo "[Executing] ${cmd}"
         #eval ${cmd}
         ((count++))
      fi
   done
   echo ""

done

echo "Done!"
