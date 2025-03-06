## qubic 128-bit alignment
```bash
git clone https://github.com/JunyiLiu1994/llvm-project -b align-in-MCObjectStreamer
cd llvm-project
mkdir build
cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE="Release"   \
      -DLLVM_ENABLE_PROJECTS="clang;lld" \
      -DCMAKE_INSTALL_PREFIX="$HOME/build/riscv-install"   \
      -DLLVM_BUILD_TESTS=False   \
      -DLLVM_DEFAULT_TARGET_TRIPLE="riscv32-unknown-elf" \
      -DLLVM_TARGETS_TO_BUILD="RISCV" \
      ../llvm

ninja -C . install
```

- Then add `~/build/riscv-install` to $PATH
```bash
echo "export PATH=$HOME/build/riscv-install/bin:$PATH" >> ~/.bashrc
source ~/.bashrc
```

- Test
```bash
clang --version
```