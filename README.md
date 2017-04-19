# GitHub merge step

A wercker step for merging Github branches. It has a few parameters, but only two are required: `token` and `base`. See [Creating a GitHub token](#creating-a-github-token).

This step will export the id of the merge in an environment variable (default: `$WERCKER_GITHUB_MERGE_ID`). This allows other steps to use this merge, like the github-upload-asset step.

Currently this step does not do any json escaping. So be careful when using quotes or newlines in parameters.

More information about GitHub merging:

- https://developer.github.com/v3/repos/merging/

# Example

A minimal example, this will get the token from a environment variable and use the hardcoded develop branch:

``` yaml
deploy:
    steps:
        - github-merge:
            token: $GITHUB_TOKEN
            base: develop
```

# Common problems

## curl: (22) The requested URL returned error: 400

GitHub has rejected the call. Most likely invalid json was used. Check to see if any of the parameters need escaping (quotes and new lines).

## curl: (22) The requested URL returned error: 401

The `token` is not valid. If using a protected environment variable, check if the token is inside the environment variable.

## curl: (22) The requested URL returned error: 422

GitHub rejected the API call.

## curl: (22) The requested URL returned error: 409

Merge conflict.

# Creating a GitHub token

To be able to use this step, you will first need to create a GitHub token with an account which has enough permissions to be able to create releases. First goto `Account settings`, then goto `Applications` for the user. Here you can create a token in the `Personal access tokens` section. For a private repository you will need the `repo` scope and for a public repository you will need the `public_repo` scope. Then it is recommended to save this token on wercker as a protected environment variable.

# What's new

- Initial release.

# Options

- `token` The token used to make the requests to GitHub. See [Creating a GitHub token](#creating-a-github-token).
- `base` The name of the base branch that the head will be merged into.
- `head` (optional) The head to merge. This can be a branch name or a commit SHA1. Defaults to the current branch.
- `owner` (optional) The GitHub owner of the repository. Defaults to `$WERCKER_GIT_OWNER`, which is the GitHub owner of the original build.
- `repo` (optional) The name of the GitHub repository. Defaults to `$WERCKER_GIT_REPOSITORY`, which is the repository of the original build.
- `commit_message` (optional) Commit message to use for the merge commit. If omitted, a default message will be used. (make sure this is json encoded, see [TODO](#todo))
- `export-id` (optional) After the release is created, a release id will be made available in the environment variable identifier in this environment variable. Defaults to `WERCKER_GITHUB_CREATE_RELEASE_ID`.

# TODO

- Create better error handling for invalid token and merge conflict.
- Escape user input to be valid json.
- Make sure `export_id` contains a valid environment variable identifier.

# License

The MIT License (MIT)

# Changelog

## 1.0.1

- Initial release.
