#!/usr/bin/env bash

# Cristian TG

# Copyright 2012-2014  Brno University of Technology (Author: Karel Vesely)
# Apache 2.0

# This example script trains a DNN on top of fMLLR features. 
# The training is done in 3 stages,
#
# 1) RBM pre-training:
#    in this unsupervised stage we train stack of RBMs, 
#    a good starting point for frame cross-entropy trainig.
# 2) frame cross-entropy training:
#    the objective is to classify frames to correct pdfs.
# 3) sequence-training optimizing sMBR: 
#    the objective is to emphasize state-sequences with better 
#    frame accuracy w.r.t. reference alignment.

if [[ $# -ne 4 ]]; then
    echo "Please set 4 parameters: feats_nj decode_nj gmmdir data_fmllr"
    exit 2
fi

. ./cmd.sh ## You'll want to change cmd.sh to something that will work on your system.
           ## This relates to the queue.

. ./path.sh ## Source the tools/utils (import the queue.pl)

# Config:
hiddim=1024 
rbmiter=5 #20 TIMIT default
feats_nj=$1 #feats_nj=10
decode_nj=$2
# decode_nj=10 #must be as max. the number of speakers
gmmdir=$3 #gmmdir=exp/tri3
data_fmllr=$4 #data_fmllr=data-fmllr-tri3
stage=0 # resume training with --stage=N
# End of config.
. utils/parse_options.sh || exit 1;
#

if [ $stage -le 0 ]; then
  echo "stage 0"
  echo $(date)
  # Store fMLLR features, so we can train on them easily,
  # test
  dir=$data_fmllr/test
  rm -rf $dir
	[ ! -d $dir ] && mkdir -p $dir
  steps/nnet/make_fmllr_feats.sh --nj $feats_nj --cmd "$train_cmd" \
     --transform-dir $gmmdir/decode_test \
     $dir data/test $gmmdir $dir/log $dir/data || exit 1
  ## dev
  #dir=$data_fmllr/dev
  #steps/nnet/make_fmllr_feats.sh --nj $feats_nj --cmd "$train_cmd" \
  #   --transform-dir $gmmdir/decode_dev \
  #   $dir data/dev $gmmdir $dir/log $dir/data || exit 1
  # train
  dir=$data_fmllr/train
  steps/nnet/make_fmllr_feats.sh --nj $feats_nj --cmd "$train_cmd" \
     --transform-dir ${gmmdir}_ali \
     $dir data/train $gmmdir $dir/log $dir/data || exit 1
  # split the data : 90% train 10% cross-validation (held-out)
  utils/subset_data_dir_tr_cv.sh $dir ${dir}_tr90 ${dir}_cv10 || exit 1
fi

if [ $stage -le 1 ]; then
  echo "stage 1"
  echo $(date)
  # Pre-train DBN, i.e. a stack of RBMs (small database, smaller DNN)
  dir=exp/dnn4_pretrain-dbn
  rm -rf $dir
	[ ! -d $dir ] && mkdir -p $dir
  (tail --pid=$$ -F $dir/log/pretrain_dbn.log 2>/dev/null)& # forward log
  $cuda_cmd $dir/log/pretrain_dbn.log \
    steps/nnet/pretrain_dbn.sh --hid-dim $hiddim --rbm-iter $rbmiter $data_fmllr/train $dir || exit 1;
fi

if [ $stage -le 2 ]; then
  echo "stage 2"
  echo $(date)
  # Train the DNN optimizing per-frame cross-entropy.
  dir=exp/dnn4_pretrain-dbn_dnn
  rm -rf $dir
	[ ! -d $dir ] && mkdir -p $dir
  ali=${gmmdir}_ali
  feature_transform=exp/dnn4_pretrain-dbn/final.feature_transform
  dbn=exp/dnn4_pretrain-dbn/6.dbn
  (tail --pid=$$ -F $dir/log/train_nnet.log 2>/dev/null)& # forward log
  # Train
  $cuda_cmd $dir/log/train_nnet.log \
    steps/nnet/train.sh --feature-transform $feature_transform --dbn $dbn --hid-layers 0 --learn-rate 0.008 \
    $data_fmllr/train_tr90 $data_fmllr/train_cv10 data/lang $ali $ali $dir || exit 1;
  # Decode (reuse HCLG graph)
  steps/nnet/decode.sh --nj $decode_nj --cmd "$decode_cmd" --acwt 0.2 \
    $gmmdir/graph $data_fmllr/test $dir/decode_test || exit 1;
  #steps/nnet/decode.sh --nj $decode_nj --cmd "$decode_cmd" --acwt 0.2 \
  #  $gmmdir/graph $data_fmllr/dev $dir/decode_dev || exit 1;
fi


# Sequence training using sMBR criterion, we do Stochastic-GD 
# with per-utterance updates. We use usually good acwt 0.1
dir=exp/dnn4_pretrain-dbn_dnn_smbr
rm -rf $dir
[ ! -d $dir ] && mkdir -p $dir
srcdir=exp/dnn4_pretrain-dbn_dnn
acwt=0.2

if [ $stage -le 3 ]; then
  echo "stage 3"
  echo $(date)
  # First we generate lattices and alignments:
  steps/nnet/align.sh --nj $decode_nj --cmd "$train_cmd" \
    $data_fmllr/train data/lang $srcdir ${srcdir}_ali || exit 1;
  steps/nnet/make_denlats.sh --nj $decode_nj --cmd "$decode_cmd" --acwt $acwt \
    --lattice-beam 10.0 --beam 18.0 \
    $data_fmllr/train data/lang $srcdir ${srcdir}_denlats || exit 1;
fi

if [ $stage -le 4 ]; then
  echo "stage 4"
  echo $(date)
  # Re-train the DNN by 6 iterations of sMBR 
  niter=6
  steps/nnet/train_mpe.sh --cmd "$cuda_cmd" --num-iters $niter --acwt $acwt \
    --do-smbr true \
    $data_fmllr/train data/lang $srcdir ${srcdir}_ali ${srcdir}_denlats $dir || exit 1
  # Decode
  for ITER in 1 $niter; do
    steps/nnet/decode.sh --nj $decode_nj --cmd "$decode_cmd" \
      --nnet $dir/${ITER}.nnet --acwt $acwt \
      $gmmdir/graph $data_fmllr/test $dir/decode_test_it${ITER} || exit 1
    #steps/nnet/decode.sh --nj $decode_nj --cmd "$decode_cmd" \
    #  --nnet $dir/${ITER}.nnet --acwt $acwt \
    #  $gmmdir/graph $data_fmllr/dev $dir/decode_dev_it${ITER} || exit 1
  done 
fi

echo Success
exit 0

# Getting results [see RESULTS file]
# for x in exp/*/decode*; do [ -d $x ] && grep WER $x/wer_* | utils/best_wer.sh; done
