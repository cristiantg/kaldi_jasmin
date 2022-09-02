# kaldi_jasmin
Kaldi project (automatic data selection, preparation, trainign ande decoding) for JASMIN (and other small datasets)


**A. Prepare your project for the first time:**

1. Install SRILM
```
# ssh rarity
# lm
cd $KALDI_PATH/tools
./install_srilm.sh Pepe Radboud pepe@ru.nl
```

2. Make sure you have the correct files in $KALDI_ROOT/src/sgmm2 and sgmm2bin
```
cd $KALDI_PATH/src/sgmm2
make
cd $KALDI_PATH/src/sgmm2bin
make 
```

3. Be sure you have enough privileges to run sh scripts:
```
cd <this_project>
chmod -R 770 ./*
```

4. Edit the absolute path of KALDI folder:
```
vi path.sh
```


**B. Run the project with:**

```

ssh thunderlane
lm
# Change values of # 0-Step1, 0-Step2 and 0-Step3
vi run.sh
my_run=_runs2022/run1
nohup time ./run.sh $my_run CLAM-USERNAME CLAM-PASSWORD &

# Check the log file in real-time:
tail -f nohup.out
```

**C. WER RESULTS (com-p and com-q G1: train:JASMIN-132 vs. test:JASMIN-10)**

```
%WER 4.73 [ 200 / 4228, 46 ins, 61 del, 93 sub ] exp/sgmm2_4_mmi_b0.1/decode_test_it1/wer_17_0.0
%WER 4.78 [ 202 / 4228, 45 ins, 68 del, 89 sub ] exp/sgmm2_4/decode_test/wer_17_0.0
%WER 4.85 [ 205 / 4228, 44 ins, 69 del, 92 sub ] exp/sgmm2_4_mmi_b0.1/decode_test_it3/wer_21_0.0
%WER 4.85 [ 205 / 4228, 46 ins, 64 del, 95 sub ] exp/sgmm2_4_mmi_b0.1/decode_test_it4/wer_18_0.0
%WER 4.90 [ 207 / 4228, 46 ins, 62 del, 99 sub ] exp/sgmm2_4_mmi_b0.1/decode_test_it2/wer_17_0.0
%WER 5.65 [ 239 / 4228, 22 ins, 111 del, 106 sub ] exp/tri4_nnet/decode_test/wer_20_0.0
%WER 5.82 [ 246 / 4228, 52 ins, 84 del, 110 sub ] exp/tri3/decode_test/wer_26_0.0
%WER 7.66 [ 324 / 4228, 47 ins, 127 del, 150 sub ] exp/tri2/decode_test/wer_21_0.0
%WER 8.40 [ 355 / 4228, 42 ins, 147 del, 166 sub ] exp/tri1/decode_test/wer_24_0.0
%WER 8.96 [ 379 / 4228, 64 ins, 132 del, 183 sub ] exp/tri3/decode_test.si/wer_25_0.0
%WER 9.01 [ 381 / 4228, 126 ins, 60 del, 195 sub ] exp/dnn4_pretrain-dbn_dnn_smbr/decode_test_it6/wer_15_0.0
%WER 10.55 [ 446 / 4228, 155 ins, 69 del, 222 sub ] exp/dnn4_pretrain-dbn_dnn_smbr/decode_test_it1/wer_14_0.5
%WER 10.97 [ 464 / 4228, 173 ins, 63 del, 228 sub ] exp/dnn4_pretrain-dbn_dnn/decode_test/wer_14_0.0
%WER 12.04 [ 509 / 4228, 46 ins, 191 del, 272 sub ] exp/mono/decode_test/wer_16_0.0
```


**D. Contact**

Cristian Tejedor-García
Email: cristian [dot] tejedorgarcia [at] ru [dot] nl
