command=$1

#conditional command for combine
if [ $1 == "combine" ]
then
	#If main.csv doesn't exists or is empty this if condition will execute otherwise will delete main.csv and then combine again. else will usually be executed if some new csv files are uploaded.
	if [[ ! -e "main.csv" || -z $(cat main.csv) ]]
	then
		./combine.sh	
	else
		rm main.csv
		./combine.sh
	fi
fi

#conditional command for upload
if [ $1 == "upload" ]
then 
	#Input error handling
	if [ $# -eq 1 ]
	then
		echo "No files provided"
		exit 1
	fi
	#Iterates through all the command line arguments and if condition executes only for files provided(not 'upload' in command line argument) and if given file is not present it will raise an error
	for i in $*
	do
		if [ ! -e $i ] && [ $i != $1 ]
		then
			echo "$i file doesn't exists."
			echo "Please provide files correct files again, nothing is copied." 	#if some file doesnt exist nothing will copy and will raise an error
			exit 1
		fi
	done
	#code for iterating through all command line arguments excpet for "upload"($1) and copying them into present working directory.
	for i in $*
	do
		if [ $i != $1 ]
		then
			cp $i $PWD
		fi
	done
fi

#conditional command for total
if [ $1 == "total" ]
then
	#If main.csv does not exists or is empty below if condition will raise an error.
	if [[ ! -e "main.csv" || -z $(cat main.csv) ]]
	then
		echo "main.csv either does not exists or is empty"
		exit 1
	fi
	find=$(head -n1 main.csv | grep "total")		#checks if "total" is present in the first line of main.csv or not
	if [ -z $find ]									#if total is not present in first line of main.csv then following code will execute
	then 
		awk -f total1.awk main.csv > yiha			#awk file is executed and its output is sent to some random file(here 'yiha'), this is then copied to main.csv and then the random file is removed.
		rm main.csv
		mv yiha main.csv
	else
		awk -f total2.awk main.csv > yiha			#same logic as above but here the awk file is different.
		rm main.csv
		mv yiha main.csv
	fi
fi

#conditional command for update
if [ $1 == "update" ]
then
	read -p "Enter Roll_Number: " a											#asks for roll number and save it to varible named 'a'
	roll=$(echo $a | awk '{print toupper($0)}')								#converts all lower case letters(if present) to upper case. Eg 23b8391 changes to 23B8391.
	read -p "Enter Name of the student: " name
	#Input Error handling of wrong name
	if [ "$name" != "$(grep "$roll" main.csv | cut -d ',' -f 2)" ]
	then
		echo "The given name doesn't match with the name of the student.";exit 1
	fi
	while [ True ]
	do
		read -p "Enter Exam(Enter 'exit' if you want to exit): " exam					#asks for exam name for which marks are to be updated
		#To exit the command
		if [ "$exam" == "exit" ]
		then
			exit 0
		fi
		#Input Error handling if exam given is not in main.csv
		if [ ! -e $exam.csv ]
		then
			echo "$exam.csv is not uploaded. Please upload it first."
			continue
		fi
		read -p "Enter Updated Marks: " marks									#asks for marks
		updated_line=$(awk -v roll="$roll" -v exam="$exam" -v marks="$marks" -f update.awk main.csv)		#gives the updated line as a result of execution of update.awk. -v will give the variable's values which will be used in awk file.
		if [ ! -z "$(grep -E "^$roll" "main.csv")" ]							#if given roll is present in main.csv this will execute
		then
			sed -i "/^$roll/ s/\(^.*\)/$updated_line/" main.csv					#code for substition of the line in which roll is present
			if [ -z "$(grep -E "^$roll" "$exam.csv")" ]							#code for updating marks in exam.csv
			then
				echo "$roll,$name,$marks" >> $exam.csv							#if given roll is not present in exam.csv whatever written in echo will be appended in exam.csv
			else
				sed -i -E "/$roll/ s/(^.*),[0-9\.]+/\1,$marks/" $exam.csv		#Substitute if roll is present in exam.csv
			fi
		else																	#executes if the roll number is not in main.csv
			echo "Given roll number is not in main.csv"
			# echo "$roll,$name,$marks" >> $exam.csv
			# exams=$(head -n 1 main.csv | cut -d ',' -f 1,2 --complement)		#first line without 'Roll_Number,Name'
			# IFS=$','															#input field sep for for loop
			# j=1
			# echo "$roll,$name" >> main.csv
			# for i in $exams														#updates main.py marks for exam will be given as 'marks' otherwise will be given 'a'
			# do
			# 	if [ $(echo $exams | cut -d ' ' -f $j) == $exam ]				
			# 	then
			# 		sed -i -E "/^$roll/ s/(^.*)$/\1,$marks/" main.csv			#appends marks to the line in which roll is present
			# 		let $((j+=1))
			# 	else
			# 		if [ $(echo $exams | cut -d ' ' -f $j) != "total" ] && [ $(echo $exams | cut -d ' ' -f $j) != "grade" ]
			# 		then
			# 			sed -i -E "/^$roll/ s/(^.*)$/\1,a/" main.csv			#apppends a to the line
			# 			let $((j+=1))
			# 		fi
			# 	fi
			# done
		fi
	done
fi

#conditional command for git_init
if [ $1 == "git_init" ]
then
	#Input Error handling(format error)
	if [ $# -ne 2 ]
	then
		echo "Wrong format of command"
		exit 1
	fi
	#If git remote repo is already initialised this condition will be true
	if [ -e ./.path.txt ]
	then
		echo -e -n "Git remote repository is already initialized to $(cat ./.path.txt).\nDo you want to reinitialize it to $2. (Y/N) "
		read g																#user response if he wants to reinitialise git remote repo
		if [ $g == "y" ] || [ $g == "Y" ]									
		then
			path=$2															#will reinitialize remote repo is gi y or Y
			file_path=$(cat ./.path.txt)
			if [ ! -d $2 ]
			then		
				mkdir -p $2							#if given remote directory doesnt exist it will make it and 
				touch $2/.git_log					#change the path in .path.txt(hidden file to see repo loc)														
				echo $2>./.path.txt					#all contents of initial remote repo will be copied to the new
				cp -R $file_path/* $2				# repo and inital repo will be deleted.
				rm -r $file_path
			else
				if [ $(realpath $2) == $(realpath $file_path) ]			#checks if the location of initial repo is same as the location of the repo given.
				then										
					exit 0												#if location is same then the code will exit with code 0.
				fi
				rm -R $2/*							#the contents of given repo will be deleted and contents of 
				echo $2>./.path.txt					#initial repo will be copied to given repo. 
				cp -R $file_path/* $2				#the path will be changed in .path.txt
				rm -r $file_path
			fi
		else
			echo "Operation Terminated."			#If user enters other than y or Y(no reinitialization)
			exit 0
		fi
	else
		path=$2										#Remote repo is beign initialized for the first time
		if [ ! -d $2 ]
		then
			mkdir -p $2								#makes directory if not present.
		fi
		if [ -d $2 ]
		then
			rm -rf $2/*;touch $2/.git_log			#if dir exists then its content will be cleared and .git_log file will be created.
			echo $2>./.path.txt						#path of dir will be appended to .path.txt
		fi
	fi
fi

#conditional command for git_commit
if [ $1 == "git_commit" ]
then
	#Input Error handling for wrong format
	if [ $# -ne 3 ] || [ $2 != "-m" ]
	then
		echo "Wrong format of command"
		exit 1
	fi
	#Error handling if remote repo is not initialized
	if [ ! -e ./.path.txt ]
	then
		echo "Git remote repo is not initialized"
		exit 1
	fi
	read path < ./.path.txt

	#.git_log typical syntax for a line will be "commit_id|msg|date_time|(;;) head". lets call this line as commit line for resp commit.
	#the string "(;;)" is used as a ref for further commits to patch with("(;;) may or may not be there"). If files(.csv) in present directory are same as files(.csv) of last commit(contents of files may or may not be same) then this string wont be present in the line in .git_log else will be there.
	#the commits containing '(;;)' in their commit line will act as ref commit for future commits until some new ref commit is made
	#string "head" may be present after any number(>1) of white spaces after last character and will denote the HEAD position in git_log. there will be only single head but its position may change across commits.
	#string "|" is just used as a field seperator ("|" for uniqeness)
	#each commit will be stored in a folder in remote repo as csv files or patch files and folder name will be the commit id.

	if [ -z "$(ls $path)" ]												
	then														#executes if there are no commits.
		for file in $(ls | grep -E "*.csv")						#modified files
		do
			echo "$file is added."
		done
		random=$(shuf -i 1000000000000000-9999999999999999 -n 1)	#generates random 16 digit hash value(commit id)
		mkdir $path/$random											
		cp ./*.csv $path/$random
		str="$random|$3|$(date)|(;;) head"					#this str will be appended to .git_log file and as it is initial commit the string "(;;)" will be appended to str along with "head" and all files(.csv) will be copied as it is.
		echo $str >> $path/.git_log
	else
		lcommit=$(grep -E "head$" $path/.git_log | cut -d '|' -f 1)			#commit id of HEAD
		
		#below code is to show modified files from the last commit.
		#I have made a random directory named 'yehe' and copied all csv files to it and then checkout to the Head commit. 
		mkdir yehe
		cp *.csv yehe
		./checkout.sh $lcommit > /dev/null				#checkout to $lcommit
		#Iteration for files initially present in the pwd for changes and addition of files.
		for file in $(ls yehe | grep -E "*.csv")
		do
			file_name=$(echo $file | cut -d '.' -f 1)
			#if the file exists in the last commit too then diff is checked between them and if it is not null then file changed is echoed.
			#else that file must has been added after lcommit and thus file added is echoed.
			if [ -e ./$file ]
			then
				difference=$(diff -u $file yehe/$file)
				if [ ! -z "$difference" ]
				then
					echo "$file changed"
				fi
			else
				echo "$file added"
			fi
		done
		#Iteration through files in lcommit for deletion of files
		for file in $(ls | grep -E "*.csv")
		do
			#if file doesnt exist in yehe then deleted file is echoed.
			if [ ! -e yehe/$file ]
			then
				echo "Deleted $(basename $file)"
			fi
		done
		#end code for checking modifications
		rm *.csv;cp yehe/*.csv ./;rm -r yehe			#finally the state of directory is recovered by removing all csv in ./ coping all csv in ./ from yehe and removing yehe.
		random=$(shuf -i 1000000000000000-9999999999999999 -n 1)
		latest=$(tac $path/.git_log | grep "(;;)" | head -n1)			#finds the latest ref commit.
		commit=$(echo $latest | cut -d '|' -f 1)
		if [ "$(ls *.csv)" ==  "$(ls $path/$commit)" ]					
		then													#if $commit files are same as commiting files(contents may or may not be same) this will execute.
			mkdir $path/$random									#makes new commit folder
			for file in $(ls *.csv)								#iterates through all files in pwd and makes corresponding patch files
			do
				file_name=$(echo $file | cut -d '.' -f 1)								#gives file name. Eg for main.csv it will be main
				diff -u $path/$commit/$file $file > $path/$random/$file_name.patch		#diff between ref commit and ./ for all files is saved as file_name.patch in new commit folder.
			done
			str="$random|$3|$(date) head"												#this is not a ref commit hence "(;;)" is not added but this is head commit hence head is added.
			sed -E -i "/head$/ s/head$//" $path/.git_log									#it removes all head references at the end of the line in .git_log.
			echo $str >> $path/.git_log														#appends commit info to .git_log
		else																				#executes if there are different files in head commit and ./ (not content wise only file_name wise)
			mkdir $path/$random
			cp ./*.csv $path/$random											#since it will be a ref commit all files will be copied as it is
			str="$random|$3|$(date)|(;;) head"									#and thus "(;;)" will be in the commit line of the commit in .git_log
			sed -E -i "/head$/ s/head$//g" $path/.git_log						#removes all head$ in .git_log
			echo $str >> $path/.git_log
		fi
	fi	
fi

#conditional command for git_checkout
if [ $1 == "git_checkout" ]
then
	read path <./.path.txt
	line=$(cat $path/.git_log | grep -E "head$")
	commit=$(echo $line | cut -d '|' -f 1)
	f=1															#flag used if there are any modifications
	#below is code for checking modifications since the head commit. the code is same as that used in git_commit.
	mkdir yehe
	cp *.csv yehe
	./checkout.sh $commit > /dev/null
	for file in $(ls yehe | grep -E "*.csv")
	do
		file_name=$(echo $file | cut -d '.' -f 1)
		if [ -e ./$file ]
		then
			difference=$(diff -u $file yehe/$file)
			if [ ! -z "$difference" ]
			then
				let $((f=0))								#flag value changed
				echo "$file changed"
			fi
		else
			let $((f=0))									#flag value changed
			echo "$file added"
		fi
	done
	for file in $(ls | grep -E "*.csv")
	do
		if [ ! -e yehe/$file ]
		then
			let $((f=0))									#flag value changed
			echo "Deleted $(basename $file)"
		fi
	done
	if [ $f == 0 ]											#this will mean some modification is made
	then
		echo "Some files are changed wrt Head commit please stash them to checkout."
		rm *.csv;cp yehe/*.csv ./;rm -r yehe
		exit 1
	fi	
	rm *.csv;cp yehe/*.csv ./;rm -r yehe
	#end code for modification
	#checkout with commit_id or master(modification)
	if [ $# -eq 2 ]												#code for direct checkout to master
	then	
		if [ $2 == "master" ]
		then													#executes if command is ./submission.sh git_checkout master 
			read path <./.path.txt
			line=$(tail -n 1 $path/.git_log)
			commit=$(echo $line | cut -d '|' -f 1)				#commit_id of latest commit
			./checkout.sh $commit								#checkout to latest commit
			sed -E -i "/head$/ s/head$//g" $path/.git_log		#removes head$ from .git_log
			sed -E -i "/$commit/ s/$/ head/" $path/.git_log		#appends head to latest commit 
		else													#expects $2 to be some initials of commit_id
			read path <./.path.txt
			files=$(find "$path" -type d -name "$2*")			#find the fav files in $path.
			#If not such commit is found then below error will be shown
			if [ -z "$files" ]
			then
				echo "No such commit found"
				exit 1
			else 												#given commit must be there for execution of this else.
				#An associative array commits is made which will be in form of commits[Serial number]=commit_id
				#thus for all favourable commits the associative array will be made.
				#a favourable commit starts with $2.
				declare -A commits
				i=1
				for f in $files									#each f will be the commit_id as folder name in $path
				do	
					commits[$i]=$f
					let $((i+=1))
				done
				let $((i=i-1))
				#if there is only one favourable commit then following condition will be tru
				if [ $i -eq 1 ]
				then
					commit=$(basename ${commits[1]})						#basename gets the name of the file which is the first element of 'commits'(ass. array).
					./checkout.sh $commit
					file=${commits[1]}
					sed -E -i "/head$/ s/head$//g" $path/.git_log			#this code removes head from .git_log
					file_name=$(basename $file)								#and will be added to commit line of 
					sed -E -i "/$file_name/ s/$/ head/" $path/.git_log		#checkout commit.
					exit 0
				fi
				#if there are multiple favourable commits then user will be asked to enter the serial number of commit he wants checkout to.
				#the serial number will be the index of associative array of that commit.
				#given serial number will be used to find commit_id of commit to checkout and then checkout to that commit will be done with same logic as above.
				echo "Which commit do you want? Enter serial number "
				j=1														#counter for serial number
				for f in $files
				do
					echo "$j $(basename $f)"
					let $((j+=1))
				done
				read n													#serial number entered by user
				file=${commits[$n]}
				#if serial number is out of bound or not in prompted serial numbers this error will show up.
				if [ -z $file ]
				then
					echo "No such serial number."
					exit 1
				fi
				#normal checkout logic
				commit=$(basename ${commits[$n]})
				./checkout.sh $commit
				sed -E -i "/head$/ s/head$//g" $path/.git_log
				file_name=$(basename $file)
				sed -E -i "/$file_name/ s/$/ head/" $path/.git_log
			fi
		fi
	fi
	#checkout with message
	if [ $# -eq 3 ]
	then
		#Input Error handling
		if [ $2 != "-m" ]
		then
			echo "Invalid Syntax"
			exit 1
		else
			read path <./.path.txt
			list=$(cat $path/.git_log)
			IFS=$'\n'											#Input field sep for for loop
			#an associative array 'clist' is made which will contain fav commit commit line along with their serial number.
			declare -A clist											
			i=1											#counter for serial number
			j=0											#flag for existence of any fav commit
			for l in $list
			do
				c=$(echo $l | cut -d '|' -f 2)			#this will extract the commit message.
				if [ $c == $3 ]	
				then										#if msg is equal to $3 this will be a fav commit and will be added to 'clist'.
					clist[$i]=$l
					let $((j=1))							#If fav commit is found j=1
					let $((i+=1))
				fi
			done
			#Error if no commit is found
			if [ $j == 0 ]
			then
				echo "No such commit found."
				exit 1
			fi
			let $((i-=1))
			#if there is only one fav commit then following condition will be true
			if [ $i -eq 1 ]
			then
				commit=$(echo ${clist[1]} | cut -d '|' -f 1) 				#extracts commit_id from the fav commit line.
				#below logic is same used above for checkout
				./checkout.sh $commit
				sed -E -i "/head$/ s/head$//g" $path/.git_log
				sed -E -i "/$commit/ s/$/ head/" $path/.git_log
			else														#executed if there are multiple fav commits.
				echo "Which commit do you want? Enter serial number "
				for i in ${!clist[*]}										#Iterates through all elements in 'clist' ass. array and prints serial number and commit id + commit msg.
				do
					echo "$i -- $(echo ${clist[$i]} | cut -d '|' -f 1,2,3)"
					let $((i+=1))
				done
				read n														#serial number by user
				commit=$(echo ${clist[$n]} | cut -d '|' -f 1)
				#Input Error handling for wrong serial number
				if [ -z "$commit" ]
				then
					echo "No such serial number."
					exit 1
				fi
				#Below logic same as used before
				./checkout.sh $commit
				sed -E -i "/head$/ s/head$//g" $path/.git_log
				sed -E -i "/$commit/ s/$/ head/" $path/.git_log
			fi
		fi
	fi
fi

#Customisations

#conditional command for git_log
if [ $1 == "git_log" ]
then
	read path < ./.path.txt
	file=$path/.git_log												#This file contains all the record for log for all commits
	#logic is that i will print the git_log file from the bottom using tac command and pass this result to check the occurence of head commit.
	#till the head commit is found nothing will be done and if it is found a flag('f') will be set to 1.
	#once the flag is set to 1 git_log contents will be printed with same format as original git log command.
	IFS=$'\n'
	str=""
	f=0
	for line in $(tac $file)										#tac will print the line from the bottom implies latest commit will be shown first
	do 
		if [ $f == 0 ] && [ ! -z $(echo $line | grep -E "head$") ]
		then															#If head$ is found in the line f will be 1 and now the git_log contents will be printed.
			let $((f=1))
		fi
		if [ $f == 1 ]
		then															
			commit=$(echo $line | cut -d '|' -f 1)
			msg=$(echo $line | cut -d '|' -f 2)
			date_time=$(echo $line | cut -d '|' -f 3)
			#There would be two cases one in which commit is head commit and other in which commit is any other commit
			#for head commit i printed (HEAD) after the commit message using suitable colors.
			if [ ! -z $(echo $line | grep -E "head$") ]
			then																						#This commit will be head commit if this executes
				str+="\n\e[33mcommit $commit (\e[34mHEAD\e[0m)\e[0m\nDate : $date_time\n\n\t$msg\n"		#\e[33m is used to color the font in linux terminal the color will be the ansi code's color given in the command(here 33, 34 and 0). 
			else																						#Execution for normal commits.
				str+="\n\e[33mcommit $commit\e[0m\nDate : $date_time\n\n\t$msg\n"
			fi
		fi
	done
	echo -e "$str" | less -R												#I used less command to show latest commit first and then other commits according to the sequence. -R command is used to show colors(used bye \e[codem) in less command.
	echo -e "$str"															#To show up git_log in terminal too i used this as it will ease to checkout.
fi

#conditional command for show
if [ $1 == "show" ]
then	
	#this command will show the marks of all the students whose roll numbers are given as command line arguments seperated with a blank space.
	python3 main.py show $* 2>/dev/null								#logic in main.py
fi

#conditional command for statistics
if [ $1 == "statistics" ]
then
	#this command will show the statistics(mean, median, stddev, three-forth, number of students above and below some marks) for all exams along with total
	if [ $2 == "mean" ]
	then
		if [ $# -eq 2 ]
		then
			python3 main.py mean 2> /dev/null
		else
			echo "Invalid Syntax"
			exit 1
		fi
	elif [ $2 == "median" ]
	then
		if [ $# -eq 2 ]
		then
			python3 main.py median 2> /dev/null
		else
			echo "Invalid Syntax"
			exit 1
		fi
	elif [ $2 == "stddev" ]
	then
		if [ $# -eq 2 ]
		then
			python3 main.py stddev 2> /dev/null
		else
			echo "Invalid Syntax"
			exit 1
		fi
	elif [ $2 == "three-fourth" ]
	then
		if [ $# -eq 2 ]
		then
			python3 main.py tf 2> /dev/null
		else
			echo "Invalid Syntax"
			exit 1
		fi
	elif [ $2 == "number" ]
	then
		python3 main.py number $* 2> /dev/null
	else 
		echo "Invalid syntax";exit 1
	fi
fi

#conditional command for grading the students in main.csv
if [ $1 == "grade" ]
then
	#Input Error Handling
	if [ $# -ne 2 ]
	then
		echo "Invalid Syntax";exit 1
	fi
	#Input Error Handling
	if [ "$2" != "-n" ] && [ "$2" != "-m" ]
	then
		echo "Invalid Syntax";exit 1
	fi
	#this will grade the students based on two cases one wrt cut off of marks of each grade and other number of students of each grade.
	#Also once this command is run grades would appear in main.csv and as grades are given already there is no need to update any marks or upload any new files or total again(and if these commands are run they would show some unexpected result as i have not handled case for after grading.)
	#Based on marks
	if [ $2 == "-m" ]
	then
		if [ -z $(grep "total$" main.csv) ]
		then													#If total is not done in main.csv this command will do it as it will be required for grading
			./submission.sh total
		fi 
		#Following reads the lowest marks for all grades.
		read -p "Enter lowest marks for AA : " aa
		read -p "Enter lowest marks for AB : " ab
		read -p "Enter lowest marks for BB : " bb
		read -p "Enter lowest marks for BC : " bc
		read -p "Enter lowest marks for CC : " cc
		read -p "Enter lowest marks for CD : " cd
		read -p "Enter lowest marks for DD : " dd
		#Below logic is that the output from awk file will be saved in a random file here it is named 'fale' and then it is copied to main.csv and then fale is removed.
		awk -v aa="$aa" -v ab="$ab" -v bb="$bb" -v bc="$bc" -v cc="$cc" -v cd="$cd" -v dd="$dd" -f grade.awk main.csv > fale 
		cp fale main.csv
		rm fale
	fi
	#Based on number of students in each grade
	if [ $2 == "-n" ]
	then
		if [ -z $(grep "total$" main.csv) ]
		then															#If total is not done in main.csv this command will do it as it will be required for grading
			./submission.sh total
		fi 
		#Following reads the number of students for all grades.
		read -p "Enter number of students for AA : " aa
		read -p "Enter number of students for AB : " ab
		read -p "Enter number of students for BB : " bb
		read -p "Enter number of students for BC : " bc
		read -p "Enter number of students for CC : " cc
		read -p "Enter number of students for CD : " cd
		read -p "Enter number of students for DD : " dd
		python3 main.py grade -n $aa $ab $bb $bc $cc $cd $dd 2> /dev/null
	fi
fi

#conditional command for getting graphs
if [ $1 == "graph" ]
then
	#This case is for the graph of all students
	if [ $2 == "-a" ]
	then
		python3 main.py graph_all 2>/dev/null
	fi
	if [ $2 == "-s" ]
	then
		python3 main.py graph $* 2>/dev/null
	fi
fi