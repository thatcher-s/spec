# Task runner. Requires `just`, `uv` and `claude`.

default:
    @just --list

# One-time setup after cloning: install the pre-push hook
init:
    prek install --hook-type pre-push

# Validate the plugin and marketplace manifests
validate:
    claude plugin validate .

# Add a release-note fragment, e.g. `just fragment fixed "Audit names the right file"`
fragment category description:
    uvx --from git+https://github.com/thatcher-s/release-fragments@v0.3.0 \
        release add {{ category }} "{{ description }}"
