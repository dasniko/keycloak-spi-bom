#!/usr/bin/env bash
# Updates library versions in pom.xml from the actual Keycloak Docker distribution.
#
# Pulls the latest Keycloak container image, reads the JAR filenames from
# /opt/keycloak/lib/lib/main (the definitive runtime classpath), derives
# the library versions from those filenames, then updates pom.xml accordingly.
# The container is removed immediately after the directory listing.
#
# Requirements: curl, docker, jq, sed (POSIX)
# Usage: ./update-versions.sh

set -euo pipefail

GITHUB_API="https://api.github.com/repos/keycloak/keycloak/releases/latest"
KC_IMAGE="quay.io/keycloak/keycloak"
KC_LIB_PATH="/opt/keycloak/lib/lib/main"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POM_XML="${SCRIPT_DIR}/pom.xml"

command -v curl   >/dev/null 2>&1 || { echo "Error: curl is required" >&2;   exit 1; }
command -v docker >/dev/null 2>&1 || { echo "Error: docker is required" >&2; exit 1; }
command -v jq     >/dev/null 2>&1 || { echo "Error: jq is required" >&2;     exit 1; }

# --- helpers -----------------------------------------------------------------

# Extract the version from a JAR filename by stripping the known artifact
# prefix and the .jar suffix.  The version starts at the first digit after
# the last hyphen that belongs to the artifact name.
# Usage: jar_version <artifact-prefix> <newline-separated-file-list>
# Example: jar_version "slf4j-api" "$libs"  →  "2.0.17"
jar_version() {
	local prefix="$1"
	local prefix_re="${prefix//./\\.}"  # escape dots for sed BRE
	printf '%s\n' "$2" \
		| { grep "^${prefix}-[0-9]" || true; } \
		| sed "s/^${prefix_re}-\(.*\)\.jar$/\1/" \
		| head -1
}

# Update a <property>value</property> entry in pom.xml in-place.
update_prop() {
	local prop="$1"
	local version="$2"
	local prop_re="${prop//./\\.}"
	if grep -q "<${prop}>" "${POM_XML}"; then
		sed -i.bak "s|<${prop_re}>[^<]*</${prop_re}>|<${prop}>${version}</${prop}>|g" "${POM_XML}"
		rm -f "${POM_XML}.bak"
		echo "  ${prop} → ${version}"
	else
		echo "  ${prop}: not found in pom.xml, skipped"
	fi
}

# --- 1. Get latest Keycloak version ------------------------------------------

echo "Fetching latest Keycloak release..."
kc_version=$(curl -sf --max-time 30 "${GITHUB_API}" | jq -r '.tag_name')
[ -z "${kc_version}" ] && { echo "Error: could not read tag_name from GitHub API" >&2; exit 1; }
echo "  → ${kc_version}"

# --- 2. Pull image and read lib directory from a temporary container ---------

echo ""
echo "Reading ${KC_LIB_PATH}..."
libs=$(docker run --rm --entrypoint /bin/bash "${KC_IMAGE}:${kc_version}" -c "ls ${KC_LIB_PATH}")
echo "  Got $(printf '%s\n' "${libs}" | wc -l | tr -d ' ') files."

# --- 3. Extract versions from JAR filenames ----------------------------------

echo ""
echo "Resolving versions from JAR filenames..."

# JAR files use {groupId}.{artifactId}-{version}.jar naming convention.
v_quarkus=$(jar_version       "io.quarkus.quarkus-rest"                  "${libs}")
v_caffeine=$(jar_version      "com.github.ben-manes.caffeine.caffeine"   "${libs}")
v_commons_codec=$(jar_version "commons-codec.commons-codec"              "${libs}")
v_commons_io=$(jar_version    "commons-io.commons-io"                    "${libs}")
v_commons_lang=$(jar_version  "org.apache.commons.commons-lang3"         "${libs}")
v_guava=$(jar_version         "com.google.guava.guava"                   "${libs}")
v_httpclient=$(jar_version    "org.apache.httpcomponents.httpclient"      "${libs}")
v_micrometer=$(jar_version    "io.micrometer.micrometer-core"            "${libs}")
v_slf4j=$(jar_version         "org.slf4j.slf4j-api"                      "${libs}")

echo "  keycloak.version      = ${kc_version}"
[ -n "${v_quarkus}" ]       && echo "  quarkus.version       = ${v_quarkus}"       || echo "  quarkus.version       : JAR not found — skipped"
[ -n "${v_caffeine}" ]      && echo "  caffeine.version      = ${v_caffeine}"      || echo "  caffeine.version      : JAR not found — skipped"
[ -n "${v_commons_codec}" ] && echo "  commons-codec.version = ${v_commons_codec}" || echo "  commons-codec.version : JAR not found — skipped"
[ -n "${v_commons_io}" ]    && echo "  commons-io.version    = ${v_commons_io}"    || echo "  commons-io.version    : JAR not found — skipped"
[ -n "${v_commons_lang}" ]  && echo "  commons-lang.version  = ${v_commons_lang}"  || echo "  commons-lang.version  : JAR not found — skipped"
[ -n "${v_guava}" ]         && echo "  guava.version         = ${v_guava}"         || echo "  guava.version         : JAR not found — skipped"
[ -n "${v_httpclient}" ]    && echo "  httpclient.version    = ${v_httpclient}"    || echo "  httpclient.version    : JAR not found — skipped"
[ -n "${v_micrometer}" ]    && echo "  micrometer.version    = ${v_micrometer}"    || echo "  micrometer.version    : JAR not found — skipped"
[ -n "${v_slf4j}" ]         && echo "  slf4j.version         = ${v_slf4j}"         || echo "  slf4j.version         : JAR not found — skipped"

# --- 4. Update pom.xml -------------------------------------------------------

echo ""
echo "Updating ${POM_XML}..."

update_prop "keycloak.version"      "${kc_version}"
[ -n "${v_quarkus}" ]       && update_prop "quarkus.version"       "${v_quarkus}"
[ -n "${v_caffeine}" ]      && update_prop "caffeine.version"      "${v_caffeine}"
[ -n "${v_commons_codec}" ] && update_prop "commons-codec.version" "${v_commons_codec}"
[ -n "${v_commons_io}" ]    && update_prop "commons-io.version"    "${v_commons_io}"
[ -n "${v_commons_lang}" ]  && update_prop "commons-lang.version"  "${v_commons_lang}"
[ -n "${v_guava}" ]         && update_prop "guava.version"         "${v_guava}"
[ -n "${v_httpclient}" ]    && update_prop "httpclient.version"    "${v_httpclient}"
[ -n "${v_micrometer}" ]    && update_prop "micrometer.version"    "${v_micrometer}"
[ -n "${v_slf4j}" ]         && update_prop "slf4j.version"         "${v_slf4j}"

echo ""
echo "Done. Review changes with: git diff pom.xml"
