#!/bin/sh -u


# Usage:
# ./send-email.log.sh filebot -script fn:sysinfo


# required user configuration
SMTP_SERVER="smtps://smtp.gmail.com:465"
SMTP_USER="<user>@gmail.com"
SMTP_PASS="<password>"

# optional user configuration
MAIL_FROM="$SMTP_USER"
MAIL_TO="$SMTP_USER"


# run command and capture console output
LOG_FILE=$(mktemp)

(time "$@") > "$LOG_FILE" 2>&1

if [ $? -eq 0 ]; then
	STATUS="OK"

	# send email only if the command failed (disabled by default)
	# rm -f "$LOG_FILE"
	# exit 0
else
	STATUS="FAILURE"
fi

# generate raw email message
MAIL_FILE=$(mktemp)

echo "Content-Type: text/html; charset=utf-8
Subject: [$STATUS] $1
From: \"$1\" <$MAIL_FROM>
To: $MAIL_TO
Date: $(date -R)

<!DOCTYPE html>
<html>
	<head>
		<style>
			h1{ font-size: medium; color: CornFlowerBlue; border-bottom: 1px dashed LightGray; padding: 0.5em 0em }
			pre{ color: DarkSlateGray; margin: 1em 0em }
		</style>
	</head>
	<body>
		<h1>Execute</h1>
			<pre><code>$@</code></pre>
		<h1>Output</h1>
			<pre><code>$(cat "$LOG_FILE")</code></pre>
	</body>
</html>" >> "$MAIL_FILE"

# print raw email message
cat "$MAIL_FILE"

# send email
curl --mail-from "$MAIL_FROM" --mail-rcpt "$MAIL_TO" --upload-file "$MAIL_FILE" --url "$SMTP_SERVER" --ssl-reqd --user "$SMTP_USER:$SMTP_PASS"

# delete temporary files
rm -f "$LOG_FILE" "$MAIL_FILE"
