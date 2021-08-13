#!/bin/bash
rm fileList
rm json.json
$(ls | grep '^.*\.csv$' > fileList)

touch json.json

lines=$(wc -l < fileList)

count=1
$(echo "[" >> json.json)
while IFS= read line
do
  $(echo "{" | sed 's/\(.*\)/\t\1/' >> json.json)
  $(echo "$line" | sed 's/\(^.*\)\.csv$/\t\t"\1": [/' >> json.json)

  inlines=$(wc -l < "$line")

  incount=1
  while IFS= read inline
  do
    if [ "$incount" == "1" ]
    then
      IFS=',' read -ra COL <<< "$inline"
    fi

    arrLen=$(echo "${#COL[@]}")

    if [ "$incount" != "1" ]
    then

      $(echo "{" | sed 's/\(.*\)/\t\t\t\1/' >> json.json)
      while IFS=',' read -ra ADDR; do

        indx=0
        icount=1
        for i in "${ADDR[@]}"; do
          j=$(echo "$i" | sed 's/"//g; s/\n//g; s/\r//g')
          if [ "$icount" -eq "$arrLen" ]
          then
            $(echo "\"${COL[indx]}\":\"$j\"" | sed 's/\(.*\)/\t\t\t\t\1/; s/\n//g; s/\r//g' >> json.json)
          else
            $(echo "\"${COL[indx]}\":\"$j\"," | sed 's/\(.*\)/\t\t\t\t\1/; s/\n//g; s/\r//g' >> json.json)
          fi
          ((icount++))
          ((indx++))
        done
      done <<< "$inline"
      if [ "$incount" -eq "$inlines" ]
      then
        $(echo "}" | sed 's/\(.*\)/\t\t\t\1/' >> json.json)
      else
        $(echo "}," | sed 's/\(.*\)/\t\t\t\1/' >> json.json)
      fi

    fi
    (( incount++ ))

  done < $line

  $(echo "]" | sed 's/\(.*\)/\t\t\1/'  >> json.json)
  if [ "$count" -eq "$lines" ]
  then
    $(echo "}" | sed 's/\(.*\)/\t\1/' >> json.json)
  else
    $(echo "}," | sed 's/\(.*\)/\t\1/' >> json.json)
  fi


  (( count++ ))
done < fileList
$(echo "]" >> json.json)
