./format_accuracy_for_plot.sh $1/_runs2022/run28/exp/tri4_nnet/log "nnet2" "output_file.txt"
python3 plot_accuracy.py -n 1 -t "My awesome title" -i "output_file.txt"