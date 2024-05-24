read path < ./.path.txt
commit=$1
#There will be two types of checkout, one will be from patch files and one will be from ref commits which will have .csv files.
if [ -z "$(grep -E "^$commit" $path/.git_log | grep "(;;)")" ]
then                                                                #This will be executed if commit line wont contain the string "(;;)". This means that this commit will contai patch files.
    str=""                                                          #This str will be used to find the latest ref commit made before the commit to checkout 
    while IFS= read -r line; do
        # Print the current line
        str+="$line\n"
        # Check if the current line contains the specified word
        if [[ $line == *"$commit"* ]]; then
            # If the word is found, exit the loop
            break
        fi
    done < "$path/.git_log"
    latest=$(echo -e "$str" | grep "(;;)" | tail -n1 | cut -d '|' -f 1)             #grep will give all the ref commit lines before the commit to checkout and tail and then cut will give the corresponding commit
    rm *.csv
    cp $path/$latest/* ./                                                           #the ref csv files need to present in this directory to patch correctly
    for file in $path/$commit/*.patch
    do
        patch -p0 < $file > /dev/null                                               #This command patches all the files iteratively.
    done
else                                                    #This is a typical case where we just need to copy csv files from commit folder to pwd as this commit should be a ref commit.
    rm *.csv
    cp $path/$commit/*.csv ./
fi