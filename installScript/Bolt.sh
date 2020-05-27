#!/bin/sh
if grep -q "extension=bolt.so" /etc/php.ini
then
    echo bolt.so is exist!
else
cp ./installScript/bolt.so /usr/lib64/php/modules

cat>>/etc/php.ini<<"EOF"
extension=bolt.so
EOF

fi