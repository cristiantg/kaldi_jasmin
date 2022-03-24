#!/usr/bin/python3
# -*- coding: utf-8 -*-
# run: python3 uber.py +33 params

import os, sys

if (len(sys.argv) < 34):
    print("You must add 33 arguments: $USER $PASSWORD $lexi_project $my_dir $data_output $CLEAN $DIACRITICS $TRAIN_local_extracted $TEST_local_extracted $TRAIN_ext_in $TEST_ext_in $TRAIN_ext_out $TEST_ext_out $TRAIN_corpus_folder $TEST_corpus_folder $TRAIN_recordings $TEST_recordingstotaal.csv $TRAIN_rec_sep $TEST_rec_sep $TRAIN_HEADER_LEXICON $TEST_HEADER_LEXICON $TRAIN_TRAIN_OR_TEST_WAV_FOLDER_PATH $TEST_TRAIN_OR_TEST_WAV_FOLDER_PATH $TRAIN_GENDER_COLUMN $TEST_GENDER_COLUMN $TRAIN_PROJECT_ID $TEST_PROJECT_ID $TRAIN_TRAIN_TEST $TEST_TRAIN_TEST $input_dict_file $test_input_dict_file $GENERATE_SEGMENTS $TEST_GENERATE_SEGMENTS")
    sys.exit(-1)
USER=sys.argv[1]
PASSWORD=sys.argv[2]
lexi_project=sys.argv[3]
project_folder= sys.argv[4]
data_output = sys.argv[5]
CLEAN=sys.argv[6]
DIACRITICS=sys.argv[7]
###
data_sel = sys.argv[8]
test_data_sel = sys.argv[9]
file_input_ext = sys.argv[10]
test_file_input_ext = sys.argv[11]
file_output_ext = sys.argv[12]
test_file_output_ext = sys.argv[13]
corpus_folder = sys.argv[14]
test_corpus_folder = sys.argv[15]
recordings = sys.argv[16]
test_recordings = sys.argv[17]
rec_sep = sys.argv[18]
test_rec_sep = sys.argv[19]
HEADER_LEXICON=sys.argv[20]
test_HEADER_LEXICON=sys.argv[21]
TRAIN_OR_TEST_WAV_FOLDER_PATH=sys.argv[22]
test_TRAIN_OR_TEST_WAV_FOLDER_PATH=sys.argv[23]
REC_GENDER_COLUMN=sys.argv[24]
test_REC_GENDER_COLUMN=sys.argv[25]
PROJECT_ID=sys.argv[26]
test_PROJECT_ID=sys.argv[27]
TRAIN_TEST= sys.argv[28]
test_TRAIN_TEST= sys.argv[29]
input_dict_file= sys.argv[30]
test_input_dict_file= sys.argv[31]
GENERATE_SEGMENTS = sys.argv[32]
TEST_GENERATE_SEGMENTS = sys.argv[33]


# create data directory and subdirs (delete all previous data)

if os.path.exists('utils'):
    print('Directory "utils/" exists, we can continue :)')
    
    print('\n+++ 1.A DATA SELECTION - TRAIN')
    train_folder = os.path.join(data_output,'train')
    os.system('rm -rf '+train_folder)
    os.system('mkdir -p ' + train_folder)
    os.system('python3 '+os.path.join(project_folder, 'data_sel.py') + ' ' + PROJECT_ID + ' ' + data_sel + ' '+ project_folder + ' '+ corpus_folder+ ' '+ recordings+ ' \"'+ rec_sep+'\"')
    os.system('/usr/bin/praat --run '+os.path.join(project_folder, 'step1_tg_to_std_format.praat')+ ' "'+data_sel+'/awd_files_to_use" ' +'"'+data_sel+'/praat_files_to_use" ' + file_input_ext + ' ' + str(len(file_input_ext)) + ' '+ file_output_ext)
    os.system('/usr/bin/praat --run '+os.path.join(project_folder, 'step2_extract_tier.praat')+ ' "'+data_sel+'/praat_files_to_use" ' +'"'+data_sel+'/tier"')
    print('\n+++ 1.B DATA SELECTION - TEST')
    test_folder = os.path.join(data_output,'test')
    os.system('rm -rf '+test_folder)
    os.system('mkdir -p ' + test_folder)    
    os.system('python3 '+os.path.join(project_folder, 'data_sel.py') + ' ' + test_PROJECT_ID + ' ' + test_data_sel + ' '+ project_folder + ' '+ test_corpus_folder+ ' '+ test_recordings+ ' \"'+ test_rec_sep+'\"')
    os.system('/usr/bin/praat --run '+os.path.join(project_folder, 'step1_tg_to_std_format.praat')+ ' "'+test_data_sel+'/awd_files_to_use" ' +'"'+test_data_sel+'/praat_files_to_use" ' + test_file_input_ext + ' ' + str(len(test_file_input_ext)) + ' '+ test_file_output_ext)
    os.system('/usr/bin/praat --run '+os.path.join(project_folder, 'step2_extract_tier.praat')+ ' "'+test_data_sel+'/praat_files_to_use" ' +'"'+test_data_sel+'/tier"')
    
    print('\n+++ # 2.A DATA PREPARATION - TRAIN')   
    os.system('python3 '+os.path.join(project_folder, 'data_prep.py') + ' ' + TRAIN_TEST + ' '+data_sel+ ' '+ project_folder +' '+ data_output + ' \"'+ rec_sep+'\" '+REC_GENDER_COLUMN+' '+GENERATE_SEGMENTS)    
    print('\n+++ # 2.B DATA PREPARATION - TEST')        
    os.system('python3 '+os.path.join(project_folder, 'data_prep.py') + ' ' + test_TRAIN_TEST + ' '+test_data_sel+ ' '+ project_folder +' '+ data_output + ' \"'+ test_rec_sep+'\" '+test_REC_GENDER_COLUMN+' '+TEST_GENERATE_SEGMENTS)


    print('\n+++ # 3.A DATA CHECKING - TRAIN ')
    os.system(os.path.join(project_folder,'utils/validate_data_dir.sh') + ' '+ data_output + '/train/ --no-feats')
    print('\n+++ # 3.B DATA CHECKING - TEST ')
    os.system(os.path.join(project_folder,'utils/validate_data_dir.sh') + ' '+ data_output + '/test/ --no-feats')
    
    print('\n+++ # 4.B DICT FOLDER')    
    os.system('python3 '+os.path.join(project_folder,'dicts_prep.py')+' '+project_folder+ ' '+ USER +' '+ PASSWORD+' '+ lexi_project+' '+ CLEAN+' '+ DIACRITICS+' '+ data_output +' '+ 'train'+' '+ 'dict'+' "'+HEADER_LEXICON+'" '+input_dict_file)
    print('\n+++ # 4.B DICT_TEST FOLDER')
    os.system('python3 '+os.path.join(project_folder,'dicts_prep.py')+' '+project_folder+ ' '+ USER +' '+ PASSWORD+' '+ lexi_project+' '+ CLEAN+' '+ DIACRITICS+' '+ data_output +' '+ 'test'+' '+ 'dict_test'+' "'+test_HEADER_LEXICON+'" '+test_input_dict_file)
    print('\n+++ # uber.py finished correctly')
    
else:
   print('You need a valid utils/ folder:\n Try this command: ln -s $KALDI_ROOT/egs/wsj/s5/utils/ utils') 
