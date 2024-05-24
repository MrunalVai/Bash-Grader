import pandas,sys,statistics,math
import numpy as np
import matplotlib.pyplot as plt

#This function will give the marks in all exams for a list of roll numbers
def get_by_roll(roll_list):
    res = {}
    for roll in roll_list:
        row = data[data.Roll_Number == roll]                        #gets row of the corresonding roll number 
        if row.empty:
            res[roll] = "No such roll number"
        else:
            a = {}
            for column,value in row.items():
                a[column] = value.values[0]
            res[roll] = a
    if res == {}:
        return "No input Provided"
    return res                                                      #Form : {roll:{"Roll_Number":roll,"Name":name,"quiz1":marks....},...}

#This function will give statistics of all exams      
def get_stats_all(data):
    if data.empty:
        return "No data in the file"
    mean = {}
    median = {}
    stddev = {}
    tf = {}
    max = {}
    min = {}
    for name,n_data in data.items():                                            #iterates through all columns in data where name is column name
        if name != "Roll_Number" and name != "Name" and name != "grade":
            s = 0
            marks = data[name].to_list()                                        #List of marks of that exam as string
            for i in range(len(marks)):
                if marks[i] == 'a':
                    marks[i] = 0
            marks = [float(a) for a in marks]
            for m in marks:
                if m != 'a':
                    s+=m
            mean[name] = round(s/len(marks),2)
            marks.sort()
            #calculating median
            if len(marks) % 2 == 0:
                median[name] = round((marks[len(marks)//2]+marks[len(marks)//2-1])/2,2)
            else:
                median[name] = round(marks[(len(marks)+1)//2],2)
            stddev[name] = round(statistics.stdev(marks),2)
            tf[name] = marks[len(marks)-len(marks)//4]
            max[name] = marks[len(marks)-1]
            min[name] = marks[0]

    result = [mean,median,stddev,tf,max,min]
    return result

#This function will give the number of students below some marks and above some marks of some exam
def get_number(exam,d):
    marks = data[exam].to_list()           
    for i in range(len(marks)):
        if marks[i] == 'a':
            marks[i] = 0
    marks = [float(i) for i in marks]
    #Below code will generate the limits of marks of the students to check. By default it will be >=0 and <=max(marks)
    r = {'ge':0,'le':max(marks)}
    if 'ge' in d:
        r['ge'] = int(d['ge'])
    if 'le' in d:
        r['le'] = int(d['le'])
    n = 0                                                       #Number of students which will be calculated using loop
    for i in marks:
        if i <=r['le'] and i>=r['ge']:
            n+=1
    return n

#This function will add grades to the students according to number of students in each grade.
def grade(a):
    #a will contain lowest cumulative rank for each grade as an integer array. 
    marks = data['total'].to_list()
    for i in range(len(marks)):
        if marks[i] == 'a':
            marks[i] = 0
    #There will be two arrays, one will be original one and other will be copied one. the other one is reverse 
    #sorted. A result array name res is made which will contain grades of all students, initially it will contain 
    #0 for all students as after that i can change any element of that array. Iteration through tmarks will be 
    #performed and comapring array index and values in array a we can assign grade to the student.
    #The student will be found by marks.index(tmarks[i]) which will give the students index if the marks obtained
    #by student is unique. Otherwise the index will increase by one until the res[index] is non zero.
    marks = [float(i) for i in marks]
    tmarks = marks.copy()
    tmarks.sort(reverse=True)
    res = [0 for i in range(len(marks))]
    for i in range(len(tmarks)):
        if i<a[0]:
            index = marks.index(tmarks[i])
            while True:
                if res[index] != 0:
                    index+=1
                else:
                    break
            res[index] = "AA"
        elif i<a[1]:
            index = marks.index(tmarks[i])
            while True:
                if res[index] != 0:
                    index+=1
                else:
                    break
            res[index] = "AB"
        elif i<a[2]:
            index = marks.index(tmarks[i])
            while True:
                if res[index] != 0:
                    index+=1
                else:
                    break
            res[index] = "BB"
        elif i<a[3]:
            index = marks.index(tmarks[i])
            while True:
                if res[index] != 0:
                    index+=1
                else:
                    break
            res[index] = "BC"
        elif i<a[4]:
            index = marks.index(tmarks[i])
            while True:
                if res[index] != 0:
                    index+=1
                else:
                    break
            res[index] = "CC"
        elif i<a[5]:
            index = marks.index(tmarks[i])
            while True:
                if res[index] != 0:
                    index+=1
                else:
                    break
            res[index] = "CD"
        elif i<a[6]:
            index = marks.index(tmarks[i])
            while True:
                if res[index] != 0:
                    index+=1
                else:
                    break
            res[index] = "DD"
        else:
            index = marks.index(tmarks[i])
            while True:
                if res[index] != 0:
                    index+=1
                else:
                    break
            res[index] = "FF"
    data['grade'] = res                                 #This will create a new column named grade in data.
    data.to_csv('main.csv',index=False)                 #converts to main.csv

#This function will show a graph with subgraphs in it. The code pretty much has no logic in it and is using the functions defined above. It will just plot the graph.
def all_graph(data):
    stats = get_stats_all(data)
    a=0
    for exam,examdata in data.items():
        if exam != "Roll_Number" and exam != "Name" and exam != "grade":
            a+=1
    j=1
    for exam,examdata in data.items():
        if exam != "Roll_Number" and exam != "Name" and exam != "grade":
            x = ['mean','median','stddev','three-fourth','max','min']
            y = []
            for i in stats:
                y.append(i[exam])
            plt.subplot(math.ceil(a/2),2,j)
            j+=1
            plt.title(exam)
            plt.bar(x,y,color=np.random.rand(3,),label=exam)
            plt.xlabel('student')
            plt.ylabel('marks')
            plt.legend()
    plt.tight_layout()
    plt.show()

#Gives graph for the roll numbers for all exams
def graph(roll_list):
    a = get_by_roll(roll_list)
    exams = []
    for i in a[roll_list[0]]:
        if i != "Roll_Number" and i != "Name" and i != "grade":
            exams.append(i)
    j = 1
    for exam in exams:
        x = roll_list
        y = [a[i][exam] for i in roll_list]
        plt.subplot(math.ceil(len(exams)/2),2,j)
        j+=1
        plt.title(exam)
        plt.bar(x,y,color=np.random.rand(3,),label=exam)
        plt.xlabel('student')
        plt.ylabel('marks')
        plt.legend()
    plt.tight_layout()
    plt.show()

data = pandas.read_csv('main.csv')                          #DataFrame object
args = sys.argv

#These are the conditions through which python code will give a specific response for a particular command line argument.
if args[1] == 'mean':
    result = get_stats_all(data)[0]
    for i in result:
        print(f"Mean of {i} is {result[i]}")

if args[1] == 'median':
    result = get_stats_all(data)[1]
    for i in result:
        print(f"Median of {i} is {result[i]}")

if args[1] == 'stddev':
    result = get_stats_all(data)[2]
    for i in result:
        print(f"Standard Deviation of {i} is {result[i]}")

if args[1] == 'tf':
    result = get_stats_all(data)[3]
    for i in result:
        print(f"Third Quarter marks of {i} is {result[i]}")

if args[1] == 'number':
    a = []
    for i in range(4,len(args)):
        a.append(args[i])
    res = {}
    if 'ge' in a:
        res['ge'] = a[a.index('ge')+1]
    if 'le' in a:
        res['le'] = a[a.index('le')+1]
    print(get_number(a[0],res))

if args[1] == 'show':
    roll_list = []
    for i in range(3,len(args)):
        roll_list.append(args[i].upper())
    result = get_by_roll(roll_list)
    d = []
    e = []
    for i in result:
        if result[i] != "No such roll number":
            d.append(result[i])
        else:
            e.append([i,"No such roll number"])
    print(pandas.DataFrame(d).to_string(index=False))
    for i in e:
        print(i[0],i[1])

if args[1] == 'grade':
    if args[2] == '-n':
        a = []
        for i in range(3,len(args)):
            a.append(int(args[i]))
        for i in range(len(a)-1,-1,-1):
            s = 0
            for j in range(i,-1,-1):
                s+=a[j]
            a[i] = s
        grade(a)

if args[1] == 'graph_all':
    all_graph(data)

if args[1] == 'graph':
    a = []
    for i in range(4,len(args)):
        a.append(args[i].upper())
    graph(a)