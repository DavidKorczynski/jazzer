#!/usr/bin/env bash
# Copyright 2021 Code Intelligence GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2.
set -uo pipefail; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
#--- end runfiles.bash initialization v2 ---

# Disable `set -e` activated by the runfiles script above as it breaks our crash
# detection.
set +e

# Crashes will be available as test outputs. These are cleared on the next run,
# so this is only useful for examples.
DEFAULT_CRASH_PREFIX="$TEST_UNDECLARED_OUTPUTS_DIR"

eval -- $(rlocation "$1") -artifact_prefix="$DEFAULT_CRASH_PREFIX/" --reproducer_path="$DEFAULT_CRASH_PREFIX" -seed=2735196724 "${@:2}"
# Assert that we either found a crash in java (exit code 77) or an ASan crash
# (exit code 76).
declare -i exit_code=$?
if [ $exit_code -eq 77 ] || [ $exit_code -eq 76 ]
then
  if [ "$(ls "$DEFAULT_CRASH_PREFIX/")" ]; then
    exit 0
  else
    exit 1
  fi
else
  echo "Unexpected exit code: $exit_code"
  exit 1
fi
