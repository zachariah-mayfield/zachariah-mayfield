#!/bin/bash

/opt/azcopy login --identity xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

for file in $(find /backup/alation -maxdepth 1 -type f); do
    echo "Uplodaing file: ${file}";
    /opt/azcopy copy ${file} "https://xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/alation-backup";
    result=$?;
    echo "AZCOPY RESULT ---------------------- $result";
    if [[ $result != 0 ]];
    then
        echo "Non-zero exit code from azcopy for ${file}.  Terminating.";
        exit -1;
    fi;
done

for file in $(find /backup/alation/ -maxdepth 1 -type f -mtime +5 -type f); do
    echo "Deleting File: ${file}";
    rm ${file}
done

for file in $(find /backup/alation/R* -maxdepth 0 -mtime -1  -type d; find /backup/alation/*.conf -maxdepth 0 -type f); do
    echo "Uplodaing file: ${file}";
    /opt/azcopy copy ${file} "https://xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/alation-backup" --recursive;
    result=$?;
    echo "AZCOPY RESULT ------------------------ $result";
    if [[ $result != 0 ]];
    then
        echo "Non-zero exit code from azcopy for ${file}.  Terminating.";
        exit -1;
    fi;
done

for file in $(find /backup/alation/R* -maxdepth 0 -mtime +5 -type d); do
    echo "Deleting Directory: ${file}";
    rm -r ${file};
done
