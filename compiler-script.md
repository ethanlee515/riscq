cmake -G Ninja -DCMAKE_BUILD_TYPE="Release"   \
      -DBUILD_SHARED_LIBS=True -DLLVM_USE_SPLIT_DWARF=True \
      -DLLVM_ENABLE_PROJECTS="clang" \
      -DCMAKE_INSTALL_PREFIX="../../riscv-install"   \
      -DLLVM_OPTIMIZED_TABLEGEN=True -DLLVM_BUILD_TESTS=False   \
      -DDEFAULT_SYSROOT="/opt/riscv/riscv64-unknown-elf"  \
      -DLLVM_DEFAULT_TARGET_TRIPLE="riscv64-unknown-elf" \
      -DLLVM_TARGETS_TO_BUILD="RISCV"   ../llvm



cmake -G Ninja -DCMAKE_BUILD_TYPE="Release"   \
      -DBUILD_SHARED_LIBS=True -DLLVM_USE_SPLIT_DWARF=True \
      -DLLVM_ENABLE_PROJECTS="clang" \
      -DCMAKE_INSTALL_PREFIX="../../riscv-install"   \
      -DLLVM_OPTIMIZED_TABLEGEN=True -DLLVM_BUILD_TESTS=False   \
      -DDEFAULT_SYSROOT="../../riscv-install"  \
      -DLLVM_DEFAULT_TARGET_TRIPLE="riscv32-unknown-elf" \
      -DLLVM_TARGETS_TO_BUILD="RISCV"   ../llvm

cmake -G Ninja -DCMAKE_BUILD_TYPE="Release"   \
      -DLLVM_ENABLE_PROJECTS="clang;lld" \
      -DCMAKE_INSTALL_PREFIX="../../riscv-install"   \
      -DLLVM_BUILD_TESTS=False   \
      -DDEFAULT_SYSROOT="/opt/riscv/riscv64-unknown-elf"  \
      -DLLVM_DEFAULT_TARGET_TRIPLE="riscv64-unknown-elf" \
      -DLLVM_ENABLE_RUNTIMES=all \
      -DLLVM_TARGETS_TO_BUILD="RISCV"   ../llvm

ninja -C . install

cmake -G Ninja -DCMAKE_BUILD_TYPE="Release"   \
      -DLLVM_ENABLE_PROJECTS="clang;lld;libc" \
      -DCMAKE_INSTALL_PREFIX="../../riscv-install"   \
      -DLLVM_BUILD_TESTS=False   \
      -DLLVM_DEFAULT_TARGET_TRIPLE="riscv32-unknown-elf" \
      -DLLVM_ENABLE_LLVM_LIBC=True \
      -DLLVM_ENABLE_RUNTIMES="libc;compiler-rt" \
      -DLLVM_TARGETS_TO_BUILD="RISCV"   ../llvm


cmake -G Ninja -DCMAKE_BUILD_TYPE="Release"   \
      -DLLVM_ENABLE_PROJECTS="clang;lld;libc;compiler-rt" \
      -DCMAKE_INSTALL_PREFIX="../../riscv-install"   \
      -DLLVM_BUILD_TESTS=False   \
      -DLLVM_DEFAULT_TARGET_TRIPLE="riscv32-unknown-elf" \
      -DLLVM_ENABLE_LLVM_LIBC=True \
      -DCOMPILER_RT_BUILD_BUILTINS=ON \
      -DLLVM_TARGETS_TO_BUILD="RISCV" \
      ../llvm


cmake -G Ninja -DCMAKE_BUILD_TYPE="Release"   \
      -DLLVM_ENABLE_PROJECTS="clang;lld" \
      -DCMAKE_INSTALL_PREFIX="../../riscv-llvm-install"   \
      -DLLVM_BUILD_TESTS=False   \
      -DLLVM_DEFAULT_TARGET_TRIPLE="riscv32-unknown-elf" \
      -DLLVM_BINUTILS_INCDIR="../../riscv-gnu-toolchain/binutils/include/" \
      -DLLVM_TARGETS_TO_BUILD="RISCV" \
      ../llvm

      -DDEFAULT_SYSROOT="../../riscv32-elf/riscv32-unknown-elf"  \

./configure --prefix=/config/build/riscv-install --enable-llvm --with-arch=rv32 --with-abi=ilp32

./configure --prefix=/config/build/riscv64-install --enable-llvm --with-arch=rv64ima --with-abi=lp64

	    cmake $(LLVM_SRCDIR)/llvm \
	    -DCMAKE_INSTALL_PREFIX=$(INSTALL_DIR) \
	    -DCMAKE_BUILD_TYPE=Release \
	    -DLLVM_TARGETS_TO_BUILD="RISCV" \
	    -DLLVM_ENABLE_PROJECTS="clang;lld" \
	    -DLLVM_DEFAULT_TARGET_TRIPLE="$(NEWLIB_TUPLE)" \
	    -DLLVM_INSTALL_TOOLCHAIN_ONLY=On \
	    -DLLVM_BINUTILS_INCDIR=$(BINUTILS_SRCDIR)/include \
	    -DLLVM_PARALLEL_LINK_JOBS=4

cmake -G Ninja -DCMAKE_BUILD_TYPE="Release"   \
      -DLLVM_ENABLE_PROJECTS="clang;lld" \
      -DCMAKE_INSTALL_PREFIX="../../riscv-install"   \
      -DLLVM_BUILD_TESTS=False   \
      -DLLVM_DEFAULT_TARGET_TRIPLE="riscv32-unknown-elf" \
      -DLLVM_BINUTILS_INCDIR="../../riscv-gnu-toolchain/binutils/include/" \
      -DLLVM_TARGETS_TO_BUILD="RISCV" \
      ../llvm

          std::string InstrAsm;
      raw_string_ostream OS(InstrAsm);
      MI.print(OS);
      OS.flush();

      errs() << InstrAsm << "\n";