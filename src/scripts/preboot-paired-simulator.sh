xcode_major=$(/usr/bin/xcodebuild -version | awk 'NR==1{print $2}' | cut -d. -f1)
if [[ $xcode_major -ge "12" ]]; then
  ESCAPED_IPHONE_VER=$(echo << parameters.iphone-version >> | tr '.' '-')
  ESCAPED_WATCHOS_VER=$(echo << parameters.watch-version >> | tr '.' '-')
  SIMLIST=$(xcrun simctl list -j)
  IPHONE_UDID=$(echo $SIMLIST | jq -r ".devices.\"com.apple.CoreSimulator.SimRuntime.iOS-$ESCAPED_IPHONE_VER\"[] | select(.name==\"<< parameters.iphone-device >>\").udid")
  echo "export <<parameters.iphone-device-udid-var>>=$IPHONE_UDID" >> $BASH_ENV
  WATCH_UDID=$(echo $SIMLIST | jq -r ".devices.\"com.apple.CoreSimulator.SimRuntime.watchOS-$ESCAPED_WATCHOS_VER\"[] | select(.name==\"<< parameters.watch-device >>\").udid")
  echo "export <<parameters.watch-device-udid-var>>=$WATCH_UDID" >> $BASH_ENV
  PAIR_UDID=$(xcrun simctl pair $WATCH_UDID $IPHONE_UDID 2> /dev/null) || true
  echo "export <<parameters.pair-udid-var>>=$PAIR_UDID" >> $BASH_ENV
  if [ -z $PAIR_UDID ]; then
    PAIR_UDID=$(echo $SIMLIST | jq -r ".pairs | to_entries[] | select(.value.watch.udid==\"$WATCH_UDID\" and .value.phone.udid==\"$IPHONE_UDID\") | .key")
  fi
  xcrun simctl boot $PAIR_UDID
else
  xcrun instruments -w "<< parameters.iphone-device >> (<< parameters.iphone-version >>) + << parameters.watch-device >> (<< parameters.watch-version >>) [" || true
fi