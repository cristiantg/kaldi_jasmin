#!/bin/bash 
#

if [ -f path.sh ]; then . path.sh; fi

silprob=0.5
mkdir -p data/lang_test data/train data/test


#arpa_lm=data/local/lm/3gram-mincount/lm_unpruned.gz
arpa_lm=data/local/lm/srilm.3g.gz
[ ! -f $arpa_lm ] && echo No such file $arpa_lm && exit 1;

# Copy stuff into its final locations...
#for f in spk2utt utt2spk wav.scp text segments reco2file_and_channel; do
for f in spk2utt utt2spk wav.scp text segments; do
  cp data/local/train/$f data/train/$f || exit 1;
done

#for f in spk2utt utt2spk wav.scp text segments reco2file_and_channel; do
for f in spk2utt utt2spk wav.scp text segments; do
  cp data/local/test/$f data/test/$f || exit 1;
done

rm -r data/lang_test
cp -r data/lang data/lang_test

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
   utils/eps2disambig.pl | utils/s2eps.pl | fstcompile --isymbols=data/lang_test/words.txt \
     --osymbols=data/lang_test/words.txt  --keep_isymbols=false --keep_osymbols=false | \
    fstrmepsilon > data/lang_test/G.fst
  fstisstochastic data/lang_test/G.fst



echo  "Checking how stochastic G is (the first of these numbers should be small):"
fstisstochastic data/lang_test/G.fst 

## Check lexicon.
## just have a look and make sure it seems sane.
echo "First few lines of lexicon FST:"
fstprint   --isymbols=data/lang_test/phones.txt --osymbols=data/lang_test/words.txt data/lang_test/L.fst  | head

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



