#!/usr/bin/python3
# -*- coding: utf-8 -*-
# INPUT: Train or Test arguments (only one of them)
# OUTPUT: dict or dict_test folders
# Needs CLAM to generate the lexicon file, if not comment the proper lines
# This script generates a vocabulary file and a corpus text file from a data/train or data/test folder.
# This script also generates: nonsilence_phones.txt from a lexicon file and optional_silence.txt/silence_phones.txt
# You may use Lexiconator: https://github.com/cristiantg/lexiconator to obtain the lexicon file

import os, sys
from pathlib import Path 

if (len(sys.argv) < 12):
    print("You must add 11 arguments: MY_DIR; USER; PASSWORD; lexi_project; CLEAN; DIACRITICS; DATA_LOCAL_PATH; TRAIN_OR_TEST; CURRENT_DICT_FOLDER; HEADER_LEXICON; INPUT_FILE_PATH")
    print('e.g. python3 kaldi_jasmin/data_preparation_kaldi/dicts_prep.py kaldi_jasmin/data_preparation_kaldi USERNAME PASSWORD /home/ctejedor/python-scripts/lexiconator 0 0 kaldi_jasmin/data/local train dict "<unk><TAB>spn" /home/ctejedor/python-scripts/lexiconator/input/wordlist')
    sys.exit(-1)
MY_DIR=sys.argv[1]
USER=sys.argv[2]
PASSWORD=sys.argv[3]
lexi_project=sys.argv[4]
CLEAN=sys.argv[5]
DIACRITICS=sys.argv[6]
DATA_LOCAL_PATH=sys.argv[7]
TRAIN_OR_TEST=sys.argv[8]
CURRENT_DICT_FOLDER=sys.argv[9]
HEADER_LEXICON=sys.argv[10]
input_dict_file=sys.argv[11]


# 1. Data folder, choose between:
# TRAIN: "data/local/train/"
# TEST: "data/local/test/"
train_or_test_folder = os.path.join(DATA_LOCAL_PATH,TRAIN_OR_TEST)

# 2. Dict folder, choose between:
# TRAIN: "data/local/dict/"
# TEST: "data/local/dict_test/"
dict_folder =  os.path.join(DATA_LOCAL_PATH, CURRENT_DICT_FOLDER)
Path(dict_folder).mkdir(parents=True, exist_ok=True)
# 3. Only in the case you want to decode phoneme symbols that are not in the original train lexicon, you combine both: 
## TODO CURRENT_TEXT_FILES_VOCAB = [os.path.join(DATA_LOCAL_PATH,'train','text'), os.path.join(DATA_LOCAL_PATH,'test','text')]
CURRENT_TEXT_FILES_VOCAB = [os.path.join(train_or_test_folder,'text')]
# END-IMPORTANT: change these values accordingly


# These files that must exist before executing
# 4. Text file to obtain frequencies of the words
CURRENT_TEXT_FILES_LM = [os.path.join(train_or_test_folder,"text")]
# IMPORTANT: change these values accordingly


# 5. This file must exist after executing the first step and obtaining the text files
# with Lexiconator
# so: (wait for input())
LEXICONFILE = os.path.join(dict_folder,"lexicon.txt")

# 6. Files created automatically with this script
textForLM = os.path.join(train_or_test_folder,"textForLM")
WORDLISTFILE = os.path.join(dict_folder,"wordlist")
NONSILENCEPHONESFILE = os.path.join(dict_folder,"nonsilence_phones.txt")
OPTIONALSILPHONESFILE= os.path.join(dict_folder,'optional_silence.txt')
SILPHONESFILE= os.path.join(dict_folder,'silence_phones.txt')
SIL_PHONES = ['sil', 'spn']
OPTIONAL_SIL_PHONES = ['sil']

#############################################################################
#############################################################################
#############################################################################
# 1. Specific (only train or only test) - textForLM <> n text files without id
all_lines = []
for m_file in CURRENT_TEXT_FILES_LM:
    #print(m_file)
    with open(m_file) as f:
        for line in f: 
            #aux = line.replace("\n", "").split(" ")[1:]
            #if (len(aux) < 2) and len(aux[0])<2:
                #print(line)
            all_lines.append(line.replace("\n","").split(" ")[1:])
with open(textForLM, "w") as f:
    for line in all_lines:
        f.write(" ".join(line)+"\n")
print("Created specific "+textForLM+" file")


# 2. general file (it will include all the words specified here) wordlist <>  textForLM
wordlist = set()
for m_file in CURRENT_TEXT_FILES_VOCAB:
    if Path(m_file).is_file():
        with open(m_file) as f:
            for line in f:
                aux = line.replace("\n", "").split(" ")[1:]
                for m_word in aux:
                    wordlist.add(m_word)

wordlist = sorted(wordlist)
with open(WORDLISTFILE, "w") as f:
    for word in wordlist:
        if word!='<unk>':
            f.write(word+"\n")
print("Created generic "+WORDLISTFILE+" file")


# 3. lexicon <> G2P: 	<word> <phone 1> <phone 2>
# run "lexiconator" project by CristianTG
####input("Waiting for the "+LEXICONFILE +" to be ready (you can use Lexiconator (clean option OFF): https://github.com/cristiantg/lexiconator... Press enter when ready")
OUTPUT_LEXICONATOR_FOLDER = os.path.join(lexi_project, 'output')
os.system('cp '+os.path.join(MY_DIR, WORDLISTFILE) + ' ' + input_dict_file)
os.system('python3 '+os.path.join(lexi_project,'uber_script.py')+ ' ' + USER + ' ' + PASSWORD + ' ' + lexi_project + ' ' + CLEAN + ' ' + DIACRITICS+ ' "'+HEADER_LEXICON+'" '+input_dict_file+' '+OUTPUT_LEXICONATOR_FOLDER)
os.system('cp '+os.path.join(OUTPUT_LEXICONATOR_FOLDER,'results-final') + '/* ' + os.path.join(MY_DIR,dict_folder))


# 4. nonsilence_phones.txt <> lexicon
set_phones = set()
with open(LEXICONFILE, "r") as f:
    for line in f:
        phones = line.replace("\n", "").split("\t")[1].split(" ")
        for phone in phones:
            #"unk" must be always included the file:
            set_phones.add(phone)

set_phones = sorted(set_phones, key=lambda v: (v.upper(), v[0].islower()))
#print(len(set_phones), " ".join(set_phones))
with open(NONSILENCEPHONESFILE, "w") as f:
    for phone in set_phones:
        if phone not in SIL_PHONES:
            f.write(phone+"\n")
print("Created generic "+NONSILENCEPHONESFILE+" file")


with open(SILPHONESFILE, "w") as f:
    for phone in SIL_PHONES:
        f.write(phone+"\n")
print("Created generic "+SILPHONESFILE+" file")

with open(OPTIONALSILPHONESFILE, "w") as f:
    for phone in OPTIONAL_SIL_PHONES:
        f.write(phone+"\n")
print("Created generic "+OPTIONALSILPHONESFILE+" file")