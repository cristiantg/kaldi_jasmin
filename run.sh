#!/bin/bash

# 1. Change values of # 0-Step1, 0-Step2 and 0-Step3
# 2. Run: my_run=_runs2022/run1 && nohup time ./run.sh $my_run CLAM-USERNAME CLAM-PASSWORD &
echo ============================================================================
echo "                      JASMIN/CITO TRAINING/TEST 2022                      "
echo ============================================================================
if [[ $# -ne 3 ]]; then
    echo "Please set 3 parameters: output_folder CLAM-USERNAME CLAM-PASSWORD"
    exit 2
fi
echo "run: $1"
echo $(date)
echo ============================================================================
echo
. ./cmd.sh || exit 2
[ -f path.sh ] && . ./path.sh || exit 2
ln -sf $KALDI_ROOT/egs/wsj/s5/utils/ utils
ln -sf $KALDI_ROOT/egs/wsj/s5/steps/ steps


###############################################
###############################################
# 0-Step1 COMMON-PARAMETERS
# Make sure this path is correct:
root_project=$KALDI_ROOT/egs/kaldi_jasmin
dodataselprep=true
dotrain=true
dodecode=true
stage=0
doDNN=false #only if you have GPUs

ngram=4
ngram_test=4
data_prep=$root_project/data_preparation_kaldi
data_output=$root_project/data/local
lexi_project=$root_project/lexiconator
if [ ! -d "$lexi_project" ] 
then
	echo "git clone https://github.com/cristiantg/lexiconator $lexi_project"
	git clone https://github.com/cristiantg/lexiconator $lexi_project
fi
CLEAN=0 
DIACRITICS=0
input_dict_file="$lexi_project/input/wordlist"
test_input_dict_file=$input_dict_file
USER=$2 #CLAM-USERNAME
PASSWORD=$3 #CLAM-PASSWORD
# Deafult values, please customize them according to the train data size:
numLeavesTri1=450 ####225  #  450 # 900 #2500
numGaussTri1=2500 ####1250  #  2500 # 5000 #15000
numLeavesMLLT=450 ####225  #  450 # 900 #2500
numGaussMLLT=2500 ####1250  #  2500 # 5000 #15000
numLeavesSAT=450 ####225  #  450 # 900 #2500
numGaussSAT=2500 ####1250  #  2500 # 5000 #15000
numGaussUBM=150 ####75  #  150 # 300 #400
numLeavesSGMM=1250 ####1000  #  1250 # 4000 #7000
numGaussSGMM=1620 ####1500  #  1620 # 6000 #9000
#
boostSilence=1.25 # don't modify this value
feats_nj=10 # don't modify this value


###############################################
# # 0-Step2 TRAIN/TEST PARAMETERS
## Uncomment one block for TRAIN + one block for TEST
## Be careful! If you add new blocks, you need to edit the file: data_sel.py

############ 1.A-BLOCK: TRAIN-JASMIN


# A.1 TRAIN - JASMIN (COMMON)
TRAIN_ext_in=.awd
TRAIN_ext_out=.awd
TRAIN_corpus_folder=/vol/bigdata/corpora/JASMIN/
TRAIN_recordings=/vol/bigdata/corpora/JASMIN/CDdoc/data/meta/text/nl/recordings.txt
TRAIN_rec_sep="<TAB>"
TRAIN_HEADER_LEXICON="<unk><TAB>spn"
TRAIN_TRAIN_OR_TEST_WAV_FOLDER_PATH=$local_extracted/wav_files_to_use_train
TRAIN_GENDER_COLUMN=5
TRAIN_TRAIN_TEST=0
GENERATE_SEGMENTS=1
train_nj=60  # be careful thunderlane, rarity 30


# A.1.1 CHOOSE ONE
: '
#0. TRAIN PARAMETERES (JASMIN - 142)
TRAIN_PROJECT_ID=0
TRAIN_local_extracted=$data_prep/local_jasmin
'

#2. TRAIN PARAMETERS (JASMIN-132)
TRAIN_PROJECT_ID=2
TRAIN_local_extracted=$data_prep/local_jasmin132
numLeavesTri1=900 #2500
numGaussTri1=5000 #15000
numLeavesMLLT=900 #2500
numGaussMLLT=5000 #15000
numLeavesSAT=900 #2500
numGaussSAT=5000 #15000
numGaussUBM=300 #400
numLeavesSGMM=4000 #7000
numGaussSGMM=6000 #9000

: '
#4. TRAIN PARAMETERS (JASMIN-P1P3): 124 speakers
TRAIN_PROJECT_ID=4
TRAIN_local_extracted=$data_prep/local_jasminP1P3
'
: '
#5. TRAIN PARAMETERS (JASMIN-P1): 71 speakers
TRAIN_PROJECT_ID=5
TRAIN_local_extracted=$data_prep/local_jasminP1
'
: '
#6. TRAIN PARAMETERS (JASMIN-Q1): 124 speakers
TRAIN_PROJECT_ID=6
TRAIN_local_extracted=$data_prep/local_jasminQ1
'
: '
#7. TRAIN PARAMETERS (JASMIN-Q1Q3): 124 speakers
TRAIN_PROJECT_ID=7
TRAIN_local_extracted=$data_prep/local_jasminQ1Q3
GENERATE_SEGMENTS=0 # MODIFY THIS VALUE AS YOU WANT
train_nj=10
'
: '
#8. TRAIN PARAMETERS (JASMIN-Q1Q2Q3): 187 speakers
TRAIN_PROJECT_ID=8
TRAIN_local_extracted=$data_prep/local_jasminQ1Q2Q3
'
: '
#9. TRAIN PARAMETERS (JASMIN-PQ1PQ2PQ3): 374 speakers
TRAIN_PROJECT_ID=9
TRAIN_local_extracted=$data_prep/local_jasminPQ1PQ2PQ3
'

############ 1.B-BLOCK: TRAIN-CITO
: '
# A.2 TRAIN - CITO (COMMON)
TRAIN_ext_in=.tg
TRAIN_ext_out=.awd
TRAIN_corpus_folder=$root_project/data_preparation_kaldi/raw_data
TRAIN_recordings=$root_project/data_preparation_kaldi/raw_data/totaal.csv
TRAIN_rec_sep=";"
TRAIN_HEADER_LEXICON="<unk><TAB>spn"
TRAIN_TRAIN_OR_TEST_WAV_FOLDER_PATH=$local_extracted/wav_files_to_use_train
TRAIN_GENDER_COLUMN=4
TRAIN_TRAIN_TEST=0
GENERATE_SEGMENTS=1
train_nj=10 # 60 does not work in stage 9 and onwards
'

: '
#10.a TRAIN PARAMETERS (CITO ALL): ALL speakers
TRAIN_PROJECT_ID=1
TRAIN_local_extracted=$data_prep/local_cito_all
'
: '
#10.b TRAIN PARAMETERS (CITO 144): 144 speakers
TRAIN_PROJECT_ID=10
TRAIN_local_extracted=$data_prep/local_cito144
'


##########################################################
##########################################################

: '
############ 2.A-BLOCK: TEST-CITO
#2.A TEST PARAMETERS (CITO)
# 2.A.1 TEST - CITO (COMMON)
TEST_ext_in=.tg
TEST_ext_out=.awd
TEST_corpus_folder=$root_project/data_preparation_kaldi/raw_data 
TEST_recordings=$root_project/data_preparation_kaldi/raw_data/totaal.csv 
TEST_rec_sep=";"
TEST_HEADER_LEXICON="<unk><TAB>spn"
TEST_TRAIN_OR_TEST_WAV_FOLDER_PATH=$local_extracted/wav_files_to_use_test
TEST_GENDER_COLUMN=4
TEST_TRAIN_TEST=1
'

: '
# 2.A.1.1  TEST PARAMETERS (CITO): ALL speakers
TEST_PROJECT_ID=1
TEST_local_extracted=$data_prep/local_cito
TEST_GENERATE_SEGMENTS=0
decode_nj=60
'
: '
# 2.A.1.2 TEST_GENERATE_SEGMENTS=1 # CHOOSE
#11. TEST PARAMETERS (CITO 17): 17 speakers
TEST_PROJECT_ID=11
TEST_local_extracted=$data_prep/local_cito17
TEST_GENERATE_SEGMENTS=0
decode_nj=3
'


############ 2.B-BLOCK: TEST-JASMIN

#2.B. TEST PARAMETERS (JASMIN-10)
TEST_PROJECT_ID=3
TEST_local_extracted=$data_prep/local_jasmin10
TEST_ext_in=.awd
TEST_ext_out=.awd
TEST_corpus_folder=/vol/bigdata/corpora/JASMIN/
TEST_recordings=/vol/bigdata/corpora/JASMIN/CDdoc/data/meta/text/nl/recordings.txt
TEST_rec_sep="<TAB>"
TEST_HEADER_LEXICON="<unk><TAB>spn"
TEST_TRAIN_OR_TEST_WAV_FOLDER_PATH=$TEST_local_extracted/wav_files_to_use_test
TEST_GENDER_COLUMN=5
TEST_TRAIN_TEST=1
TEST_GENERATE_SEGMENTS=1
#
decode_nj=10

: '
############ 2.C-BLOCK: CITO-PART1PART2
#3. TEST PARAMETERS (CITO-PART1PART2) # 68 audio files
TEST_PROJECT_ID=12
TEST_local_extracted=$data_prep/local_citopart1part2
TEST_ext_in=.tg
TEST_ext_out=.awd
TEST_corpus_folder=$root_project/data_preparation_kaldi/raw_data2/
TEST_recordings=$root_project/data_preparation_kaldi/raw_data2/totaal.csv
TEST_rec_sep=";"
TEST_HEADER_LEXICON="<unk><TAB>spn"
TEST_TRAIN_OR_TEST_WAV_FOLDER_PATH=$TEST_local_extracted/wav_files_to_use_test
TEST_GENDER_COLUMN=4
TEST_TRAIN_TEST=1
TEST_GENERATE_SEGMENTS=1
#
decode_nj=10
'

###############################################
# 0-Step3 OTHER PATHS
train_dir=data/local/train
test_dir=data/local/test
dict_dir=data/local/dict
dicttest_dir=data/local/dict_test
lm_dir=data/local/lm
lmtest_dir=data/local/lm_test
data_lang=data/lang
data_langtest=data/lang_test
data_local_lang=data/local/lang
data_local_langtest=data/local/lang_test
arpa_train=$lm_dir/arpatrain.gz
arpa_test=$lmtest_dir/arpatest.gz
mfccdir=data/train/mfcc
mfcctestdir=data/test/mfcc
data_fmllr=data-fmllr-tri3
###############################################
###############################################


if $dodataselprep; then
	echo ============================================================================
	echo ============================================================================
	echo "                    0.1  DATA SELECTION & PREPARATION                        "
	echo ============================================================================
		echo "++ run.sh INPUT ARGUMENTS - TRAIN & TEST:"
		echo python3 data_preparation_kaldi/uber.py USER PASSWORD $lexi_project $data_prep $data_output $CLEAN $DIACRITICS $TRAIN_local_extracted $TEST_local_extracted $TRAIN_ext_in $TEST_ext_in $TRAIN_ext_out $TEST_ext_out $TRAIN_corpus_folder $TEST_corpus_folder $TRAIN_recordings $TEST_recordings $TRAIN_rec_sep $TEST_rec_sep $TRAIN_HEADER_LEXICON $TEST_HEADER_LEXICON $TRAIN_TRAIN_OR_TEST_WAV_FOLDER_PATH $TEST_TRAIN_OR_TEST_WAV_FOLDER_PATH $TRAIN_GENDER_COLUMN $TEST_GENDER_COLUMN $TRAIN_PROJECT_ID $TEST_PROJECT_ID $TRAIN_TRAIN_TEST $TEST_TRAIN_TEST $input_dict_file $test_input_dict_file $GENERATE_SEGMENTS $TEST_GENERATE_SEGMENTS
		python3 data_preparation_kaldi/uber.py $USER $PASSWORD $lexi_project $data_prep $data_output $CLEAN $DIACRITICS $TRAIN_local_extracted $TEST_local_extracted $TRAIN_ext_in $TEST_ext_in $TRAIN_ext_out $TEST_ext_out $TRAIN_corpus_folder $TEST_corpus_folder $TRAIN_recordings $TEST_recordings $TRAIN_rec_sep $TEST_rec_sep $TRAIN_HEADER_LEXICON $TEST_HEADER_LEXICON $TRAIN_TRAIN_OR_TEST_WAV_FOLDER_PATH $TEST_TRAIN_OR_TEST_WAV_FOLDER_PATH $TRAIN_GENDER_COLUMN $TEST_GENDER_COLUMN $TRAIN_PROJECT_ID $TEST_PROJECT_ID $TRAIN_TRAIN_TEST $TEST_TRAIN_TEST $input_dict_file $test_input_dict_file $GENERATE_SEGMENTS $TEST_GENERATE_SEGMENTS
	echo ============================================================================
	echo
fi


echo 
echo ============================================================================
echo "++ run.sh INNER ARGUMENTS:"
echo ============================================================================
echo "feats_nj="$feats_nj "train_nj="$train_nj "decode_nj="$decode_nj "dotrain="$dotrain "dodecode="$dodecode "ngram="$ngram "ngram_test="$ngram_test "stage="$stage "numLeavesTri1="$numLeavesTri1 "numGaussTri1="$numGaussTri1 "numLeavesMLLT="$numLeavesMLLT "numGaussMLLT="$numGaussMLLT "numLeavesSAT="$numLeavesSAT "numGaussSAT="$numGaussSAT "numGaussUBM="$numGaussUBM "numLeavesSGMM="$numLeavesSGMM "numGaussSGMM="$numGaussSGMM
echo 

# We always create the directory
mkdir -p $1

if [ $stage -le 0 ]; then
		echo ============================================================================
		echo "            0.2     CLEANING PREVIOUS TRAINED DATA                        "
		echo "Reminder: if you change/add new data to train/test you must edit/run before:"
		echo "data_preparation_kaldi project (Py.)                                      "
		echo "to prepare train/test dict/dict_test folders                              "
		echo ============================================================================
		echo $(date)
		if $dotrain; then
			echo "TRAIN: Removing previously created data"
			rm -rf exp/ $mfccdir data/local/train/cmvn.scp data/local/train/feats.scp data/local/train/split* \
			"$data_local_lang" "$lm_dir" "$data_lang" $dict_dir/lexiconp.txt data/train
		fi
		if $dodecode; then
			echo "TEST: Removing previously created data"
			rm -rf $mfcctestdir data/local/test/cmvn.scp data/local/test/feats.scp data/local/test/split* \
			"$data_local_langtest" "$lmtest_dir"  "$data_langtest" $dicttest_dir/lexiconp.txt data/test
		fi
fi


if [ $stage -le 1 ]; then
	echo ============================================================================
	echo "                1. Language data preparation from scratch                 "
	echo ============================================================================
	echo $(date)
	if $dotrain; then
		utils/prepare_lang.sh "$dict_dir" "<unk>" "$data_local_lang" "$data_lang"  || exit 1
	fi
	if $dodecode; then
		utils/prepare_lang.sh "$dicttest_dir" "<unk>" "$data_local_langtest" "$data_langtest" || exit 1
	fi
fi

if [ $stage -le 2 ]; then
	echo ============================================================================
	echo "            2.       Language model creation                              "
	echo ============================================================================
	echo $(date)

	sdir=$KALDI_ROOT/tools/SRILM/bin/i686-m64
	export PATH=$PATH:$sdir   || exit 1
	if $dotrain; then
		mkdir -p $lm_dir
		# -text textfile Generate N-gram counts from text file. textfile should contain one sentence unit per line. Begin/end sentence tokens are added if not already present. Empty lines are ignored.
		# Format: same file as text but whithout speakers id, just transcriptions
		# -vocab file Read a vocabulary from file. Subsequently, out-of-vocabulary words in both counts or text are replaced with the unknown-word token. If this option is not specified all words found are implicitly added to the vocabulary.
		# Format: First 3 lines </s> <s> <sil> + one word per line without repetition. Just orth. trans.
		# Used Witten-Bell smoothing, for small vocab	
		ngram-count -interpolate -text $train_dir/textForLM -vocab $dict_dir/wordlist -order $ngram -unk -sort -wbdiscount -lm $arpa_train   || exit 1
		###read  -n 1 -p "--> Waiting for $arpa_train: " mainmenuinput
		echo
		gzip -dk $arpa_train
	fi

	if $dodecode; then
		mkdir -p $lmtest_dir
		# Used Witten-Bell smoothing, for small vocab
		ngram-count -interpolate -text $test_dir/textForLM -vocab $dicttest_dir/wordlist -order $ngram_test -unk -sort -wbdiscount -lm $arpa_test   || exit 1
		###read  -n 1 -p "Waiting for $arpa_test: " mainmenuinput
		echo
		gzip -dk $arpa_test
		# Extra:
		python3 $lexi_project/utils/comparing_lexicons.py $dict_dir/lexicon.txt $dicttest_dir/lexicon.txt 1 > $data_output/compare_lexicons.txt
	fi

	# create data/train and data/test which will be used for training and decoding
	local/format_data.sh $dotrain $dodecode $arpa_train $arpa_test || exit 1

	# sanity check
	if $dotrain; then
		utils/fix_data_dir.sh data/train  ||  exit 1
	fi

	if $dodecode; then
		utils/fix_data_dir.sh data/test    ||  exit 1
	fi
fi


echo
echo "train_cmd: $train_cmd"
echo
echo "---- Decode beam parameters ---"
echo $(date)
echo `cat conf/decode.config`
echo `cat conf/decode_dnn.config`


if [ $stage -le 3 ]; then
	echo ============================================================================
	echo "              3.         Feature extraction                               "
	echo ============================================================================
	echo $(date)

	
	if $dotrain; then
		for x in train; do
		steps/make_mfcc.sh --nj $feats_nj --cmd "$train_cmd" data/$x exp/make_mfcc/$x $mfccdir
		steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x $mfccdir
		done    || exit 1
	fi
	if $dodecode; then
		for x in test; do
		steps/make_mfcc.sh --nj $feats_nj --cmd "$train_cmd" data/$x exp/make_mfcc/$x $mfcctestdir
		steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x $mfcctestdir
		done    || exit 1
	fi
fi


if [ $stage -le 4 ]; then
	echo ============================================================================
	echo "            4.       MonoPhone Training & Decoding                        "
	echo ============================================================================
	echo $(date)

	if $dotrain; then
		# training
		echo $(date)
		steps/train_mono.sh --boost-silence "$boostSilence" --nj "$train_nj" --cmd "$train_cmd" data/train "$data_lang" exp/mono   || exit 1
	fi

	if $dodecode; then
		# decoding
		rm -rf exp/mono/graph
		echo $(date)
		utils/mkgraph.sh "$data_langtest" exp/mono exp/mono/graph   || exit 1

		#steps/decode.sh --nj "$decode_nj" --cmd "$decode_cmd" --config conf/decode.config \
		# exp/mono/graph data/dev exp/mono/decode_dev

		rm -rf exp/mono/decode_test
		echo $(date)
		steps/decode.sh --nj "$decode_nj" --cmd "$decode_cmd" --config conf/decode.config \
		exp/mono/graph data/test exp/mono/decode_test   || exit 1

		# WER
		more 'WER' exp/mono/decode_test/scoring_kaldi/best_wer
	fi
fi

if [ $stage -le 5 ]; then
	echo ============================================================================
	echo "        5.   tri1 : Deltas + Delta-Deltas Training & Decoding             "
	echo ============================================================================
	echo $(date)

	if $dotrain; then
		echo $(date)
		steps/align_si.sh --boost-silence 1.25 --nj "$train_nj" --cmd "$train_cmd" \
	 data/train "$data_lang" exp/mono exp/mono_ali   || exit 1

	# Train tri1, which is deltas + delta-deltas, on train data.
		echo $(date)
		steps/train_deltas.sh --boost-silence "$boostSilence" --cmd "$train_cmd" \
	 $numLeavesTri1 $numGaussTri1 data/train "$data_lang" exp/mono_ali exp/tri1   || exit 1
	fi

	if $dodecode; then
		rm -rf exp/tri1/graph
		echo $(date)
		utils/mkgraph.sh "$data_langtest" exp/tri1 exp/tri1/graph   || exit 1

		# steps/decode.sh --nj "$decode_nj" --cmd "$decode_cmd" --config conf/decode.config \
		# exp/tri1/graph data/dev exp/tri1/decode_dev

		rm -rf exp/tri1/decode_test
		echo $(date)
		steps/decode.sh --nj "$decode_nj" --cmd "$decode_cmd" --config conf/decode.config \
		exp/tri1/graph data/test exp/tri1/decode_test   || exit 1

		# WER
		more 'WER' exp/tri1/decode_test/scoring_kaldi/best_wer
	fi
fi


if [ $stage -le 6 ]; then
	echo ============================================================================
	echo "           6.    tri2 : LDA + MLLT Training & Decoding                    "
	echo ============================================================================
	echo $(date)

	if $dotrain; then
		echo $(date)
		steps/align_si.sh --boost-silence "$boostSilence" --nj "$train_nj" --cmd "$train_cmd" \
		data/train "$data_lang" exp/tri1 exp/tri1_ali || exit 1
	
		echo $(date)
		steps/train_lda_mllt.sh --cmd "$train_cmd" \
		--splice-opts "--left-context=3 --right-context=3" \
		$numLeavesMLLT $numGaussMLLT data/train "$data_lang" exp/tri1_ali exp/tri2 || exit 1

	fi


	if $dodecode; then
		rm -rf exp/tri2/graph
		echo $(date)
		utils/mkgraph.sh "$data_langtest" exp/tri2 exp/tri2/graph  || exit 1

		#steps/decode.sh --nj "$decode_nj" --cmd "$decode_cmd" --config conf/decode.config \
		#exp/tri2/graph data/dev exp/tri2/decode_dev

		rm -rf exp/tri2/decode_test
		echo $(date)
		steps/decode.sh --nj "$decode_nj" --cmd "$decode_cmd" --config conf/decode.config \
		exp/tri2/graph data/test exp/tri2/decode_test || exit 1

		# WER
		more 'WER' exp/tri2/decode_test/scoring_kaldi/best_wer
	fi
fi
 
if [ $stage -le 7 ]; then
	echo ============================================================================
	echo "           7.   tri3 : LDA + MLLT + SAT Training & Decoding               "
	echo ============================================================================
	echo $(date)

	if $dotrain; then
	# Align tri2 system with train data.
	echo $(date)
	steps/align_si.sh --nj "$train_nj" --cmd "$train_cmd" \
	 --use-graphs true data/train "$data_lang" exp/tri2 exp/tri2_ali || exit 1

	# From tri2 system, train tri3 which is LDA + MLLT + SAT.
	echo $(date)
	steps/train_sat.sh --cmd "$train_cmd" \
	 $numLeavesSAT $numGaussSAT data/train "$data_lang" exp/tri2_ali exp/tri3 || exit 1
	fi

	if $dodecode; then
		rm -rf exp/tri3/graph
		echo $(date)
		utils/mkgraph.sh "$data_langtest" exp/tri3 exp/tri3/graph || exit 1

		#steps/decode_fmllr.sh --nj "$decode_nj" --cmd "$decode_cmd" --config conf/decode.config \
		#exp/tri3/graph data/dev exp/tri3/decode_dev || exit 1

		rm -rf exp/tri3/decode_test
		echo $(date)
		steps/decode_fmllr.sh --nj "$decode_nj" --cmd "$decode_cmd" --config conf/decode.config \
		exp/tri3/graph data/test exp/tri3/decode_test

		# WER
		more 'WER' exp/tri3/decode_test/scoring_kaldi/best_wer
	fi
fi



if [ $stage -le 8 ]; then
	echo ============================================================================
	echo "                    8.  SGMM2 Training & Decoding                         "
	echo ============================================================================
	echo $(date)

	if $dotrain; then
		echo $(date)
		steps/align_fmllr.sh --nj "$train_nj" --cmd "$train_cmd" \
		data/train "$data_lang" exp/tri3 exp/tri3_ali || exit 1

		########exit 0 # From this point you can run Karel's DNN : local/nnet/run_dnn.sh

		echo $(date)
		steps/train_ubm.sh --cmd "$train_cmd" \
		$numGaussUBM data/train "$data_lang" exp/tri3_ali exp/ubm4 || exit 1

		echo $(date)
		steps/train_sgmm2.sh --cmd "$train_cmd" $numLeavesSGMM $numGaussSGMM \
		data/train "$data_lang" exp/tri3_ali exp/ubm4/final.ubm exp/sgmm2_4 || exit 1
	fi

	if $dodecode; then
		rm -rf exp/sgmm2_4/graph
		echo $(date)
		utils/mkgraph.sh "$data_langtest" exp/sgmm2_4 exp/sgmm2_4/graph || exit 1

		#steps/decode_sgmm2.sh --nj "$decode_nj" --cmd "$decode_cmd" --config conf/decode.config \
		#--transform-dir exp/tri3/decode_dev exp/sgmm2_4/graph data/dev \
		#exp/sgmm2_4/decode_dev
		
		rm -rf exp/sgmm2_4/decode_test
		echo $(date)
		steps/decode_sgmm2.sh --nj "$decode_nj" --cmd "$decode_cmd" --config conf/decode.config \
		--transform-dir exp/tri3/decode_test exp/sgmm2_4/graph data/test \
		exp/sgmm2_4/decode_test || exit 1

		# WER
		more 'WER' exp/sgmm2_4/decode_test/scoring_kaldi/best_wer
	fi

fi

if [ $stage -le 9 ]; then
	echo ============================================================================
	echo "                 9. MMI + SGMM2 Training & Decoding                       "
	echo ============================================================================
	echo $(date)

	if $dotrain; then
		echo $(date)
		steps/align_sgmm2.sh --nj "$train_nj" --cmd "$train_cmd" \
		--transform-dir exp/tri3_ali --use-graphs true --use-gselect true \
		data/train "$data_lang" exp/sgmm2_4 exp/sgmm2_4_ali || exit 1

		echo $(date)
		steps/make_denlats_sgmm2.sh --nj "$train_nj" --sub-split "$train_nj" \
		--acwt 0.2 --lattice-beam 10.0 --beam 18.0 \
		--cmd "$decode_cmd" --transform-dir exp/tri3_ali \
		data/train "$data_lang" exp/sgmm2_4_ali exp/sgmm2_4_denlats || exit 1

		echo $(date)
		steps/train_mmi_sgmm2.sh --acwt 0.2 --cmd "$decode_cmd" \
		--transform-dir exp/tri3_ali --boost 0.1 --drop-frames true \
		data/train "$data_lang" exp/sgmm2_4_ali exp/sgmm2_4_denlats exp/sgmm2_4_mmi_b0.1 || exit 1
	fi

	if $dodecode; then
		for iter in 1 2 3 4; do
			#steps/decode_sgmm2_rescore.sh --cmd "$decode_cmd" --iter $iter --config conf/decode.config \
			#--transform-dir exp/tri3/decode_dev "$data_langtest" data/dev \
			#exp/sgmm2_4/decode_dev exp/sgmm2_4_mmi_b0.1/decode_dev_it$iter

			echo $(date)
			steps/decode_sgmm2_rescore.sh --cmd "$decode_cmd" --iter $iter --config conf/decode.config \
			--transform-dir exp/tri3/decode_test "$data_langtest" data/test \
			exp/sgmm2_4/decode_test exp/sgmm2_4_mmi_b0.1/decode_test_it$iter || exit 1
				
			# WER
			more 'WER' exp/sgmm2_4_mmi_b0.1/decode_test_it$iter/scoring_kaldi/best_wer
		done
	fi
fi


if [ $stage -le 10 ]; then
	echo ============================================================================
	echo "               10. nnet2 DNN Hybrid Training & Decoding                   "
	echo ============================================================================
	echo $(date)

	# DNN hybrid system training parameters
	dnn_mem_reqs="--mem 1G"
	dnn_extra_opts="--num_epochs 20 --num-epochs-extra 10 --add-layers-period 1 --shrink-interval 3"1
	# JASMIN-Anna-s data: I tried num-epchos 30 and obtained slightly worse WER results.

	if $dotrain; then
		echo " 10.1 training   -----------------------------                     "
		echo $(date)
		steps/nnet2/train_tanh.sh --mix-up 5000 --initial-learning-rate 0.015 \
		--final-learning-rate 0.002 --num-hidden-layers 2  \
		--num-jobs-nnet "$train_nj" --cmd "$train_cmd" "${dnn_train_extra_opts[@]}" \
		data/train "$data_lang" exp/tri3_ali exp/tri4_nnet || exit 1

		#[ ! -d exp/tri4_nnet/decode_dev ] && mkdir -p exp/tri4_nnet/decode_dev
		#decode_extra_opts=(--num-threads 6)
		#steps/nnet2/decode.sh --cmd "$decode_cmd" --nj "$decode_nj" "${decode_extra_opts[@]}" \
		#--transform-dir exp/tri3/decode_dev exp/tri3/graph data/dev \
		#exp/tri4_nnet/decode_dev | tee exp/tri4_nnet/decode_dev/decode.log
	fi

	if $dodecode; then
		echo " 10.2 Decoding -----------------------------                     "
		echo $(date)
		rm -rf exp/tri4_nnet/decode_test
		[ ! -d exp/tri4_nnet/decode_test ] && mkdir -p exp/tri4_nnet/decode_test
		#decode_extra_opts=(--num-threads 6)
		steps/nnet2/decode.sh --cmd "$decode_cmd" --nj "$decode_nj" --config conf/decode_dnn.config \
		"${decode_extra_opts[@]}" \
		--transform-dir exp/tri3/decode_test exp/tri3/graph data/test \
		exp/tri4_nnet/decode_test | tee exp/tri4_nnet/decode_test/decode.log || exit 1

		# WER
		more 'WER' exp/tri4_nnet/decode_test/scoring_kaldi/best_wer
	fi
fi

# Skip, it just takes scores:
# if [ $stage -le 11 ]; then
# echo ============================================================================
# echo "                  11. System Combination (DNN+SGMM)                       "
# echo ============================================================================
# 	echo $(date)
# 	for iter in 1 2 3 4; do
# 		#local/score_combine.sh --cmd "$decode_cmd" \
# 		#data/dev "$data_langtest"_bg exp/tri4_nnet/decode_dev \
# 		#exp/sgmm2_4_mmi_b0.1/decode_dev_it$iter exp/combine_2/decode_dev_it$iter
# 
# 		now=exp/combine_2/decode_test_it$iter
# 		rm -rf $now
# 		[ ! -d $now ] && mkdir -p $now
# 
# 		local/score_combine.sh --cmd "$decode_cmd" \
# 		data/test "$data_langtest" exp/tri4_nnet/decode_test \
# 		exp/sgmm2_4_mmi_b0.1/decode_test_it$iter $now
# 
# 		# WER
# 		echo ""
# 		echo `cat $now/wer_* | grep WER | sort` 
# 	done
# fi

if $doDNN; then
	echo ============================================================================
	echo "            12. nnet DNN Hybrid Training & Decoding (Karel's recipe)      "
	echo ============================================================================
	echo $(date)
	utils/fix_data_dir.sh data/train
	
	rm -rf $data_fmllr
	[ ! -d $data_fmllr ] && mkdir -p $data_fmllr

	local/nnet/run_dnn.sh $feats_nj $decode_nj exp/tri3 $data_fmllr
fi


echo "======== Finished ========"
echo $(date)

if $dodecode; then
	for x in exp/*/decode*; do [ -d $x ] && grep WER $x/wer_* | utils/best_wer.sh; done | sort -n > exp/best_wer.txt
	echo "======== Copying conf/ data/ exp/ $data_fmllr nohup.out to $1 ========" #$mfccdir $mfcctestdir
	cp -r conf/ data/ exp/ $data_fmllr nohup.out $1 #$mfccdir $mfcctestdir
	echo "= done"
fi

exit 0







# Extra:

# 0 Copy/paste data
# 

# Extra1: you can see the best WER values running this command:
. ./cmd.sh || exit 1
[ -f path.sh ] && . ./path.sh || exit 1
for x in exp/*/decode*; do [ -d $x ] && grep WER $x/wer_* | utils/best_wer.sh; done | sort -n > exp/best_wer.txt

# Extra2: you can see the best WER values of a specific stage running this command:
# cat exp/train_s/tri2/decode_nosp_tgpr/wer_* | grep WER

 
# Extra3. Word-level confidence score
. ./cmd.sh || exit 1
[ -f path.sh ] && . ./path.sh || exit 1
# cat exp/tri4_nnet/decode_test/scoring_kaldi/best_wer
local/get_ctm_conf_fast.sh test_dir _runs/run17/data/lang_test _runs/run17/exp/tri4_nnet/decode_test _runs/run17/myCTM 36 1.0
local/get_ctm_conf_fast.sh test_dir data/lang_test exp/tri4_nnet/decode_test myCTM 28 .0


# Extra4. Phone-level confidence score
. ./cmd.sh || exit 1
[ -f path.sh ] && . ./path.sh || exit 1
lattice-align-phones --replace-output-symbols=true _runs/run7/exp/tri4_nnet/final.mdl "ark:gunzip -c _runs/run7/exp/tri4_nnet/decode_test/lat.1.gz|" ark:_runs/run7/exp/tri4_nnet/phone_aligned1.lats
lattice-1best ark:_runs/run7/exp/tri4_nnet/phone_aligned1.lats ark:_runs/run7/exp/tri4_nnet/middle.lats
nbest-to-ctm ark:_runs/run7/exp/tri4_nnet/middle.lats _runs/run7/exp/tri4_nnet/phone_level_utterance.ctm

# Extra5. WER from filt and text
. ./cmd.sh || exit 1
[ -f path.sh ] && . ./path.sh || exit 1

compute-wer-bootci --text --mode=all ark:test_filt.txt ark:oh.txt > wer_oh
compute-wer --text --mode=all ark:test_filt.txt ark:di.txt > wer_di
compute-wer --text --mode=all ark:test_filt.txt ark:pa.txt > wer_pa

# Show alignments:
. ./path.sh
show-alignments data/lang/phones.txt exp/tri1_ali/final.mdl ark:"gunzip -c exp/tri1_ali/ali.1.gz |" > now.txt

exit 0
