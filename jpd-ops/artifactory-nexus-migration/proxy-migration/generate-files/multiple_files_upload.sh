#!/bin/bash

ARTIFACTORY_URL="http://10.245.198.16:8082"
REPOSITORY="example-repo-local"
USERNAME="admin"
PASSWORD="<JPD-admin-password>"
FILE_PREFIX="large_file"
FILE_SIZE="2M"
ITERATIONS=100

#jf config add jfrogtest --url=$ARTIFACTORY_URL --user=$USERNAME --password=$PASSWORD --interactive=false
#jf c use jfrogtest
jf c show

mkdir -p testfiles
cd testfiles
for i in $(seq 1 $ITERATIONS); do
    FILE_NAME="${FILE_PREFIX}_${i}.bin"

    echo "Generating file $FILE_NAME..."
    dd if=/dev/urandom of=$FILE_NAME bs=$FILE_SIZE count=1

    echo "Iteration $i completed."
done

cd ..

echo "Uploading file $FILE_NAME to Artifactory..."
jf rt upload "testfiles/*.bin" $REPOSITORY/ --threads=20

echo "Deleting local test files..."
rm -f testfiles/*.bin

echo "All files have been generated and uploaded to Artifactory."
