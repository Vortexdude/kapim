#!/bin/bash


RESOURCE_GROUP='dlr-dev-apim'
APIM_INSTANCE='dlr-dev-apim'

# install the nessesary tools
sudo apt install jq yq -y

cd APIs


echo "Filtering  the Name from the file"

find -type f -exec sh -c '
    original_name="$1"
    new_name=$(echo "$1" | sed "s/[[:space:]\(\)\$]//g")
    if [ "$original_name" != "$new_name" ]; then
        mv "$original_name" "$new_name"
    fi
' sh {} \;


# Function to convert YAML to JSON
convert_yaml_to_json() {
    yaml_file="$1"
    json_file="${yaml_file%.yaml}.json"

    # remove the octal value if any
    sed -i 's/\b0\([0-9]\+\)/\1/g' "$yaml_file"
    
    cat "$yaml_file" | yq . > "$json_file"
}

# Iterate over all files in the directory
for file in *; do
    if [ -f "$file" ]; then
        if [[ "$file" == *.yaml ]]; then
            convert_yaml_to_json "$file"
            if [[ $? -eq 0 ]]; then
            	rm -rf "$file"
            fi

        elif [[ "$file" != *.json ]]; then
            echo "$file"
        fi
    fi
done



createApi (){
	apiFilePath=$1
	jsonFile=$(cat "$apiFilePath" | jq -c '.')
	# apiVersionSetId=$(echo "$jsonFile" | jq -r '.info.title' | tr -d '[:space:]' | tr -cd '[:alnum:]_' | sed 's/[^0-9a-zA-Z_]/-/g')
	apiVersironNumber=$(echo "$jsonFile" | jq -r '.info.version' | cut -d'.' -f1)
	# apiRevisionId=$(echo "$jsonFile" | jq -r '.info.version' | cut -d'.' -f2)
	# apiVersionId="Version $apiVersironNumber"
	specificationFormat="OpenApi"
	# displayName=$(echo "$jsonFile" | jq -r '.info.title')
	serviceUrl=$(echo "$jsonFile" | jq -r '.servers[0].url')
	basePath=$(echo "$jsonFile" | jq -r '.paths | keys[0]')
	az apim api import --resource-group "${RESOURCE_GROUP}" \
	                   --service-name "${APIM_INSTANCE}" \
	                   --specification-path ./api-spec.json \
	                   --display-name "Comments-v1" \
	                   --path "${basePath}" \
	                   --api-type http \
	                   --protocols "https" \
	                   --subscription-required \
	                   --authorization-scope "Authorization"

for file in APIs/*; do 
    if [ -f "$file" ]; then 
        echo "Importing Json format API: $file"
        createApi "$file"
    fi 
done
