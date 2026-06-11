#!/usr/bin/env bash
# lint-section-refs.sh — verify cross-file §-references in this rule-set
# resolve to an existing numbered heading in the referenced file.
#
# Checks (over tracked *.md files):
#   1. Filename-qualified refs — "<Name>.md §N[.N…]" or "<Name>.md section N"
#      (also "sections N", first number only) → numbered heading exists in the
#      target file. Batch.md resolves to the /core:batch SKILL.md; all other
#      names resolve to rules/<Name>.md.
#   2. Skill-qualified refs — "/plugin:skill §N" → heading exists in that
#      skill's SKILL.md under the local marketplace.
#   3. Ledger completeness — every tracked local-plugin SKILL.md is listed in
#      the CLAUDE.md skill ledger as /plugin:skill.
#
# Limitations (by design): bare same-file "§N" refs are not checked (too many
# implicit-context refs); a ref that resolves to an EXISTING heading with the
# WRONG meaning cannot be detected; in "sections X and Y" enumerations only X
# is checked — prefer one fully-qualified ref per section number.
#
# Exit 1 on any failure. Bypass: SKIP_REF_LINT=1.

set -uo pipefail
cd "$(git rev-parse --show-toplevel)" || exit 1
[[ "${SKIP_REF_LINT:-0}" == "1" ]] && exit 0

PLUGIN_ROOT="plugins/marketplaces/local/plugins"

resolve_target() {
    case "$1" in
        Batch) echo "$PLUGIN_ROOT/core/skills/batch/SKILL.md" ;;
        General|Meta|Persona|CleanCode|PER|Twig|TYPO3) echo "rules/$1.md" ;;
        *) echo "" ;;
    esac
}

heading_exists() { # $1=file $2=section number
    local esc="${2//./\\.}"
    grep -qE "^#{1,6}[[:space:]]+§?${esc}([.[:space:]]|$)" "$1"
}

FAIL=0
report() { echo "REF-LINT: $1"; FAIL=1; }

RE_FILE='(General|Meta|Persona|CleanCode|PER|Twig|TYPO3|Batch)\.md`?[[:space:]]*(§|sections?)[[:space:]]*`?[0-9]+(\.[0-9]+)*'
RE_SKILL='/(core|typo3):[a-z0-9-]+`?[[:space:]]+(skill[[:space:]]+)?§[[:space:]]*[0-9]+(\.[0-9]+)*'

while IFS= read -r f; do
    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        line="${hit%%:*}"; m="${hit#*:}"
        name=$(printf '%s' "$m" | sed -E 's/^([A-Za-z0-9]+)\.md.*/\1/')
        num=$(printf '%s' "$m" | sed -E 's/.*(§|sections?)[[:space:]]*`?//; s/[^0-9.].*$//; s/\.$//')
        tgt=$(resolve_target "$name")
        if [[ -z "$tgt" || ! -f "$tgt" ]]; then
            report "$f:$line: unresolvable target for '$m'"
            continue
        fi
        heading_exists "$tgt" "$num" || report "$f:$line: $name.md §$num does not exist ('$m')"
    done < <(grep -noE "$RE_FILE" "$f" 2>/dev/null)

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        line="${hit%%:*}"; m="${hit#*:}"
        plugin=$(printf '%s' "$m" | sed -E 's|^/([a-z0-9-]+):.*|\1|')
        skill=$(printf '%s' "$m" | sed -E 's|^/[a-z0-9-]+:([a-z0-9-]+).*|\1|')
        num=$(printf '%s' "$m" | sed -E 's/.*§[[:space:]]*//; s/[^0-9.].*$//; s/\.$//')
        tgt="$PLUGIN_ROOT/$plugin/skills/$skill/SKILL.md"
        if [[ ! -f "$tgt" ]]; then
            report "$f:$line: skill file missing for '$m'"
            continue
        fi
        heading_exists "$tgt" "$num" || report "$f:$line: /$plugin:$skill §$num does not exist ('$m')"
    done < <(grep -noE "$RE_SKILL" "$f" 2>/dev/null)
done < <(git ls-files '*.md')

# Check 3: every tracked local-plugin skill is in the CLAUDE.md ledger.
for sk in "$PLUGIN_ROOT"/*/skills/*/SKILL.md; do
    [[ -f "$sk" ]] || continue
    git ls-files --error-unmatch "$sk" >/dev/null 2>&1 || continue
    plugin=$(basename "$(dirname "$(dirname "$(dirname "$sk")")")")
    skill=$(basename "$(dirname "$sk")")
    grep -q "/$plugin:$skill" CLAUDE.md \
        || report "ledger: /$plugin:$skill ($sk) is not listed in CLAUDE.md"
done

if [[ $FAIL -eq 1 ]]; then
    echo "REF-LINT: failures found — fix the references or rerun with SKIP_REF_LINT=1." >&2
    exit 1
fi
echo "REF-LINT: ok"
