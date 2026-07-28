#!/bin/bash
#
# createbuildinfo  -  Create info on current config and source code changes

getGitInfo() {
#params: directory patchfile infofile
 echo "\n######################################################\n" >> $3
 (cd $1
  git diff HEAD > $2
  git remote -v show | grep fetch >> $3
  git branch --list >> $3
  git show --format="%cd %h %s" --abbrev=7 --date=short | head -n 1 | cut -b1-60 >> $3
  git status --porcelain >> $3
 )
}

BinDir=$PWD/bin/targets/qualcommax/ipq807x/
Branch=main

VersTime=$Branch-$(scripts/getver.sh)-$(date +%Y%m%d-%H%M)
Pwd="$(pwd)"
Manifest="openwrt-qualcommax-ipq807x.manifest"

createBuildInfo() {
  if [[ $# -eq 0 ]]; then
    >&2 echo "createBuildInfo needs 2 args, got $@"
    exit 1
  fi

  cd "${Pwd}"

  Device="$1"
  Prefix="$2"

  local TFile=$BinDir/$Device-$VersTime

  echo process $Branch...

  # cleanup old binaries & patches
  rm -f $BinDir/$Device-*

  # remove unnecessary files
  rm -f $BinDir/*root.img $BinDir/*vmlinux.elf $BinDir/*initramfs-uImage $BinDir/*initramfs-uImage.itb

  # create status info and patches
  echo "$VersTime" > $TFile-status.txt
  getGitInfo . $TFile-openwrt.patch $TFile-status.txt
  getGitInfo feeds/luci $TFile-luci.patch $TFile-status.txt
  getGitInfo feeds/packages $TFile-packages.patch $TFile-status.txt
  #getGitInfo feeds/routing $TFile-routing.patch $TFile-status.txt
  sed -i -e 's/$/\r/' $TFile-status.txt

  # collect config info
  cp .config $TFile.config
  cp config.buildinfo $TFile.config.buildinfo
  scripts/diffconfig.sh > $TFile.diffconfig.txt 2>/dev/null

  # copy buildroot creation script and patch timestamp info
  cp hnscripts/newBuildroot.sh $TFile-newBuildroot.sh
  sed -i "s/^FILESTAMP=.*/FILESTAMP=$Device-$VersTime/" $TFile-newBuildroot.sh

  # cleanup checksum files
  grep -sh $Prefix.*-squashfs $BinDir/md5sums $BinDir/sha256sums \
    | sed -e 's/$/\r/' -e 's/\*'$Prefix'/'$Device'/' -e 's/squashfs-//' \
    > $TFile-checksums.txt
  rm -f $BinDir/md5sums $BinDir/sha256sums

  # rename manifest and firmware files
  cd $BinDir
  cp "${Manifest}" $Device-$VersTime-manifest.txt
  mv $Prefix-squashfs-sysupgrade.bin $Device-$VersTime-sysupgrade.bin
  mv $Prefix-squashfs-factory.chk $Device-$VersTime-factory.chk
  mv $Prefix-squashfs-factory.ubi $Device-$VersTime-factory.ubi
}

createBuildInfo "RBR750" "openwrt-qualcommax-ipq807x-netgear_rbr750"
createBuildInfo "RBS750" "openwrt-qualcommax-ipq807x-netgear_rbs750"
