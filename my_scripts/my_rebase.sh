#/usr/bin/env bash

set -eu

APPLY_BRANCH="hnyman-build-apply"

R7800_BRANCH="hnyman-new"
LAST_R7800_BASE="hnyman-new-base"

R4S_BRANCH="r4s"
LAST_R4S_BASE="r4s-base"

function is_ancestor() {
	git merge-base --is-ancestor "$1" "$2"
	echo "$?"
}

function rebase() {
	local branch="$1"
	local new_base="$2"
	local old_base="$3"

	if [[ $(is_ancestor "${new_base}" "${branch}") == "0" ]]; then
		>&2 echo "${branch} is already up to date with ${new_base}"
	else
		git co "${branch}"
		git rebase --onto "${new_base}" "${old_base}"
		git branch -f "${old_base}" "${new_base}"
	fi
}

# update R7800 branch
>&2 echo "Rebasing R7800 branch"
rebase "${R7800_BRANCH}" "${APPLY_BRANCH}" "${LAST_R7800_BASE}"

# update R4S branch
>&2 echo "Rebasing R4s branch"
rebase "${R4S_BRANCH}" "${R7800_BRANCH}" "${LAST_R4S_BASE}"
