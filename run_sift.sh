#!/bin/bash

CONFIG=riscv
INPUT_TYPE=test
BUILD_DIR=${SPECKLE_HOME}/${CONFIG}-spec-${INPUT_TYPE}

SIMULATOR=spike	# spike or rv8
OUTPUT_LOC=${SPECKLE_HOME}/output/${SIMULATOR}

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
	print_error
fi

for b in ${BENCHMARKS[@]}; do

	if [ ! -d ${BUILD_DIR}/${b} ]; then
		print_error
	fi

	echo "Running riscv simulator ($SIMULATOR) for $b ...."
   	OUTPUT_DIR=${OUTPUT_LOC}/${b}
   	mkdir -p ${OUTPUT_DIR}
	
	cd ${BUILD_DIR}/${b}
   	SHORT_EXE=${b##*.} # cut off the numbers ###.short_exe
  
	# handle benchmarks that don't conform to the naming convention
   	if [ $b == "482.sphinx3" ]; then SHORT_EXE=sphinx_livepretend; fi
   	if [ $b == "483.xalancbmk" ]; then SHORT_EXE=Xalan; fi  

   	# read the command file
   	IFS=$'\n' read -d '' -r -a commands < ${SPECKLE_HOME}/commands/${b}.${INPUT_TYPE}.cmd

   	# run each workload
   	count=1
   	for input in "${commands[@]}"; do
      		if [[ ${input:0:1} != '#' ]]; then # allow us to comment out lines in the cmd files
	 		
			if [[ $SIMULATOR == 'rv8' ]]; then
				RUN="$RV8_HOME/build/linux_x86_64/bin/rv-jit --log-sift --log-sift-filename ${SHORT_EXE}-${count}.sift"
			else
				RUN="spike --sift=${SHORT_EXE}-${count}.sift pk "
	 		fi

			cmd="${RUN} ${SHORT_EXE} ${input} 2> ${OUTPUT_DIR}/${SHORT_EXE}-${count}.err  > ${OUTPUT_DIR}/${SHORT_EXE}-${count}.out" 
			echo "${cmd}"
        	 	
			eval ${cmd}
	 		[ -f rv8.bb ] && mv rv8.bb $OUTPUT_DIR/${SHORT_EXE}-${count}.bb
			[ -f ${SHORT_EXE}-${count}.sift ] && mv ${SHORT_EXE}-${count}.sift $OUTPUT_DIR/${SHORT_EXE}-${count}.sift
         		((count++))
      		fi
   	done
   	echo ""

done

echo "Done!"
