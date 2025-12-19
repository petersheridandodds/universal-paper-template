#!/bin/zsh
## checkrefs.sh -- Summarize LaTeX reference/citation/label issues (zsh-safe)
## Usage: ./checkrefs.sh archetypometrics-manuscript.log

LOGFILE="$1"
if [[ -z "$LOGFILE" || ! -f "$LOGFILE" ]]; then
  echo "Usage: $0 path/to/latex.log"
  exit 1
fi

## Helpers
print_section() {
  local title="$1" data="$2"
  echo "=== $title ==="
  if [[ -n "$data" ]]; then
    echo "$data" | sed 's/^/  /'
  else
    echo "  (none)"
  fi
  echo
}

## 1) Undefined references
refs=$(
awk '
/LaTeX Warning: Reference/ {
  p = index($0, "Reference `");
  if (p > 0) {
    s = substr($0, p + length("Reference `"));
    q = index(s, "'\''");
    if (q > 0) print substr(s, 1, q - 1);
  }
}
' "$LOGFILE" | sort -u
)

## 2) Undefined citations
cites=$(
awk '
/LaTeX Warning: Citation/ {
  p = index($0, "Citation `");
  if (p > 0) {
    s = substr($0, p + length("Citation `"));
    q = index(s, "'\''");
    if (q > 0) print substr(s, 1, q - 1);
  }
}
' "$LOGFILE" | sort -u
)

## 3) Multiply defined labels (with counts)
dups=$(
awk '
/LaTeX Warning: Label/ {
  p = index($0, "Label `");
  if (p > 0) {
    s = substr($0, p + length("Label `"));
    q = index(s, "'\''");
    if (q > 0) print substr(s, 1, q - 1);
  }
}
' "$LOGFILE" | sort | uniq -c | sort -nr
)

print_section "Undefined references" "$refs"
print_section "Undefined citations"  "$cites"
print_section "Multiply defined labels" "$dups"
