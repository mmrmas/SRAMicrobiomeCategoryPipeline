import sys, getopt
import re
import pandas as pd
import os
from pathlib import Path
import urllib.request
from urllib.request import Request, urlopen

def SRARunTable():
    inputFile = read_argv(sys.argv[1:])
    print (inputFile)
    print ('Opening file & creating categories in Downloads/categories')
    df = pd.read_csv(inputFile, sep=',', low_memory=False)
    for i in df.index:
        searchString = df.iloc[i,:].to_string(header=False, index=False)
        if re.search('HMP_', searchString):
            #store first element
            runIdentifier = df.iloc[i][0]
            directory  = df.iloc[i]['biospecimen_repository']
            #make a directory if it does not exisit yet
            to_directory('categories/' + directory) #set dir to "Downloads"
            #download the website
            scrape_website(runIdentifier, searchString)
            #obtain the oTaxAnalysisData object
            #store file, first column is searchString


def scrape_website(id, header):
    ws = 'https://trace.ncbi.nlm.nih.gov/Traces/sra/?run='+id
    outFile = id + '.txt'
    try:
        file_exists(outFile)
    except:
        fileContent = ''
        print ("downloading " + id)
        try:
            req = Request(ws, headers={'User-Agent': 'XYZ/3.0'})
            response = urlopen(req, timeout=50).read()
            webpage = response.decode('utf-8')
            object = re.search(r"oTaxAnalysisData.*\}\}\,.*\n0]\;", webpage, re.DOTALL)
            fileContent = object[0]
            #clean up
            fileContent = fileContent.replace('oTaxAnalysisData =', '')
            fileContent = fileContent.replace('0];', '')
            header = "\t".join(header.split())
            fileContent = '#' + header + "\n" + fileContent
            #save
            storeWebSite(outFile, fileContent)
        except:
            print ('no object')
            pass

def file_exists(f):
    path = Path(f)
    if path.is_file():
        print(f'The file {f} exists')
        return True
    else:
        return 1/0


def storeWebSite(o, w):
    with open(o, 'a') as f:
        f.write(w)


def to_directory(targetDirectory):
    #set the directory
    my_dl_path = os.path.join(Path.home(), "Downloads/" + targetDirectory)
    Path(my_dl_path).mkdir(parents=True, exist_ok=True)
    os.chdir(my_dl_path)


def read_argv(argv):
    inputFile = ''
    try:
        opts, args = getopt.getopt(argv,"hi:",["ifile="])
    except getopt.GetoptError:
        print ('test.py -i <inputfile>')
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print ('test.py -i <inputfile>')
            sys.exit()
        elif opt in ("-i", "--ifile"):
            inputFile = arg
    print ('Input file is "', inputFile)
    return (inputFile)




#main
if __name__ == '__main__':
    read_argv(sys.argv[1:])
