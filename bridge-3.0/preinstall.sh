#!/usr/bin/env bash
echo "Running bridge"
killall "Bridge"
echo "Finding old version of Bridge"
sudo rm -rf /Applications/Bridge.app 
sudo rm -rf ~/Desktop/Bridge.app
sudo rm -rf ~/Documents/.loadDataScript.plist
sudo rm -rf /usr/local/lib/libVTNotification.dylib

sleep 8
echo "pre-install Bridge success."
exit 0

