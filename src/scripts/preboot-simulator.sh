xcode_major=$(/usr/bin/xcodebuild -version | awk 'NR==1{print $2}' | cut -d. -f1)
if [[ $xcode_major -ge "12" ]]; then
  ESCAPED_VER=$(echo << parameters.version >> | tr '.' '-')
  SIMLIST=$(xcrun simctl list -j)
  UDID=$(echo $SIMLIST | jq -r ".devices.\"com.apple.CoreSimulator.SimRuntime.<< parameters.platform >>-$ESCAPED_VER\"[] | select(.name==\"<< parameters.device >>\").udid")
  echo "export <<parameters.device-udid-var>>=$UDID" >> $BASH_ENV
  xcrun simctl boot $UDID
else
  xcrun instruments -w "<< parameters.device >> (<< parameters.version >>) [" || true
fi
