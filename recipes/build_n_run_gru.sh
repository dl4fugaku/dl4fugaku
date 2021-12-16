#!/bin/bash

ADDLLVM="no"
ADDFCC="yes"
ADDGCC="no"
ADDSCOREP="no"

#source /opt/ohpc/admin/lmod/lmod/init/zsh; module load system/fx700; module load FJSVstclanga
#LLVMDIR=$HOME/llvm-v12.0.0
#export PATH=$LLVMDIR/bin:$PATH
#export LD_LIBRARY_PATH=$LLVMDIR/lib:$LD_LIBRARY_PATH
#export CC=$(which clang); export CXX=$(which clang++)

if [ -f ~/spack/share/spack/setup-env.sh ]; then
	. ~/spack/share/spack/setup-env.sh
else
	. /vol0004/apps/oss/spack/share/spack/setup-env.sh
fi

spack load fujitsu-mpi@latest%gcc@8.3.1 arch=linux-rhel8-a64fx; export LD_LIBRARY_PATH=/lib64:$LD_LIBRARY_PATH
spack load hwloc@1.11.11%gcc@8.3.1 arch=linux-rhel8-a64fx; export LD_LIBRARY_PATH=/lib64:$LD_LIBRARY_PATH

mkdir -p $HOME/build.onednn
cd $HOME/build.onednn
export BUILDDIR=$(pwd)

if [ ! -f arm_compute-v21.11-bin-linux-armv8.2-a-sve-neon.tar.gz ]; then
	wget https://github.com/ARM-software/ComputeLibrary/releases/download/v21.11/arm_compute-v21.11-bin-linux-armv8.2-a-sve-neon.tar.gz
	mkdir -p $BUILDDIR/armcl
	tar xzf arm_compute-v21.11-bin-linux-armv8.2-a-sve-neon.tar.gz -C $BUILDDIR/armcl --strip-components 1
fi

if [ ! -d oneDNN.git ]; then
	git clone --branch lbann https://github.com/dl4fugaku/oneDNN.git oneDNN.git
fi


#############################################################
############### FCC #########################################
if [[ "$ADDLLVM" = "yes" ]]; then

	spack load llvm@12.0.1%gcc@8.3.1 arch=linux-rhel8-a64fx
	export CC=$(which clang); export CXX=$(which clang++)

	cd $BUILDDIR/oneDNN.git
	sed -i '/SDL.cmake/d' ./CMakeLists.txt
	rm -rf build; mkdir -p build; cd build

	ACL_ROOT_DIR="$BUILDDIR/armcl" cmake .. -DCMAKE_INSTALL_PREFIX=$BUILDDIR/oneDNN-llvm \
		 -DCMAKE_C_COMPILER="$(which clang)" -DCMAKE_CXX_COMPILER="$(which clang++)" \
		 -DCMAKE_AR="$(dirname $(which clang))/ar" -DCMAKE_CXX_COMPILER_AR="$(dirname $(which clang))/llvm-ar" -DCMAKE_CXX_COMPILER_RANLIB="$(dirname $(which clang))/llvm-ranlib" -DCMAKE_C_COMPILER_AR="$(dirname $(which clang))/llvm-ar" -DCMAKE_C_COMPILER_RANLIB="$(dirname $(which clang))/llvm-ranlib" -DCMAKE_LINKER="$(dirname $(which clang))/lld" -DCMAKE_NM="$(dirname $(which clang))/nm" -DCMAKE_OBJCOPY="$(dirname $(which clang))/objcopy" -DCMAKE_OBJDUMP="$(dirname $(which clang))/objdump" -DCMAKE_RANLIB="$(dirname $(which clang))/ranlib" -DCMAKE_STRIP="$(dirname $(which clang))/strip" \
		 -DCMAKE_C_FLAGS="-Ofast -ffast-math -mcpu=a64fx -mtune=a64fx" -DCMAKE_CXX_FLAGS="-Ofast -ffast-math -mcpu=a64fx -mtune=a64fx" -DCMAKE_CXX_FLAGS_RELEASE="-DNDEBUG" \
		 -DCMAKE_BUILD_TYPE=Release -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_SYSTEM_PROCESSOR=AARCH64 \
		 -DDNNL_LIBRARY_TYPE=STATIC -DDNNL_CPU_RUNTIME=OMP -DDNNL_BUILD_EXAMPLES=OFF -DDNNL_BUILD_TESTS=OFF \
		 -DDNNL_AARCH64_USE_ACL=ON -DACL_INCLUDE_DIRS="$ACL_ROOT_DIR/include" -DACL_LIBRARY="$ACL_ROOT_DIR/lib/armv8.2-a-sve-neon/libarm_compute.so" -DACL_GRAPH_LIBRARY="$ACL_ROOT_DIR/lib/armv8.2-a-sve-neon/libarm_compute_graph.so" -DACL_CORE_LIBRARY="$ACL_ROOT_DIR/lib/armv8.2-a-sve-neon/libarm_compute_core.so" \
		 -DDNNL_BLAS_VENDOR=OPENBLAS -DBLAS_LIBRARIES="m -fuse-ld=lld -L$(readlink -f $(dirname $(which mpifcc))/../lib64) -Wl,-rpath=$(readlink -f $(dirname $(which clang))/../lib) $(readlink -f $(dirname $(which mpifcc))/../lib64)/fjhpctag.o $(readlink -f $(dirname $(which mpifcc))/../lib64)/fjlang08.o $(readlink -f $(dirname $(which mpifcc))/../lib64)/fjomp.o -lfjomphk -lfjomp -lfj90rt2 -lssl2mtexsve -lssl2mtsve -lfj90i -lfj90fmt_sve -lfj90f -lfjsrcinfo -lfj90rt -lfjompcrt -lfjprofcore -lfjprofomp -lm -lrt -latomic -lpthread -lelf -lz -ldl" -DBLAS_INCLUDE_DIR="$(dirname `which fcc`)/../include" \
		 -DDNNL_ENABLE_ITT_TASKS=OFF -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON
	make -j 2>&1 | tee build.log && make install
	cd -

	cd $BUILDDIR/
	cp $BUILDDIR/armcl/lib/armv8.2-a-sve-neon/libarm_*a $BUILDDIR/oneDNN-llvm/lib/

	cd $BUILDDIR/
	mkdir -p $BUILDDIR/gru-llvm
	tar xzf ~/onednn_gru_benchmark.tgz -C $BUILDDIR/gru-llvm --strip-components 1
	cd $BUILDDIR/gru-llvm
	sed -i -e "s#LIBRARIES := .*#LIBRARIES := -L\$(ONEDNN_PATH)/lib -l:libdnnl.a -l:libarm_compute-static.a -l:libarm_compute_graph-static.a -l:libarm_compute_core-static.a\nLIBRARIES += -fuse-ld=lld -L$(readlink -f $(dirname $(which mpifcc))/../lib64) -Wl,-rpath=$(readlink -f $(dirname $(which clang))/../lib)\nLIBRARIES += $(readlink -f $(dirname $(which mpifcc))/../lib64)/fjhpctag.o $(readlink -f $(dirname $(which mpifcc))/../lib64)/fjlang08.o $(readlink -f $(dirname $(which mpifcc))/../lib64)/fjomp.o\nLIBRARIES += -lfjomphk -lfjomp -lfj90rt2 -lssl2mtexsve -lssl2mtsve -lfj90i -lfj90fmt_sve -lfj90f -lfjsrcinfo -lfj90rt -lfjompcrt -lfjprofcore -lfjprofomp\nLIBRARIES += -lm -lrt -latomic -lpthread -lelf -lz -ldl#g" ./Makefile
	sed -i -e "s/i<100/i<10/g" main.cpp
	CXX_FLAGS="-Ofast -ffast-math -mcpu=a64fx -mtune=a64fx -fopenmp -flto" ONEDNN_PATH=$BUILDDIR/oneDNN-llvm make -B
	OMP_BIND=close OMP_NUM_THREADS=12 OMP_WAIT_POLICY=ACTIVE XOS_MMM_L_HPAGE_TYPE=none LD_PRELOAD=/home/apps/oss/PyTorch-1.7.0/lib/libtcmalloc.so ./main

	#for i in $(seq 1 17); do OMP_BIND=close OMP_NUM_THREADS=12 fapp -C -d ./tmp${i} -Icpupa,nompi -Hevent=pa${i} ./main; done
	#mkdir -p fapp.report/ ; for i in `seq 1 17`; do  fapp -A -d ./tmp${i}  -Icpupa -tcsv -o "fapp.report/pa${i}.csv"; done

fi


#############################################################
############### FCC #########################################
if [[ "$ADDFCC" = "yes" ]]; then

	export CC=$(which fcc); export CXX=$(which FCC)

	cd $BUILDDIR/oneDNN.git
	sed -i '/SDL.cmake/d' ./CMakeLists.txt
	rm -rf build; mkdir -p build; cd build

	cmake .. -DCMAKE_INSTALL_PREFIX=$BUILDDIR/oneDNN-fcc \
		 -DCMAKE_C_COMPILER="$(which fcc)" -DCMAKE_CXX_COMPILER="$(which FCC)" \
		 -DCMAKE_C_FLAGS="-Nclang -Ofast -mcpu=a64fx+sve -fopenmp -ffj-ocl -ffj-no-largepage" -DCMAKE_CXX_FLAGS="-Nclang -Ofast -mcpu=a64fx+sve -fopenmp -ffj-ocl -ffj-no-largepage" -DCMAKE_CXX_FLAGS_RELEASE="-DNDEBUG" \
		 -DCMAKE_BUILD_TYPE=Release -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_SYSTEM_PROCESSOR=AARCH64 \
		 -DDNNL_LIBRARY_TYPE=STATIC -DDNNL_CPU_RUNTIME=OMP -DDNNL_BUILD_EXAMPLES=OFF -DDNNL_BUILD_TESTS=OFF \
		 -DDNNL_BLAS_VENDOR=OPENBLAS -DBLAS_LIBRARIES="m -SSL2BLAMP" -DBLAS_INCLUDE_DIR="$(dirname `which fcc`)/../include" \
		 -DDNNL_ENABLE_ITT_TASKS=OFF -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON
	make -j 2>&1 | tee build.log && make install
	cd -

	cd $BUILDDIR/
	mkdir -p $BUILDDIR/gru-fcc
	tar xzf ~/onednn_gru_benchmark.tgz -C $BUILDDIR/gru-fcc --strip-components 1
	cd $BUILDDIR/gru-fcc
	sed -i -e "s#LIBRARIES := .*#LIBRARIES := -L\$(ONEDNN_PATH)/lib -l:libdnnl.a -SSL2BLAMP#g" ./Makefile
	sed -i -e "s/i<100/i<10/g" main.cpp
	CXX="FCC" CXX_FLAGS="-Nclang -Ofast -mcpu=a64fx+sve -fopenmp -ffj-ocl -ffj-no-largepage" ONEDNN_PATH=$BUILDDIR/oneDNN-fcc make -B
	OMP_BIND=close OMP_NUM_THREADS=12 OMP_WAIT_POLICY=ACTIVE XOS_MMM_L_HPAGE_TYPE=none LD_PRELOAD=/home/apps/oss/PyTorch-1.7.0/lib/libtcmalloc.so ./main

fi


#############################################################
############### SCORE-P #####################################
if [[ "$ADDGCC" = "yes" ]]; then

	cd $BUILDDIR/oneDNN.git
	sed -i '/SDL.cmake/d' ./CMakeLists.txt
	rm -rf build; mkdir -p build; cd build

	spack load gcc@10.2.0 arch=linux-rhel8-a64fx
	export CC=$(which gcc); export CXX=$(which g++)

	ACL_ROOT_DIR="$BUILDDIR/armcl" cmake .. -DCMAKE_INSTALL_PREFIX=$BUILDDIR/oneDNN-gcc \
		 -DCMAKE_C_COMPILER="$(which gcc)" -DCMAKE_CXX_COMPILER="$(which g++)" \
		 -DCMAKE_C_FLAGS="-O3 -march=native" -DCMAKE_CXX_FLAGS="-O3 -march=native" -DCMAKE_CXX_FLAGS_RELEASE="-DNDEBUG" \
		 -DCMAKE_BUILD_TYPE=Release -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_SYSTEM_PROCESSOR=AARCH64 \
		 -DDNNL_LIBRARY_TYPE=STATIC -DDNNL_CPU_RUNTIME=OMP -DDNNL_BUILD_EXAMPLES=OFF -DDNNL_BUILD_TESTS=OFF \
		 -DDNNL_AARCH64_USE_ACL=ON -DACL_INCLUDE_DIRS="$ACL_ROOT_DIR/include" -DACL_LIBRARY="$ACL_ROOT_DIR/lib/armv8.2-a-sve-neon/libarm_compute.so" -DACL_GRAPH_LIBRARY="$ACL_ROOT_DIR/lib/armv8.2-a-sve-neon/libarm_compute_graph.so" -DACL_CORE_LIBRARY="$ACL_ROOT_DIR/lib/armv8.2-a-sve-neon/libarm_compute_core.so" \
		 -DDNNL_BLAS_VENDOR=OPENBLAS -DBLAS_LIBRARIES="m -L$(readlink -f $(dirname $(which mpifcc))/../lib64) $(readlink -f $(dirname $(which mpifcc))/../lib64)/fjhpctag.o $(readlink -f $(dirname $(which mpifcc))/../lib64)/fjlang08.o $(readlink -f $(dirname $(which mpifcc))/../lib64)/fjomp.o -lfjomphk -lfjomp -lfj90rt2 -lssl2mtexsve -lssl2mtsve -lfj90i -lfj90fmt_sve -lfj90f -lfjsrcinfo -lfj90rt -lfjompcrt -lfjprofcore -lfjprofomp -lm -lrt -latomic -lpthread -lelf -lz -ldl" -DBLAS_INCLUDE_DIR="$(dirname `which fcc`)/../include" \
		 -DDNNL_ENABLE_ITT_TASKS=OFF -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON
	make -j 2>&1 | tee build.log && make install
	cd -

	cd $BUILDDIR/
	cp $BUILDDIR/armcl/lib/armv8.2-a-sve-neon/libarm_*a $BUILDDIR/oneDNN-gcc/lib/

	cd $BUILDDIR/
	mkdir -p $BUILDDIR/gru-gcc
	tar xzf ~/onednn_gru_benchmark.tgz -C $BUILDDIR/gru-gcc --strip-components 1
	cd $BUILDDIR/gru-gcc
	sed -i -e "s#LIBRARIES := .*#LIBRARIES := -L\$(ONEDNN_PATH)/lib -l:libdnnl.a -l:libarm_compute-static.a -l:libarm_compute_graph-static.a -l:libarm_compute_core-static.a\nLIBRARIES += -L$(readlink -f $(dirname $(which mpifcc))/../lib64) $(readlink -f $(dirname $(which mpifcc))/../lib64)/fjhpctag.o $(readlink -f $(dirname $(which mpifcc))/../lib64)/fjlang08.o $(readlink -f $(dirname $(which mpifcc))/../lib64)/fjomp.o\nLIBRARIES += -lfjomphk -lfjomp -lfj90rt2 -lssl2mtexsve -lssl2mtsve -lfj90i -lfj90fmt_sve -lfj90f -lfjsrcinfo -lfj90rt -lfjompcrt -lfjprofcore -lfjprofomp\nLIBRARIES += -lm -lrt -latomic -lpthread -lelf -lz -ldl#g" ./Makefile
	sed -i -e "s/i<100/i<10/g" main.cpp
	CXX_FLAGS="-O3 -march=native -fopenmp" ONEDNN_PATH=$BUILDDIR/oneDNN-gcc make -B
	OMP_BIND=close OMP_NUM_THREADS=12 OMP_WAIT_POLICY=ACTIVE XOS_MMM_L_HPAGE_TYPE=none LD_PRELOAD=/home/apps/oss/PyTorch-1.7.0/lib/libtcmalloc.so ./main

fi


#############################################################
############### SCORE-P #####################################
if [[ "$ADDSCOREP" = "yes" ]]; then

	cd $BUILDDIR/oneDNN.git
	sed -i '/SDL.cmake/d' ./CMakeLists.txt
	rm -rf build; mkdir -p build; cd build

	echo -e 'SCOREP_REGION_NAMES_BEGIN\nEXCLUDE _ZN4dnnl4impl3cpu9rnn_utils8to_floatEPKv16dnnl_data_type_t *to_float*\nSCOREP_REGION_NAMES_END' >../dnnl.filter
	export SCOREP_WRAPPER_INSTRUMENTER_FLAGS="--instrument-filter=$(pwd)/../dnnl.filter"
	spack load gcc@10.2.0 arch=linux-rhel8-a64fx
	export CC=$(which gcc); export CXX=$(which g++)

	#spack install scorep %gcc@10.2.0 mpi=false
	#spack install scorep %clang@12.0.1 mpi=False
	spack load scorep %gcc@10.2.0 arch=linux-rhel8-a64fx
	SCOREP_WRAPPER=off ACL_ROOT_DIR="$BUILDDIR/armcl" cmake .. -DCMAKE_INSTALL_PREFIX=$BUILDDIR/oneDNN-scorep \
		 -DCMAKE_C_COMPILER="$(which scorep-gcc)" -DCMAKE_CXX_COMPILER="$(which scorep-g++)" \
		 -DCMAKE_CXX_COMPILER_AR="$(dirname $(which gcc))/gcc-ar" -DCMAKE_CXX_COMPILER_RANLIB="$(dirname $(which gcc))/gcc-ranlib" -DCMAKE_C_COMPILER_AR="$(dirname $(which gcc))/gcc-ar" -DCMAKE_C_COMPILER_RANLIB="$(dirname $(which gcc))/gcc-ranlib" -DCMAKE_NM="$(dirname $(which gcc))/gcc-nm" -DCMAKE_AR="/usr/bin/ar" -DCMAKE_LINKER="/usr/bin/ld" -DCMAKE_OBJCOPY="/usr/bin/objcopy" -DCMAKE_OBJDUMP="/usr/bin/objdump" -DCMAKE_RANLIB="/usr/bin/ranlib" -DCMAKE_STRIP="/usr/bin/strip" \
		 -DCMAKE_C_FLAGS="-O3 -march=native" -DCMAKE_CXX_FLAGS="-O3 -march=native" -DCMAKE_CXX_FLAGS_RELEASE="-DNDEBUG" \
		 -DCMAKE_BUILD_TYPE=Release -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_SYSTEM_PROCESSOR=AARCH64 \
		 -DDNNL_LIBRARY_TYPE=STATIC -DDNNL_CPU_RUNTIME=OMP -DDNNL_BUILD_EXAMPLES=OFF -DDNNL_BUILD_TESTS=OFF \
		 -DDNNL_AARCH64_USE_ACL=ON -DACL_INCLUDE_DIRS="$ACL_ROOT_DIR/include" -DACL_LIBRARY="$ACL_ROOT_DIR/lib/armv8.2-a-sve-neon/libarm_compute.so" -DACL_GRAPH_LIBRARY="$ACL_ROOT_DIR/lib/armv8.2-a-sve-neon/libarm_compute_graph.so" -DACL_CORE_LIBRARY="$ACL_ROOT_DIR/lib/armv8.2-a-sve-neon/libarm_compute_core.so" \
		 -DDNNL_BLAS_VENDOR=OPENBLAS -DBLAS_LIBRARIES="m -fuse-ld=lld -L$(readlink -f $(dirname $(which mpifcc))/../lib64) $(readlink -f $(dirname $(which mpifcc))/../lib64)/fjhpctag.o $(readlink -f $(dirname $(which mpifcc))/../lib64)/fjlang08.o $(readlink -f $(dirname $(which mpifcc))/../lib64)/fjomp.o -lfjomphk -lfjomp -lfj90rt2 -lssl2mtexsve -lssl2mtsve -lfj90i -lfj90fmt_sve -lfj90f -lfjsrcinfo -lfj90rt -lfjompcrt -lfjprofcore -lfjprofomp -lm -lrt -latomic -lpthread -lelf -lz -ldl" -DBLAS_INCLUDE_DIR="$(dirname `which fcc`)/../include" \
		 -DDNNL_ENABLE_ITT_TASKS=OFF -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON
	make -j 2>&1 | tee build.log && make install
	cd -

	cd $BUILDDIR/
	cp $BUILDDIR/armcl/lib/armv8.2-a-sve-neon/libarm_*a $BUILDDIR/oneDNN-scorep/lib/

	cd $BUILDDIR/
	mkdir -p $BUILDDIR/gru-scorep
	tar xzf ~/onednn_gru_benchmark.tgz -C $BUILDDIR/gru-scorep --strip-components 1
	cd $BUILDDIR/gru-scorep
	sed -i -e "s#LIBRARIES := .*#LIBRARIES := -L\$(ONEDNN_PATH)/lib -l:libdnnl.a -l:libarm_compute-static.a -l:libarm_compute_graph-static.a -l:libarm_compute_core-static.a\nLIBRARIES += -L$(readlink -f $(dirname $(which mpifcc))/../lib64) $(readlink -f $(dirname $(which mpifcc))/../lib64)/fjhpctag.o $(readlink -f $(dirname $(which mpifcc))/../lib64)/fjlang08.o $(readlink -f $(dirname $(which mpifcc))/../lib64)/fjomp.o\nLIBRARIES += -lfjomphk -lfjomp -lfj90rt2 -lssl2mtexsve -lssl2mtsve -lfj90i -lfj90fmt_sve -lfj90f -lfjsrcinfo -lfj90rt -lfjompcrt -lfjprofcore -lfjprofomp\nLIBRARIES += -lm -lrt -latomic -lpthread -lelf -lz -ldl#g" ./Makefile
	sed -i -e "s/i<100/i<10/g" main.cpp
	CXX="$(which scorep-g++)" CXX_FLAGS="-O3 -march=native -fopenmp" ONEDNN_PATH=$BUILDDIR/oneDNN-scorep make -B
	SCOREP_ENABLE_PROFILING=false SCOREP_ENABLE_TRACING=true SCOREP_TOTAL_MEMORY=4095MB OMP_BIND=close OMP_NUM_THREADS=12 OMP_WAIT_POLICY=ACTIVE XOS_MMM_L_HPAGE_TYPE=none LD_PRELOAD=/home/apps/oss/PyTorch-1.7.0/lib/libtcmalloc.so ./main

fi
