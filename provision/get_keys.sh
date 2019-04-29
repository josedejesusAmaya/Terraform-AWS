#!/bin/bash

TF_OUTPUT=$(terraform output -json)

get_ids(){
    echo "$TF_OUTPUT"| jq -r ".iam_ids.value[]"
}

get_keys(){
    echo "$TF_OUTPUT"| jq -r ".iam_keys.value[]"|
    while IFS=$'\t' read -r data; do
        decrypted=$(echo $data| base64 --decode | keybase pgp decrypt)
        echo $decrypted\n
    done
}

ids=( $(get_ids) )
keys=( $(get_keys) )

for ((i=0;i<${#ids[@]};++i)); do
    printf "academy-user-%s\n\taws_access_key_id=%s\n\taws_secret_access_key=%s\n" "$i" "${ids[i]}" "${keys[i]}"
done