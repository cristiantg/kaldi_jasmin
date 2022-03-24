#!/usr/bin/python3
# -*- coding: utf-8 -*-
# OUTPUT: folder with wav, tier_utf8, rec_to_use.txt files.
## If you add a new project (PROJECT_ID) add its corresponding lines

import re
import os
import glob
import sys
import shutil
from pathlib import Path


if (len(sys.argv) < 7):
    print("You must add 6 arguments: PROJECT_ID; a folder name for generating the files; the root path to this project folder; the corpus_folder path; the recordings file path; the recordings file separator.")
    print('python3 kaldi_jasmin/data_preparation_kaldi/data_sel.py 3 kaldi_jasmin/data_preparation_kaldi/local_jasmin10 kaldi_jasmin/data_preparation_kaldi /vol/bigdata/corpora/JASMIN/ /vol/bigdata/corpora/JASMIN/CDdoc/data/meta/text/nl/recordings.txt "<TAB>"')
    '''
    0:JASMIN
    1:CITO (all)
    2:JASMIN-132
    3:JASMIN-10
    4:JASMIN-P1P3
    5:JASMIN-P1
    6:JASMIN-Q1
    7:JASMIN-Q1Q3
    8:JASMIN-Q1Q2Q3
    9:JASMIN-PQ1PQ2PQ3
    10:CITO-144
    11:CITO-17
    12:CITO-part1part2
    '''
    sys.exit(-1)

# PROJECT_ID-MODIFY THESE VALUES ACCORDINGLY
JASMIN_IDS = {0, 2, 3, 4, 5, 6, 7, 8, 9}
CITO_IDS = {1, 10, 11, 12}
# PROJECT_ID-MODIFY THESE VALUES ACCORDINGLY
PROJECT_ID=int(sys.argv[1])
myfolder = os.path.join(sys.argv[3], sys.argv[2])
corpus_folder = sys.argv[4]
recordings = sys.argv[5]
recordings_separator = sys.argv[6]
ALL_SEPARATORS = {'<BLANK>':' ', '<TAB>':'\t'}
if recordings_separator in ALL_SEPARATORS:
    recordings_separator = ALL_SEPARATORS[recordings_separator]
number_zeros_filler = 6
selected_recordings = os.path.join(myfolder, 'rec_to_use.txt')
mp3_id_recordings = os.path.join(myfolder, 'mp3_id.txt')
wav_folder = os.path.join(myfolder, 'wav_files_to_use_original')
wav_folder_converted = os.path.join(myfolder, 'wav_files_to_use')
mp3_folder = os.path.join(myfolder, 'mp3_files_to_use')
##ort_folder = os.path.join(myfolder, 'ort_files_to_use')
##hmi_folder = os.path.join(myfolder, 'hmi_files_to_use')
awd_folder = os.path.join(myfolder, 'awd_files_to_use')

# remove my old folder
shutil.rmtree(myfolder, ignore_errors=True)

# create myfolder
path_to_myfolder = Path(myfolder)
path_to_myfolder.mkdir()
praat_folder = os.path.join(myfolder,'praat_files_to_use')
tier_folder =  os.path.join(myfolder,'tier')
os.mkdir(praat_folder)
os.mkdir(tier_folder)

# generate selected recordings, selection criteria *****
original_ids = {}
CITO_SPLIT = 74
counter = CITO_SPLIT if PROJECT_ID == 11 else 1
PROJECT_ID_2_IDS = ['fn000048','fn000049','fn000050','fn000051','fn000052','fn000059','fn000060','fn000061','fn000062','fn000063','fn000064','fn000065','fn000066','fn000067','fn000068','fn000069','fn000070','fn000071','fn000073','fn000074','fn000075','fn000076','fn000077','fn000078','fn000079','fn000080','fn000081','fn000082','fn000083','fn000084','fn000086','fn000087','fn000088','fn000090','fn000091','fn000092','fn000093','fn000094','fn000095','fn000096','fn000097','fn000098','fn000099','fn000100','fn000101','fn000102','fn000103','fn000104','fn000105','fn000106','fn000107','fn000108','fn000109','fn000110','fn000111','fn000112','fn000113','fn000115','fn000116','fn000117','fn000118','fn000119','fn000120','fn000121','fn000122','fn000123','fn000124','fn000125','fn000126','fn000127','fn000128','fn000129','fn000132','fn000133','fn000134','fn000135','fn000136','fn000137','fn000138','fn000139','fn000140','fn000141','fn000142','fn000143','fn000144','fn000145','fn000146','fn000147','fn000148','fn000149','fn000150','fn000151','fn000152','fn000153','fn000154','fn000155','fn000156','fn000157','fn000490','fn000491','fn000493','fn000494','fn000497','fn000499','fn000500','fn000502','fn000503','fn000506','fn000507','fn000509','fn000510','fn000514','fn000515','fn000517','fn000518','fn000520','fn000521','fn000523','fn000524','fn000527','fn000530','fn000531','fn000533','fn000534','fn000536','fn000537','fn000539','fn000540','fn000542','fn000543','fn000545','fn000546']
PROJECT_ID_3_IDS = ['fn000548', 'fn000549', 'fn000551', 'fn000552', 'fn000554', 'fn000555', 'fn000557', 'fn000558', 'fn000560', 'fn000561']
with open(recordings,'r', encoding='utf-8') as f_in, open(selected_recordings,'w', encoding='utf-8') as f_out:
    for line in f_in:
        w_lst = line.split(str(recordings_separator))
        if PROJECT_ID == 0:
            if w_lst[3] == '1':
                f_out.write(line)
        elif PROJECT_ID == 2: 
            if w_lst[0] in PROJECT_ID_2_IDS:
                f_out.write(line)
        elif PROJECT_ID == 3:
            if w_lst[0] in PROJECT_ID_3_IDS:
                f_out.write(line)
        elif PROJECT_ID in CITO_IDS:
            aux_field = w_lst[4]
            if w_lst[0].isdigit():
                aux_field = 'F' if aux_field == '1' else 'M'
                w_lst[4] = aux_field
                if PROJECT_ID==12:#only one ID per line
                    aux = "ci"+str(counter).zfill(number_zeros_filler)
                    original_ids[aux]= w_lst[1]
                    w_lst[1]=aux
                    w_lst[2]=aux
                    counter+=1
                    f_out.write(recordings_separator.join(w_lst).strip()+'\n')
                else:
                    if (PROJECT_ID==1 or ((PROJECT_ID == 10) and (int(w_lst[0])<CITO_SPLIT)) or ((PROJECT_ID == 11) and (int(w_lst[0])>=CITO_SPLIT))):
                        if len(w_lst[1])>0:
                            aux = "ci"+str(counter).zfill(number_zeros_filler)
                            original_ids[aux]= w_lst[1]
                            w_lst[1]=aux                
                            counter+=1
                        if len(w_lst[2])>0:
                            aux = "ci"+str(counter).zfill(number_zeros_filler)
                            original_ids[aux]= w_lst[2]
                            w_lst[2]=aux
                            counter+=1
                        f_out.write(recordings_separator.join(w_lst).strip()+'\n')
        elif PROJECT_ID == 4: # 124 = comp-p	1 -71 + comp-p	3 - 53
            if (w_lst[2] == 'comp-p') and ((w_lst[3] == '1') or (w_lst[3] == '3')):
                f_out.write(line)
        elif PROJECT_ID == 5: # 71 = comp-p	1
            if (w_lst[2] == 'comp-p') and (w_lst[3] == '1'):
                f_out.write(line)
        elif PROJECT_ID == 6: # 71 = comp-q	1
            if (w_lst[2] == 'comp-q') and (w_lst[3] == '1'):
                f_out.write(line)
        elif PROJECT_ID == 7:
            if (w_lst[2] == 'comp-q') and ((w_lst[3] == '1') or (w_lst[3] == '3')):
                f_out.write(line)
        elif PROJECT_ID == 8:
            if (w_lst[2] == 'comp-q') and ((w_lst[3] == '1') or (w_lst[3] == '2') or (w_lst[3] == '3')):
                f_out.write(line)                   
        elif PROJECT_ID == 9: 
            if ((w_lst[2] == 'comp-p') or (w_lst[2] == 'comp-q')) and ((w_lst[3] == '1') or (w_lst[3] == '2') or (w_lst[3] == '3')):
                f_out.write(line)                    
inv_original_ids = {v: k for k, v in original_ids.items()}

# create folders if not exist, remove folders if exist
myfolder_lst = [wav_folder, awd_folder, wav_folder_converted, mp3_folder] ## ort_folder, hmi_folder
for myfolder in myfolder_lst:
    if os.path.isdir(myfolder):
        filelist = [f for f in os.listdir(myfolder)]
        for f in filelist:
            os.remove(os.path.join(myfolder,f))
    else:
        os.mkdir(myfolder)

# put selected recordings .wav
name_lst = set()
with open(selected_recordings, 'r', encoding='utf-8') as f:
    for line in f:
        fields = line.split(recordings_separator)
        if PROJECT_ID in CITO_IDS:
            if len(fields[1])>0:
                name_lst.add(fields[1])
            if len(fields[2])>0:
                name_lst.add(fields[2])
        elif PROJECT_ID in JASMIN_IDS:
            name_lst.add(fields[0])       
wav_file_lst = set()
mp3_file_lst = set()
##ort_file_lst = set()
##hmi_file_lst = set()
awd_file_lst = set()
# Cristian: this is not optimized at all... but it works :)
for fname in name_lst:
    for dirpath, dirnames, filenames in os.walk(corpus_folder):
        for ff in filenames:
            if (((PROJECT_ID in CITO_IDS) and (original_ids[fname] in ff)) or ((PROJECT_ID in JASMIN_IDS) and (fname in ff))):
                if ff.endswith('.wav'):
                    wav_file_lst.add(os.path.join(dirpath, ff))
                if ff.endswith('.mp3'):
                    mp3_file_lst.add(os.path.join(dirpath, ff))
                ##if ff.endswith('.ort'):
                ##    ort_file_lst.add(os.path.join(dirpath, ff))
                ##if ff.endswith('.hmi'):
                ##    hmi_file_lst.add(os.path.join(dirpath, ff))
                if ff.endswith('.tg') or ff.endswith('.awd'):
                    awd_file_lst.add(os.path.join(dirpath, ff))


def convert_sox(orig, dest):
    os.system('sox ' + orig + ' -r 16000 -c 1 -b 16 -e signed-integer ' + dest + ' > /dev/null 2>&1')
    return None

for j in mp3_file_lst:
    #print(j)
    shutil.copy(j, mp3_folder)
if len(mp3_file_lst)>0:
    print(' | Converting MP3 files to WAV...')
local_mp3files = [f for f in os.listdir(mp3_folder) if os.path.isfile(os.path.join(mp3_folder, f))]
# 1. Change IDS
# 2. tranform to wav
for mp3 in local_mp3files:
    new_mp3_path = os.path.join(mp3_folder,inv_original_ids[mp3.replace('.mp3','')]+'.mp3')
    os.rename(os.path.join(mp3_folder,mp3), new_mp3_path)
    convert_sox(new_mp3_path, os.path.join(wav_folder_converted,os.path.basename(new_mp3_path).replace('.mp3','.wav')))
print('mp3_file_lst',len(mp3_file_lst))
if len(local_mp3files)>0 and len(inv_original_ids)>0:
    with open(mp3_id_recordings, 'w', encoding='utf-8') as output_ids:
        lines = []
        for k,v in inv_original_ids.items():
            lines.append(k+recordings_separator+v)
        output_ids.write('\n'.join(lines))

print('wav_file_lst',len(wav_file_lst))
print(' | Converting audio files to 1 channel...')
for j in wav_file_lst:
    #print(j)
    dest=shutil.copy(j, wav_folder)
    convert_sox(dest, os.path.join(wav_folder_converted,os.path.basename(dest)))

'''print('ort_file_lst',len(ort_file_lst))
for m in ort_file_lst:
    #print(m)
    shutil.copy(m, ort_folder)'''

'''print('hmi_file_lst',len(hmi_file_lst))
for n in hmi_file_lst:
    #print(n)
    shutil.copy(n, hmi_folder)'''

print('awd_file_lst',len(awd_file_lst))
for q in awd_file_lst:
    #print(q)
    if len(local_mp3files)>0 and len(inv_original_ids)>0:
        new_awd_path = os.path.join(awd_folder, inv_original_ids[os.path.basename(q).replace('.tg','')]+'.tg')
        shutil.copy(q, new_awd_path)
    else:
        shutil.copy(q, awd_folder)

print('Cleaning a bit','shutil.rmtree(',wav_folder,'ignore_errors=True)')
shutil.rmtree(wav_folder, ignore_errors=True)