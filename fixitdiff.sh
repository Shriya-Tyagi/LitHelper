FILE="path/to/your/lit/test/file"

TMP=$(mktemp /tmp/fixit.XXXXXX.cpp)

cp "$FILE" "$TMP"

bin/clang-tidy \
  -checks="-*,your-check" \
  -fix -fix-errors \
  "$TMP" -- \
  -std=c++17 >/dev/null 2>&1      #i added c++17 becuase I was working on a modernize check which needed it.

awk '
BEGIN {
    actual_idx = 0
}

/CHECK-FIXES:/ {
    expected = $0
    sub(/^.*CHECK-FIXES: */, "", expected)

    line = NR - 1

    while ((getline actual_line < ARGV[1]) > 0) {
        actual_idx++
        if (actual_idx == line) {
            break
        }
    }

    if (expected != actual_line) {
        print "///////////////////////////////////////////////////////////////"
        print "Mismatch near source line:", line
        print "EXPECTED:"
        print expected
        print "ACTUAL:"
        print actual_line
        print
    }
}
' "$TMP" "$FILE"

rm "$TMP"
