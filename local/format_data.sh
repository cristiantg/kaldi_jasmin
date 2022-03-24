#!/bin/bash 
# modified by Cristian TG  (2022/02/26)

if [ -f path.sh ]; then . path.sh; fi

silprob=0.5

if $1; then
  echo  "format_data lm data/train"
  mkdir -p data/train

  arpa_lm=$3
  [ ! -f $arpa_lm ] && echo No such file $arpa_lm && exit 1;

  # Copy stuff into its final locations...
  #for f in spk2utt utt2spk wav.scp text reco2file_and_channel; do
  for f in spk2utt utt2spk wav.scp text; do
    cp data/local/train/$f data/train/$f || exit 1;
  done
  m_seg=data/local/train/segments
  if [[ -f "$m_seg" ]]; then
    cp $m_seg data/train/segments || exit 1;
  fi


  echo  "-- format_data lm"
  # grep -v '<s> <s>' etc. is only for future-proofing this script.  Our
  # LM doesn't have these "invalid combinations".  These can cause 
  # determinization failures of CLG [ends up being epsilon cycles].
  # Note: remove_oovs.pl takes a list of words in the LM that aren't in
  # our word list.  Since our LM doesn't have any, we just give it
  # /test/null [we leave it in the script to show how you'd do it].
  gunzip -c "$arpa_lm" | \
    grep -v '<s> <s>' | \
    grep -v '</s> <s>' | \
    grep -v '</s> </s>' | \
    arpa2fst - | fstprint | \
    # utils/remove_oovs.pl /test/null | \
    utils/eps2disambig.pl | utils/s2eps.pl | fstcompile --isymbols=data/lang/words.txt \
      --osymbols=data/lang/words.txt  --keep_isymbols=false --keep_osymbols=false | \
      fstrmepsilon > data/lang/G.fst
    fstisstochastic data/lang/G.fst

  echo  "-- Checking how stochastic G is (the first of these numbers should be small):"
  fstisstochastic data/lang/G.fst 

  ## Check lexicon.
  ## just have a look and make sure it seems sane.
  echo "-- First few lines of lexicon FST:"
  fstprint   --isymbols=data/lang/phones.txt --osymbols=data/lang/words.txt data/lang/L.fst  | head
fi


if $2; then
  echo  "format_data lm data/test"
  mkdir -p data/train data/test

  arpa_lm_test=$4
  [ ! -f $arpa_lm_test ] && echo No such file $arpa_lm_test && exit 1;

  #for f in spk2utt utt2spk wav.scp text reco2file_and_channel; do
  for f in spk2utt utt2spk wav.scp text; do
    cp data/local/test/$f data/test/$f; #|| exit 1;
  done
  m_test_seg=data/local/test/segments
  if [[ -f "$m_test_seg" ]]; then
    cp $m_test_seg data/test/segments || exit 1;
  fi

  gunzip -c "$arpa_lm_test" | \
    grep -v '<s> <s>' | \
    grep -v '</s> <s>' | \
    grep -v '</s> </s>' | \
    arpa2fst - | fstprint | \
    # utils/remove_oovs.pl /test/null | \
    utils/eps2disambig.pl | utils/s2eps.pl | fstcompile --isymbols=data/lang_test/words.txt \
      --osymbols=data/lang_test/words.txt  --keep_isymbols=false --keep_osymbols=false | \
      fstrmepsilon > data/lang_test/G.fst
    fstisstochastic data/lang_test/G.fst


  echo  "-- Checking how stochastic G is (the first of these numbers should be small):"
  fstisstochastic data/lang_test/G.fst 

  ## Check lexicon.
  ## just have a look and make sure it seems sane.
  echo "-- First few lines of lexicon FST:"
  fstprint   --isymbols=data/lang_test/phones.txt --osymbols=data/lang_test/words.txt data/lang_test/L.fst  | head
fi



# TODO: if uncommented, include   data/lang also 
# echo Performing further checks

# # Checking that G.fst is determinizable.
# fstdeterminize data/lang_test/G.fst /test/null || echo Error determinizing G.

# # Checking that L_disambig.fst is determinizable.
# fstdeterminize data/lang_test/L_disambig.fst /test/null || echo Error determinizing L.

# # Checking that disambiguated lexicon times G is determinizable
# # Note: we do this with fstdeterminizestar not fstdeterminize, as
# # fstdeterminize was taking forever (presumbaly relates to a bug
# # in this version of OpenFst that makes determinization slow for
# # some case).
# fsttablecompose data/lang_test/L_disambig.fst data/lang_test/G.fst | \
#    fstdeterminizestar >/test/null || echo Error

# # Checking that LG is stochastic:
# fsttablecompose data/lang/L_disambig.fst data/lang_test/G.fst | \
#    fstisstochastic || echo LG is not stochastic


# echo hkust_format_data succeeded.



