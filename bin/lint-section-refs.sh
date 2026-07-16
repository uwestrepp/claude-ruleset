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
#   4. Same-file refs (rules/*.md only) — a bare "§N" with no cross-file
#      qualifier on its line must resolve to a heading in the same file. Scoped
#      to rules/ because there cross-file refs are filename-qualified, so a bare
#      §N reliably means "this file"; skills use wrapped/under-qualified bare
#      refs and are intentionally excluded.
#   5. Heading immutability — numbered headings are stable anchors: fail if a
#      number present at HEAD was removed/renumbered or had its title changed
#      (pure additions are allowed). This is what catches insert-and-shift
#      drift that checks 1–2 cannot (a still-existing number with new meaning).
#   6. Always-on token budgets — Meta.md §3.3 trip-wire: estimated tokens
#      (chars/3.8) per always-on file must stay under its budget; raise a
#      budget only via explicit user decision.
#
# Limitations (by design): same-file check is rules/-only and line-based, so a
# bare §N sharing a line with a cross-file qualifier is skipped; a cross-file
# ref that resolves to an EXISTING heading with the WRONG meaning is still
# undetectable at the reference site (check 5 guards the heading side instead);
# in "sections X and Y" enumerations only X is checked — prefer one
# fully-qualified ref per section number.
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

extract_headings() { # stdin = markdown; emits "<number>\t<title>" for numbered headings
    sed -nE 's/^#{1,6}[[:space:]]+§?([0-9]+(\.[0-9]+)*)[.]?[[:space:]]+(.*)$/\1\t\3/p'
}

FAIL=0
report() { echo "REF-LINT: $1"; FAIL=1; }

RE_FILE='(General|Meta|Persona|CleanCode|PER|Twig|TYPO3|Batch)\.md`?[[:space:]]*(§|sections?)[[:space:]]*`?[0-9]+(\.[0-9]+)*'
RE_SKILL='/(core|typo3|composer|pocock):[a-z0-9-]+`?[[:space:]]+(skill[[:space:]]+)?§[[:space:]]*[0-9]+(\.[0-9]+)*'

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

    # Check 4: same-file bare §N refs (rules/*.md only; skip lines bearing a
    # cross-file qualifier — those are handled by checks 1–2).
    if [[ "$f" == rules/*.md ]]; then
        while IFS= read -r ln; do
            line="${ln%%:*}"; text="${ln#*:}"
            case "$text" in *.md*|*/core:*|*/typo3:*|*/composer:*|*/pocock:*) continue ;; esac
            for num in $(printf '%s' "$text" | grep -oE '§[[:space:]]*[0-9]+(\.[0-9]+)*' | sed -E 's/§[[:space:]]*//'); do
                heading_exists "$f" "$num" || report "$f:$line: same-file §$num has no heading in $f"
            done
        done < <(grep -nE '§[[:space:]]*[0-9]' "$f")
    fi

    # Check 5: numbered headings are immutable anchors vs HEAD.
    if git cat-file -e "HEAD:$f" 2>/dev/null; then
        declare -A _hm=() _wm=()
        while IFS=$'\t' read -r n t; do [[ -n "$n" ]] && _hm["$n"]="$t"; done < <(git show "HEAD:$f" | extract_headings)
        while IFS=$'\t' read -r n t; do [[ -n "$n" ]] && _wm["$n"]="$t"; done < <(extract_headings < "$f")
        for n in "${!_hm[@]}"; do
            if [[ -z "${_wm[$n]+x}" ]]; then
                report "$f: §$n removed/renumbered vs HEAD ('${_hm[$n]}') — numbers are stable anchors; if intentional, bypass with SKIP_REF_LINT=1"
            elif [[ "${_wm[$n]}" != "${_hm[$n]}" ]]; then
                report "$f: §$n title changed vs HEAD ('${_hm[$n]}' -> '${_wm[$n]}') — if a deliberate rename, bypass with SKIP_REF_LINT=1"
            fi
        done
        unset _hm _wm
    fi
done < <(git ls-files '*.md')

# Check 6: always-on token budgets (Meta.md §3.3 trip-wire).
declare -A BUDGETS=(
    [rules/General.md]=10500
    [rules/Meta.md]=4500
    [rules/Persona.md]=1000
    [CLAUDE.md]=3000
)
for f in "${!BUDGETS[@]}"; do
    if [[ ! -f "$f" ]]; then
        # Fail closed: a renamed/removed budgeted file must not silently drop
        # budget enforcement — update the BUDGETS table in the same change-set.
        report "$f: budgeted always-on file missing — update the budget table in this script if it was renamed/removed (Meta.md §3.3)"
        continue
    fi
    est=$(( $(wc -c < "$f") * 10 / 38 ))
    if (( est > BUDGETS[$f] )); then
        report "$f: ~${est} estimated tokens exceeds always-on budget ${BUDGETS[$f]} (Meta.md §3.3) — demote content or raise the budget via explicit user decision"
    fi
done

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
