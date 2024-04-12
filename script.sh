

FIRST_COMMIT_HASH='c940dd84621df36524518f6ebea4d8646f7bc160'

current_hash=$(git log --oneline -1 --pretty=format:%H)

gitchanges=$(git diff --name-status "$FIRST_COMMIT_HASH" "$current_hash")


echo "Git Changes - - "
echo "$gitchanges"


while IFS= read -r line; do
	modificationType=$(echo "$line" | cut -d' ' -f1)
	apiFilePath=$(echo "$line" | cut -d' ' -f2)

	if [ "${apiFilePath%%/*}" != "APIs" ]; then
        echo "Ignoring file: $apiFilePath"
        continue
    fi




done < <(echo "$gitchanges")
