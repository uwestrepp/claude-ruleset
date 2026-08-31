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
#   6. Always-on budget coverage + token budgets — Meta.md §3.3 trip-wire:
#      every member of every always-on surface (rule files, CLAUDE.md, skill
#      and agent descriptions) must map to a budget entry or an explicit
#      unbudgeted marker — fail closed — and its estimated tokens (chars/3.8)
#      must stay under that budget; raise a budget only via explicit user
#      decision.
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
        General|Meta|Persona|Organisation|CleanCode|PER|Twig|TYPO3) echo "rules/$1.md" ;;
        *) echo "" ;;
    esac
}

heading_exists() { # $1=file $2=section number
    local esc="${2//./\\.}"
    # NOTE: the optional § must be a GROUP quantifier "(§)?". A bare "§?" puts the
    # quantifier on the last BYTE of the multibyte char in GNU grep/sed, making the
    # first byte mandatory — every §-less numbered heading then fails to match.
    # (ugrep quantifies the full character; do not "simplify" this back.)
    grep -qE "^#{1,6}[[:space:]]+(§)?${esc}([.[:space:]]|$)" "$1"
}

extract_headings() { # stdin = markdown; emits "<number>\t<title>" for numbered headings
    # group quantifier for §, see heading_exists — capture groups shift accordingly
    sed -nE 's/^#{1,6}[[:space:]]+(§)?([0-9]+(\.[0-9]+)*)[.]?[[:space:]]+(.*)$/\2\t\4/p'
}

FAIL=0
report() { echo "REF-LINT: $1"; FAIL=1; }

RE_FILE='(General|Meta|Persona|Organisation|CleanCode|PER|Twig|TYPO3|Batch)\.md`?[[:space:]]*(§|sections?)[[:space:]]*`?[0-9]+(\.[0-9]+)*'
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

# Check 6: always-on budget COVERAGE + token budgets (Meta.md §3.3 trip-wire).
#
# WHICH surfaces are always-on is decided in Meta.md §3.3; that prose is
# deliberately NOT parsed — the surface list below is maintained by hand and
# MUST be updated in the same change-set as §3.3. What IS enumerated
# mechanically is the MEMBERS of each surface, so a newly added rule file,
# skill, or agent cannot slip in unmeasured — that hole is what this check
# exists to close (skill + agent descriptions sat ungoverned until 2026-08-31).
#
#   S1 always-on rule files — members: the @<path> imports in CLAUDE.md
#   S2 the CLAUDE.md index  — member:  CLAUDE.md itself
#   S3 skill descriptions   — members: tracked local-plugin SKILL.md frontmatter
#   S4 agent descriptions   — members: tracked agents/*.md frontmatter
#
# Coverage rule: every enumerated member must map to a FILE_BUDGETS key, an
# AGG_BUDGETS bucket, or an UNBUDGETED marker. An unmapped member fails.
declare -A FILE_BUDGETS=(
    [rules/General.md]=10500
    [rules/Meta.md]=4500
    [rules/Persona.md]=1000
    [rules/Organisation.md]=600
    [CLAUDE.md]=3100
)
declare -A AGG_BUDGETS=(
    [skill-descriptions]=3700
    [agent-descriptions]=470
)
# Always-on members deliberately left unbudgeted, with the reason.
declare -A UNBUDGETED=(
    [CLAUDE.local.md]="machine-local and gitignored — outside a repo lint's reach"
)

est_tokens() { echo $(( $1 * 10 / 38 )); }

check_file_budget() { # $1=path $2=budget
    local est; est=$(est_tokens "$(wc -c < "$1")")
    (( est > $2 )) && report "$1: ~${est} estimated tokens exceeds always-on budget $2 (Meta.md §3.3) — demote content or raise the budget via explicit user decision"
    return 0
}

# S1 + S2: per-file budgets, coverage-checked against the actual import list.
while IFS= read -r m; do
    [[ -n "${UNBUDGETED[$m]+x}" ]] && continue
    [[ -n "${FILE_BUDGETS[$m]+x}" ]] \
        || report "$m: always-on file has no budget entry — add it to FILE_BUDGETS or UNBUDGETED in this script (Meta.md §3.3)"
done < <(printf '%s\n' "$(grep -oE '@[^ `]+\.md' CLAUDE.md | sed 's/^@//')" CLAUDE.md)

for f in "${!FILE_BUDGETS[@]}"; do
    if [[ ! -f "$f" ]]; then
        # Fail closed: a renamed/removed budgeted file must not silently drop
        # budget enforcement — update FILE_BUDGETS in the same change-set.
        report "$f: budgeted always-on file missing — update the budget table in this script if it was renamed/removed (Meta.md §3.3)"
        continue
    fi
    check_file_budget "$f" "${FILE_BUDGETS[$f]}"
done

# S3 + S4: frontmatter descriptions, budgeted in aggregate per surface. Members
# are enumerated, so a new skill/agent joins its bucket automatically.
# A naive sed range runs past the closing --- on multi-line values; this is a
# frontmatter state machine (0=pre, 1=in fm, 2=in description, 3=done).
FM_DESC_AWK='
FNR==1 { if (fn != "") print fn "\t" n; fn=FILENAME; n=0; st=0 }
st==3 { next }
st==0 { if ($0 ~ /^---[ \t]*$/) st=1; next }
$0 ~ /^---[ \t]*$/ { st=3; next }
st==1 && $0 ~ /^description:/ { v=$0; sub(/^description:[ \t]*/,"",v); n=length(v); st=2; next }
st==2 { if ($0 ~ /^[A-Za-z_-]+:/) st=1; else n += length($0)+1 }
END { if (fn != "") print fn "\t" n }
'
check_description_surface() { # $1=bucket name $2...=files
    local bucket="$1"; shift
    (( $# == 0 )) && { report "$bucket: no members found — the enumeration broke, budget coverage is unverifiable"; return 0; }
    local sum=0 f n est
    while IFS=$'\t' read -r f n; do
        (( n == 0 )) && report "$f: no frontmatter description — always-on surface member cannot be measured"
        sum=$(( sum + n ))
    done < <(awk "$FM_DESC_AWK" "$@")
    est=$(est_tokens "$sum")
    (( est > AGG_BUDGETS[$bucket] )) && report "$bucket: ~${est} estimated tokens across $# files exceeds always-on budget ${AGG_BUDGETS[$bucket]} (Meta.md §3.3) — shorten descriptions or raise the budget via explicit user decision"
    return 0
}
mapfile -t _skill_files < <(git ls-files "$PLUGIN_ROOT/*/skills/*/SKILL.md")
mapfile -t _agent_files < <(git ls-files 'agents/*.md')
check_description_surface skill-descriptions "${_skill_files[@]}"
check_description_surface agent-descriptions "${_agent_files[@]}"

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
