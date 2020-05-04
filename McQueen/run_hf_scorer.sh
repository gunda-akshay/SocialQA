#!/usr/bin/env bash

#SBATCH -n 1
#SBATCH -e %j.ERROR
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ssrujan98@gmail.com
#module load tensorflow/1.8-agave-gpu
#SBATCH -p rcgpu1
#SBATCH -q wildfire
#SBATCH --gres=gpu:1

#set -e
module load cuda/9.2.148


python3 pytorch_transformers/models/hf_scorer.py --input_data_path dev_with_winograd_typed.jsonl   --max_number_premises 1 --max_seq_length 80 --eval_batch_size 1 --model_dir /scratch/sjaliga1/roberta-large-winograd1 --bert_model roberta-large --mcq_model roberta-mcq-weighted-sum  --output_data_path /scratch/sjaliga1/evaluation_winograd_1

