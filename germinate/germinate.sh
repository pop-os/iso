germinate \
    -S seeds/ \
    -s ubuntu.bionic \
    -m http://archive.ubuntu.com/ubuntu/ \
    -m http://ppa.launchpad.net/system76/pop/ubuntu \
    -d bionic,bionic-updates \
    -a amd64 \
    -c main,restricted,universe,multiverse \
    --no-rdepends
