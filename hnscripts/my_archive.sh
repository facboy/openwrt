#!/bin/bash

TAG=$(date -I)
mkdir -p ~/openwrt/builds/${TAG}
cp -r bin/* ~/openwrt/builds/${TAG}
