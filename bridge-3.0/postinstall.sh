#!/usr/bin/env bash
echo "shotcut bridge"
sleep 4
sudo ln -s /Applications/Bridge.app ~/Desktop
echo "post-install Bridge success."
sleep 1
sudo tccutil reset All com.apple.terminal
exit 0

