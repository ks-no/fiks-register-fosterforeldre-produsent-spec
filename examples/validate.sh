#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SCHEMA="${REPO_ROOT}/meldinger/MeldingOmEndringAvOmsorgsansvar_v1.0.xsd"

if ! command -v xmllint >/dev/null 2>&1; then
  echo "Error: xmllint is not installed." >&2
  exit 1
fi

if [[ ! -f "${SCHEMA}" ]]; then
  echo "Error: Schema not found: ${SCHEMA}" >&2
  exit 1
fi

shopt -s nullglob
xml_files=("${SCRIPT_DIR}"/*.xml)

if [[ ${#xml_files[@]} -eq 0 ]]; then
  echo "No XML files found in ${SCRIPT_DIR}" >&2
  exit 1
fi

for xml in "${xml_files[@]}"; do
  echo "Validating $(basename "${xml}")"
  xmllint --noout --schema "${SCHEMA}" "${xml}"
done

echo "All example XML files validated successfully."

