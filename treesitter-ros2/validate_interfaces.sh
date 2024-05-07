#!/usr/bin/env bash

RED='\033[0;31m'
NC='\033[0m' # No Color

report_error() {
  echo -e "${RED}$1${NC}"
}

interfaces_path=$1


if [ ! -e "${interfaces_path}" ]; then
  report_error "Provided path does not exist ${interfaces_path}"
  exit 1
fi

if [ -d "${interfaces_path}" ]; then
  echo "Searching for interfaces files in ${interfaces_path}"
  INTERFACES_FILES=$(find "${interfaces_path}" -type f \( -name "*.msg" -o -name "*.srv" -o -name "*.action" \))
else
  file_extension="${1##*.}"
  case "$file_extension" in
    "msg" | "srv" | "action")
      INTERFACES_FILES=${interfaces_path}
      ;;
    *)
      report_error "Provided file is not a ROS 2 interface file."
      exit 1
      ;;
  esac
fi

errors_found="false"
# Iterate over all found ROS 2 interfaces
for file in ${INTERFACES_FILES}; do
    # Add your commands here
    if tree-sitter parse "${file}" | grep -q "ERROR"; then
      report_error "Invalid ROS 2 interface file: ${file}"
      errors_found="true"
    fi
done

if [ "${errors_found}" == "true" ]; then
  exit 1
fi

