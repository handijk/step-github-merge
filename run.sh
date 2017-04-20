
merge() {
  set -e;

  local token="$1";
  local owner="$2";
  local repo="$3";
  local base="$4";
  local head="$5";
  local commit_message="$6";

  local payload="\"base\":\"$base\"";

  payload="$payload,\"head\":\"$head\"";

  if [ -n "$commit_message" ]; then
    payload="$payload,\"commit_message\":\"$commit_message\"";
  fi;

  payload="{$payload}";

  curl --fail -s -S -X POST https://api.github.com/repos/$owner/$repo/merges \
    -A "wercker-merge-branch" \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Authorization: token $token" \
    -H "Content-Type: application/json" \
    -d "$payload";
}

export_id_to_env_var() {
  set -e;

  local json="$1";
  local export_name="$2";

  local id=$(echo "$json" | $WERCKER_STEP_ROOT/bin/jq ".id");

  info "exporting release id ($id) to environment variable: \$$export_name";

  export $export_name=$id;
}

main() {
  set -e;

  # Assign global variables to local variables
  local token="$WERCKER_GITHUB_MERGE_TOKEN";
  local owner="$WERCKER_GITHUB_MERGE_OWNER";
  local repo="$WERCKER_GITHUB_MERE_REPO";
  local head="$WERCKER_GITHUB_MERGE_HEAD";
  local base="$WERCKER_GITHUB_MERGE_BASE";
  local commit_message="$WERCKER_MERGE_COMMIT_MESSAGE";
  local export_id="$WERCKER_GITHUB_MERGE_EXPORT_ID";

  # Validate variables
  if [ -z "$token" ]; then
    fail "Token not specified; please add a token parameter to the step";
  fi

  if [ -z "$base" ]; then
    fail "Base branch not specified; please add a base parameter to the step";
  fi

  # Set variables to defaults if not set by the user
  if [ -z "$head" ]; then
    head="$WERCKER_GIT_BRANCH";
    info "no head branch was supplied; using current branch: $head";
  fi

  if [ -z "$owner" ]; then
    owner="$WERCKER_GIT_OWNER";
    info "no GitHub owner was supplied; using GitHub owner of build repository: $owner";
  fi

  if [ -z "$repo" ]; then
    repo="$WERCKER_GIT_REPOSITORY";
    info "no GitHub repository was supplied; using GitHub repository of build: $repo";
  fi

  if [ -z "$export_id" ]; then
    export_id="WERCKER_GITHUB_RELEASE_ID";
    info "no export id was supplied, using default value: $export_id";
  fi

  info "starting creating release with tag $tag_name to GitHub repo $owner/$repo";

  # Create the release and save the output from curl
  MERGE_RESPONSE=$(merge \
    "$token" \
    "$owner" \
    "$repo" \
    "$base" \
    "$head" \
    "$commit_message");

  info "finished merging $head with $base to GitHub repo $owner/$repo";

  export_id_to_env_var "$MERGE_RESPONSE" "$export_id";

  info "successfully merged branches on GitHub";
}

# Run the main function
main;