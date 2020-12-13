#!/bin/bash
echo -e "\e[1mStarting DB Install Script\e[0m"
file=$1
username="pi"

if [ ${#file} -eq 0 ]
then
  echo "conf input file missing!"
  exit -1
fi

#read -p "Enter mysql username: "  username

if [ ${#file} -eq 1 ]
then
  file="P000${file}.conf"
elif [ ${#file} -eq 2 ]
then
  file="P00${file}.conf"
elif [ ${#file} -eq 3 ]
then
  file="P0${file}.conf"
elif [ ${#file} -eq 4 ]
then
  file="P${file}.conf"
fi
echo -e "\e[1mInstalling Project ${file}\e[0m"

if [ ! -f "$file" ]
then
  echo -e "\e[31mfile ${file} does not exist!\e[0m"
  exit -1
fi

echo ""
echo -e "\e[1mChecking Files in config\e[0m"
counter=0
while IFS= read -r line
do
  echo "${line}"
  # no empty lines and no comments
  if [ ${#line} -gt 1 ] && [ ${line:0:1} != "#" ]
  then
    if [ ! -f "$line" ]
    then
      counter=$[$counter +1]
      out="${line} \e[31mdoes not exist!\e[0m"
      echo -e $out
    else
      echo -e "${line} \e[32mdoes exist\e[0m"
    fi
  fi
done < "$file"

#abort when at least one file in the conf does not exist.
if [ ${counter} -gt 0 ]
then
   echo -e "Exit -> files are missing. Count missing files ${counter}"	
   exit -1
fi

echo -e "\e[1mExecuting DDL statements\e[0m"
while IFS= read -r line
do
  # no empty lines and no comments
  if [ ${#line} -gt 1 ] && [ ${line:0:1} != "#" ]
  then
    echo "Login with user ${username}"
    psql -U $username -d dev -f ${line}
    echo -e "${line} proccessed"
  fi
done < "$file"
