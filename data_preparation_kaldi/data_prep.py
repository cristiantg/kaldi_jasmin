#!/usr/bin/python3
# -*- coding: utf-8 -*-
# INPUT: Train or Test arguments (only one of them)
# Output: data preparation for either TRAIN or TEST (not both at the same time)
# Note: audio files with empty content or just xxx are discarded for kaldi data preparation

import re, sys, os

if (len(sys.argv) < 8):
    print("You must add 7 arguments: 0/1(TRAIN/TEST); a folder name for generating the files; the root path to this project folder; the data output folder; REC_SEPARATOR; REC_GENDER_COLUMN; GENERATE_SEGMENTS ON/OFF (1-0)")
    print('e.g. python3 data_prep.py 0 kaldi_jasmin/data_preparation_kaldi/local_cito144 kaldi_jasmin/data_preparation_kaldi kaldi_jasmin/data/local ";" 4 0')
    sys.exit(-1)

TRAIN_TEST= int(sys.argv[1])
date = sys.argv[2]
myfolder = sys.argv[3]
data_output = sys.argv[4]
REC_SEPARATOR = sys.argv[5]
REC_GENDER_COLUMN = int(sys.argv[6])
GENERATE_SEGMENTS = int(sys.argv[7])==1


ALL_SEPARATORS = {'<BLANK>':' ', '<TAB>':'\t'}
if REC_SEPARATOR in ALL_SEPARATORS:
    REC_SEPARATOR = ALL_SEPARATORS[REC_SEPARATOR]
# Discard the segmens/text etc. of single sentences which only includes:
DISCARD_SENTENCES = ['', 'xxx', 'xxx.']
EMPTY_UTT = 'xxx'
# Line delimiter
delimitatorsToCheck = ['.', '?']
## DIRECTORIES all of them ending with / ##
# output data dir
filedir = os.path.join(myfolder,data_output)+'/'
# tier dir
original_prev =  os.path.join(myfolder, date, 'tier')
original = original_prev+'_utf8/'
os.system(os.path.join(myfolder,'encoding.sh')+ ' '+original_prev+ ' '+original)
# wav files to use dir
final_wav_folder='wav_files_to_use_train/' if TRAIN_TEST==0 else 'wav_files_to_use_test/'
my_set_folder = os.path.join(myfolder, date, final_wav_folder)
os.system('mkdir -p ' + my_set_folder)
os.system('mv '+date+'/wav_files_to_use/* ' + my_set_folder)
# rec to use file
rec = os.path.join(myfolder, date, 'rec_to_use.txt')

## TRAIN/TEST SET ##
MY_PATH = 'train/' if TRAIN_TEST==0 else 'test/'
my_train_test = []
for name in os.listdir(my_set_folder):
    my_train_test.append(name)
extension = '.wav'
check_lentgh_dir=os.path.join(myfolder, 'check_duration_audio_files')
if not os.path.isdir(check_lentgh_dir):
    os.system('git clone https://github.com/cristiantg/check_duration_audio_files.git '+check_lentgh_dir)
os.system(os.path.join(check_lentgh_dir,'get_duration.sh')+ ' '+my_set_folder+ ' '+extension + ' '+ os.path.join(data_output,os.path.basename(os.path.normpath(date))+'.txt'))

# Important: we discard empty files for Kaldi (or with only 'xxx' content)
discarded_files = []

## TEXT ##
## UTT2SPK ##
def text(filenames):
    results = []
    utt2spk = []
    for name in filenames:
        basename = name.split('.')[0]
        file = open(original + basename + '.awd')
        transcript = ""        
        if GENERATE_SEGMENTS:
          m_num = 1
          at_least_one = False          
          for line in file:
            if "text =" in line:            
              aux_result = re.findall('"([^"]*)"', line)
              m_text = aux_result[0].strip()
              if len(m_text) > 0 and (m_text.lower() not in DISCARD_SENTENCES):
                transcript += " "+ m_text
                if any(ext in line for ext in delimitatorsToCheck):
                  results.append("{} {}".format(basename+"_"+str(m_num).zfill(4), transcript[1:]))
                  utt2spk.append("{} {}".format(basename+"_"+str(m_num).zfill(4), basename))
                  m_num += 1
                  transcript = ""
                  at_least_one = True
          ## Extra: only cases without . (xxx in the whole file)
          if not at_least_one:
            discarded_files.append(basename)
            ##print('Warning: This file does not contain transcriptions or only xxx:',basename,transcript)
            ##results.append("{} {}".format(basename+"_"+str(m_num).zfill(4), EMPTY_UTT))            
            ##utt2spk.append("{} {}".format(basename+"_"+str(m_num).zfill(4), basename))
            m_num += 1
            transcript = ""
            at_least_one = True
        else:          
          for line in file:          
            if "text =" in line:            
              aux_result = re.findall('"([^"]*)"', line)
              m_text = aux_result[0].strip()
              if len(m_text) > 0 and (m_text.lower() not in DISCARD_SENTENCES):
                transcript += " "+ m_text
          if len(transcript.strip())==0:
            discarded_files.append(basename)
            ##print('Warning: This file does not contain transcriptions or only xxx:',basename,transcript)
            transcript=EMPTY_UTT
            ##results.append("{} {}".format(basename, transcript.strip())) ##basename+"_"+str(m_num).zfill(4)
            ##utt2spk.append("{} {}".format(basename, basename)) ##basename+"_"+str(m_num).zfill(4)       
          else:
            results.append("{} {}".format(basename, transcript.strip())) ##basename+"_"+str(m_num).zfill(4)
            utt2spk.append("{} {}".format(basename, basename)) ##basename+"_"+str(m_num).zfill(4)    
    return '\n'.join(sorted(results)),'\n'.join(sorted(utt2spk))
text_file_path=os.path.join(filedir,MY_PATH,'text')
with open(text_file_path, 'w', encoding='utf-8') as my_text, open(filedir+MY_PATH+'utt2spk', 'w', encoding='utf-8') as my_utt:
    aux_train_test = text(my_train_test)
    my_text.write(aux_train_test[0]+ '\n')
    my_utt.write(aux_train_test[1]) # after converting to spk2utt we add '\n'


## WAV.SCP ##
def wav_scp(filenames, set):
    results = []
    for name in filenames:
        basename = name.split('.')[0]
        if basename not in discarded_files:
          results.append("{} {}".format(basename, set + name))
    return "\n".join(sorted(results))
with open(os.path.join(filedir,MY_PATH,'wav.scp'), 'w', encoding='utf-8') as my_text:
    my_text.write(wav_scp(my_train_test, my_set_folder)+ '\n')


## SPK2UTT ##
def spk2utt():
    os.system('utils/utt2spk_to_spk2utt.pl '+os.path.join(filedir,MY_PATH,'utt2spk')+' > '+os.path.join(filedir,MY_PATH,'spk2utt'))
spk2utt()
with open(os.path.join(filedir,MY_PATH,'utt2spk'), 'a') as my_text:
    my_text.write('\n')

## SEGMENTS ##
if GENERATE_SEGMENTS:
    def segments(filenames):
        results = []
        for name in filenames:
            basename = name.split('.')[0]
            if basename not in discarded_files:
              file = open(original + basename + '.awd')
              begin = ""
              end = ""
              start = True
              m_num = 1
              transcript = ''
              at_least_one = False
              for line in file:
                if "xmin =" in line and start:
                  begin = line.split('= ')[1].replace('\n', '')            
                if "xmax =" in line:
                  end = line.split('= ')[1].replace('\n', '')                   
                if "text =" in line:
                  aux_result = re.findall('"([^"]*)"', line)
                  m_text = aux_result[0].strip()            
                  if len(m_text) > 0 and (m_text.lower() not in DISCARD_SENTENCES):  
                    transcript += " "+ m_text
                    start = False
                    if any(ext in line for ext in delimitatorsToCheck):
                      results.append("{} {} {}{}".format(basename+"_"+str(m_num).zfill(4), basename, begin, end))
                      m_num += 1
                      transcript=''
                      start = True
                      at_least_one = True      
              ## Warning: file with no transcription or only xxx
              if not at_least_one:
                ##results.append("{} {} {} {}".format(basename+"_"+str(m_num).zfill(4), basename, '0', end))
                m_num += 1
                start = True
                at_least_one = True
        return '\n'.join(sorted(results))
    with open(os.path.join(filedir,MY_PATH,'segments'), 'w', encoding='utf-8') as my_text:
        my_text.write(segments(my_train_test)+ '\n')
### GENERATE_SEGMENTS

## SPK2GENDER ##
def spk2gender(filenames):
    results = []
    for name in filenames:
        file = open(rec)
        basename = name.split('.')[0]
        if basename not in discarded_files:
          for line in file:
            line = line.strip()
            fields = line.split(REC_SEPARATOR)
            if basename in line:
              if "F" == fields[REC_GENDER_COLUMN]:
                results.append("{} {}".format(basename, "f"))
              elif "M" == fields[REC_GENDER_COLUMN]:
                results.append("{} {}".format(basename, "m"))
    return "\n".join(sorted(results))
with open(os.path.join(filedir,MY_PATH,'spk2gender'), 'w', encoding='utf-8') as my_text:
    my_text.write(spk2gender(my_train_test)+ '\n')


## String normalization:
print('Filtering:')
os.system('python3 '+os.path.join(myfolder,'text_filter.py')+' '+text_file_path+" "+text_file_path)

print('discarded_files (empty or just xxx):', len(discarded_files), discarded_files)
print()