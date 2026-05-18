FILE="path/to/lit/file"

EXPECTED=$(mktemp)
ACTUAL=$(mktemp)

# Find expected warning lines from CHECK-MESSAGES
awk '
/CHECK-MESSAGES/ {
    idx = index($0, "@LINE-");
    if (idx > 0) {
        s = substr($0, idx + 6);
        match(s, /^[0-9]+/);
        offset = substr(s, RSTART, RLENGTH);
        print NR - offset;
    }
}
' "$FILE" | sort -n > "$EXPECTED"

# Run clang-tidy and get actual warning lines
bin/clang-tidy \
  -checks="-*,name-of-check" \
  "$FILE" -- \
  -std=c++17 2>&1 | \
grep "warning:" | \
sed -E 's/^.*:([0-9]+):[0-9]+: warning:.*$/\1/' | \
sort -n > "$ACTUAL"

echo "EXPECTED"
cat "$EXPECTED"

echo
echo "ACTUAL"
cat "$ACTUAL"

echo
echo "DIFF"
diff -u "$EXPECTED" "$ACTUAL"

rm "$EXPECTED" "$ACTUAL"
