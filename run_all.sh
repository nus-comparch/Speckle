BNCHMARKS=(401.bzip2 429.mcf 445.gobmk 456.hmmer 458.sjeng 462.libquantum 464.h264ref 471.omnetpp 473.astar)

for b in ${BENCHMARKS[@]}; do
	#echo "mkdir -p OUTPUT/$b"
	echo "time ./gen_binaries.sh --benchmark $b --run 2> OUTPUT/$b/error > OUTPUT/$b/out"
done

