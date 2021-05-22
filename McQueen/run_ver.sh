#!/usr/bin/env bash

#SBATCH -n 1
#SBATCH -p gpu
#SBATCH -q wildfire
#SBATCH --gres=gpu:1
#SBATCH -e %j.ERROR
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ssrujan98@gmail.com
module load tensorflow/1.8-agave-gpu
#set -e

#cp scripts/Social/* .

#pip install elasticsearch elasticsearch-dsl  --no-cache-dir

#/etc/init.d/elasticsearch start

#sleep 15

#cat atomic_knowledge_sentences.txt | python insert_text_to_elasticsearch_lemmatized.py

#python preprare_dataset.py /data/socialiqa.jsonl

# python preprare_dataset.py scripts/Social/val.jsonl

# IR
#python ir_from_aristo_lemmatized.py dev_ir_lemma.tsv

#/etc/init.d/elasticsearch  stop

# RE-RANK AND CONSOLIDATION
#python merge_ir.py typed

#python clean_dataset.py dev_typed.jsonl

### BEST MODEL WEIGHTED SUM physical_merged_dev.jsonl

#tar -zxvf trained_models/soc_rob.tar

# python pytorch_transformers/models/hf_scorer.py --input_data_path dev_typed.jsonl   --max_number_premises 6 --max_seq_length 72 --eval_batch_size 1 --model_dir scratch/pbanerj6/social/social_mcq_mac_bertir_ranked_6_tw_50  --bert_model bert-large-uncased-whole-word-masking --mcq_model bert-mcq-mac  --output_data_path .


#python pytorch_transformers/models/hf_scorer.py --input_data_path dev_typed.jsonl   --max_number_premises 1 --max_seq_length 80 --eval_batch_size 1 --model_dir scratch/pbanerj6/social/robert_large_social_wstw_typ_16_5e6_1wtd_wm06  --bert_model roberta-large --mcq_model roberta-mcq-weighted-sum  --output_data_path .

#python fix_preds.py

#mv predictions2.txt /results/predictions.lst

#pip install pytorch_transformers

#git clone https://github.com/NVIDIA/apex

#pip install -v --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" ./apex
#python3 apex.py

#python3 apex/setup.py "--cpp_ext" --global-option="--cuda_ext"

#python3 pytorch_transformers/models/hf_trainer.py --training_data_path train_typed.jsonl --validation_data_path dev_typed.jsonl  --mcq_model roberta-mcq-concat  --tie_weights_weighted_sum --bert_model roberta-large --output_dir  /scratch/sjaliga1/roberta-large-model2 --num_train_epochs 10 --train_batch_size 32  --do_eval --do_train --max_seq_length 128 --do_lower_case --gradient_accumulation_steps 16 --eval_freq 1000 --learning_rate 9e-6  --warmup_steps 400 --weight_decay 0.001 --fp16

python3 pytorch_transformers/models/hf_scorer.py --input_data_path dev_updated.jsonl   --max_number_premises 1 --max_seq_length 80 --eval_batch_size 1 --model_dir /scratch/sjaliga1/roberta-large-model2 --bert_model roberta-large --mcq_model roberta-mcq-concat  --output_data_path /scratch/sjaliga1/evaluation_ver
