#Logic : 
#this code will first assume that either main.csv doesnt exist or it is empty.
#first all the distinct roll numbers are appended to main.csv along with student names by iterating through all non empty-csv files except main.csv
#then iteration will be through all suitable .csv files where marks of roll number (if found in 'exam'.csv) will be appended else if roll number not found in 'exam'.csv a will be appended for that roll number. 

echo "Roll_Number,Name" >main.csv                                       #appends "Roll_Number,Name" to main.csv as it will be used as column name
files=$(ls | grep -E '*.csv')
#iteration through all the csv files
for file in $files
do
    if [ $file != "main.csv" ] && [ ! -z "$(cat $file)" ]                   #follows only if file is non empty and is not main.csv
    then
        list=$(awk 'BEGIN{FS=",";OFS=","}{if(NR>1) print $1,$2}' $file)     #will contain all roll and names in that csv file
        IFS=$'\n'
        for line in $list                                                   #iterating through list using input field sep as \n
        do
            if [ -z $(echo "$line" | grep "Roll_Number,Name") ]             #wont run for first line in the file.
            then
                a=$(echo "$line" | cut -d ',' -f 1)                                                     #original roll number
                roll=$(echo $(echo "$line" | cut -d ',' -f 1) | awk '{print toupper($0)}')             #converts lower case roll numbers to upper case roll numbers (toupper functn)
                find=$(grep "$roll" main.csv)
                l=$(echo $line | sed "s/$a/$roll/")                                            #gives the updated line with capital case roll numbers.
                if [ -z "$find" ]
                then                                                            #to prevent duplicates if roll in not found in main.csv this will run and append roll,name in it but if found it will do nothing.
                    echo "$l" >> main.csv
                fi
            fi
        done
    fi
done
#Below code adds marks ro the students in main.csv
for file in $files
do 
    if [ $file != "main.csv" ] && [ ! -z "$(cat $file)" ]
    then                                                            #only true if file is non empty and is not main.csv
        IFS=$'\n'
        i=0                                                         #counter for first line the file(ie to add exam name as a column name)
        for line in $(cat $file)
        do                                                          #iterates through file with ifs \n
            marks=$(echo "$line" | cut -d ',' -f 3)
            a=$(echo "$line" | cut -d ',' -f 1)
            roll=$(echo $(echo "$line" | cut -d ',' -f 1) | awk '{print toupper($0)}')
            if [ $i == 0 ]
            then                                                    #True if this is first line of the file
                file_name=$(echo $file | cut -d '.' -f 1)              #Eg for quiz1.csv will give quiz1
                #logic to append will be substitute all letters in the given line by the orginal letters along with file_name.
                sed -i "/Roll_Number,Name/ s/\(^.*\)/\1,$file_name/" main.csv   #will append exam name in the first line of main.csv and main.csv will be changed because of -i
            else                                                                #for other lines
                sed -i -E "s/$a/$roll/" $file                                   #any lower case roll will be substitued as upper case roll in exam.csv
                sed -i -E "/$roll/ s/(^.*)/\1,${marks%$'\r'}/" main.csv         #addition of marks of that roll number
            fi
            let "i=i+1"
        done
        #This is for absent students ie whose name is in main.csv but not in exam.csv hence the iteration will be on lines in main.csv
        for line in $(cat main.csv)
        do
            roll=$(echo "$line" | cut -d ',' -f 1)
            find=$(grep $roll $file)
            if [ -z "$find" ]
            then                                                        #if roll is not found in $file then a will be appended to that roll number in main.csv
                sed -i "/$roll/ s/\(^.*\)/\1,a/" main.csv
            fi
        done
    fi
done