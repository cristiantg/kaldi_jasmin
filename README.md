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

1. Make sure you have the correct files in $KALDI_ROOT/src/sgmm2 and sgmm2bin
```
cd $KALDI_PATH/src/sgmm2
make
cd $KALDI_PATH/src/sgmm2bin
make 
```

1. Be sure you have enough privileges to run sh scripts:
```
cd <this_project>
chmod -R 770 ./*
```

1. Edit the absolute path of KALDI folder:
```
vi path.sh
```


**B. Run the project with:**

1. Change values of # 0-Step1, 0-Step2 and 0-Step3
vi run.sh
my_run=_runs2022/run1
nohup time ./run.sh CLAM-USERNAME CLAM-PASSWORD &

1. check the log file in real-time:
tail -f nohup.out


**C. WER RESULTS (com-p and com-q G1: train:JASMIN-132 vs. test:JASMIN-10)**
%WER 4.47 [ 189 / 4228, 42 ins, 58 del, 89 sub ] exp/sgmm2_4/decode_test/wer_18_0.0
%WER 4.61 [ 195 / 4228, 40 ins, 63 del, 92 sub ] exp/sgmm2_4_mmi_b0.1/decode_test_it1/wer_18_0.0
%WER 4.64 [ 196 / 4228, 37 ins, 66 del, 93 sub ] exp/sgmm2_4_mmi_b0.1/decode_test_it4/wer_18_0.0
%WER 4.64 [ 196 / 4228, 38 ins, 62 del, 96 sub ] exp/sgmm2_4_mmi_b0.1/decode_test_it3/wer_17_0.0
%WER 4.64 [ 196 / 4228, 38 ins, 67 del, 91 sub ] exp/sgmm2_4_mmi_b0.1/decode_test_it2/wer_19_0.0
%WER 5.65 [ 239 / 4228, 28 ins, 96 del, 115 sub ] exp/tri4_nnet/decode_test/wer_18_0.0
%WER 6.17 [ 261 / 4228, 50 ins, 91 del, 120 sub ] exp/tri3/decode_test/wer_31_0.0
%WER 8.07 [ 341 / 4228, 53 ins, 125 del, 163 sub ] exp/tri2/decode_test/wer_21_0.0
%WER 8.51 [ 360 / 4228, 49 ins, 148 del, 163 sub ] exp/tri1/decode_test/wer_25_0.0
%WER 9.11 [ 385 / 4228, 61 ins, 131 del, 193 sub ] exp/tri3/decode_test.si/wer_23_0.0
%WER 12.23 [ 517 / 4228, 37 ins, 212 del, 268 sub ] exp/mono/decode_test/wer_20_0.0



**D. Contact**

Cristian Tejedor-García
Email: cristian [dot] tejedorgarcia [at] ru [dot] nl
