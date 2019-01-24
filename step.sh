#!/bin/bash
set -ex

#=======================================
# Main
#=======================================

#step_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
temp_path=$PWD

echo "building universal apk path"
echo "Getting app bundle from ${aab_path}"
echo "Signing with ${keystore_url} key and alias ${keystore_alias}"

bundletool="${temp_path}/bundletool.jar"
keystore="${temp_path}/keystore.jks"
source="https://github.com/google/bundletool/releases/download/0.8.0/bundletool-all-0.8.0.jar"


# Building
aab_output_path="${temp_path}/output/bundle"
aab_output="${aab_output_path}/app.apks"
apk_output_path="${temp_path}/output/apk"
apk_output="${apk_output_path}/universal.apk"

mkdir -p "${aab_output_path}" &
mkdir -p "${apk_output_path}" &
wait
curl -o "keystore.jks" "${keystore_url}" &
wget "${source}" --output-document="${bundletool}" &
wait
exec java -jar "${bundletool}" build-apks --bundle="${aab_path}" --output="${aab_output}" --mode=universal --ks=${keystore} --ks-pass=pass:"${keystore_password}" --ks-key-alias="${keystore_alias}" --key-pass=pass:"${keystore_alias_password}" &
wait
echo "APK created in ${apk_output_path}"
exec unzip ${aab_output} -d ${apk_output_path} &

envman add --key BITRISE_APK_PATH --value ${apk_output}

echo
exit 0
