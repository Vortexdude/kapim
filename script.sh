

FIRST_COMMIT_HASH='c940dd84621df36524518f6ebea4d8646f7bc160'
RESOURCE_GROUP='dlr-dev-apim'
APIM_INSTANCE='dlr-dev-apim'

BUILD_SOURCESDIRECTORY=$(pwd)

sourceFolder="$BUILD_SOURCESDIRECTORY/APIs"


current_hash=$(git log --oneline -1 --pretty=format:%H)

gitchanges=$(git diff --name-status "$FIRST_COMMIT_HASH" "$current_hash")


echo "Git Changes - - "

echo "$gitchanges"

craeteApi (){
	apiFilePath=$1
	jsonFile=$(cat "$apiFilePath" | jq -c '.')
	apiVersionSetId=$(echo "$jsonFile" | jq -r '.info.title' | tr -d '[:space:]' | tr -cd '[:alnum:]_' | sed 's/[^0-9a-zA-Z_]/-/g')
    apiVersironNumber=$(echo "$jsonFile" | jq -r '.info.version' | cut -d'.' -f1)
    apiVersionId="Version $apiVersironNumber"
    displayName=$(echo "$jsonFile" | jq -r '.info.title')
    az apim api create --service-name "${APIM_INSTANCE}" -g "${RESOURCE_GROUP}" --api-id "${apiVersionSetId}" --path "/${apiVersionSetId}" --display-name "${displayName}"
}



while IFS= read -r line; do

	modificationType=$(echo $line | awk '{print $1}')
	apiFilePath=$(echo $line | awk '{print $2}')


	if [ "${apiFilePath%%/*}" != "APIs" ]; then
        echo "Ignoring file: $apiFilePath"
        continue
    fi

    fileType=${apiFilePath##*.}
    filepath="$sourceFolder/${apiFilePath//APIs\//}"

    echo "Handling API: $filePath"

    if [ "$modificationType" == "A" ]; then
       if [ "$fileType" == "json" ]; then
           echo "Importing Json format API: $filePath"
           
           craeteApi $filepath

       else
           echo "Unsupported file type: $fileType..."
       fi
    fi
    

done < <(echo "$gitchanges")
