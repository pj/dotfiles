#!/bin/sh

# FROM https://unix.stackexchange.com/a/641053
line_number=$(grep -na -m1 "^ONLY_BASE64_AFTER_THIS_POINT:$" "$0"|cut -d':' -f1)
line_number=$(expr "$line_number" + "1")
tail -n +"${line_number}" "$0" | base64 --decode > ~/bootstrap

# don't forget the new line here and don't type in anything after this point
#                            ↓
ONLY_BASE64_AFTER_THIS_POINT:
