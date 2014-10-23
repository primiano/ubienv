#!/bin/sh
(
echo "From: $1";
echo "To: $1";
echo "Subject: Test HTML email";
echo "Content-Type: text/html";
echo "MIME-Version: 1.0";
echo "";
cat $2;
) | sendmail -t
