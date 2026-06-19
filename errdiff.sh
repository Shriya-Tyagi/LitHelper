bin/llvm-lit -sv \
  ../clang-tools-extra/test/clang-tidy/checkers/module/test-file.cpp \
  2>&1 | grep -A3 "error: CHECK-"
