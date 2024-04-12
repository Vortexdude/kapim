

FIRST_COMMIT_HASH='c940dd84621df36524518f6ebea4d8646f7bc160'

current_hash=$(git log --oneline -1 --pretty=format:%H)

git diff "${FIRST_COMMIT_HASH}" "${current_hash}"





