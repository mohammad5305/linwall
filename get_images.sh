#!/bin/bash
BASE_URL="https://api.telegram.org/bot${TEL_TOKEN}"
UPDATE_JSON=$(curl -s "${BASE_URL}/getUpdates")
LOG_FILE="./test.log"
IMAGES_PATH="./images"

for message in $(echo "${UPDATE_JSON}" | jq -r '.result[] | @base64'); do
    DATA=$(echo "${message}" | base64 --decode)
    CHANNEL=$(jq -r .channel_post.sender_chat.username <<< $DATA)

    if [[ "$(jq .channel_post.document <<< $DATA)" != "null" ]] && [[ "$(jq .channel_post.document.mime_type <<< $DATA)" =~ "image" ]] && [ $CHANNEL == "LinWallpaper" -o $CHANNEL == "coolpics23" ]; then
        FILE_ID=$(echo $DATA | jq -r .channel_post.document.file_id)
        FILE_NAME=$(echo $DATA | jq -r .channel_post.document.file_name )

        if [[ ! $(grep "$FILE_ID" $LOG_FILE) ]]; then
            FILE_PATH=$(curl -s ${BASE_URL}/getFile?file_id=$FILE_ID | jq -r .result.file_path)

            if [[ -e ${IMAGES_PATH}/$FILE_NAME ]]; then
                FILE_NAME=${FILE_NAME%.*}_new.${FILE_NAME##*.}
            fi

            curl -s -o "${IMAGES_PATH}/${FILE_NAME}" https://api.telegram.org/file/bot${TEL_TOKEN}/${FILE_PATH}
            echo $FILE_ID >> $LOG_FILE
        fi
    fi
done
