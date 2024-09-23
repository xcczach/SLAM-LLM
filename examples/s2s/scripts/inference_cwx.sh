#!/bin/bash
# export PYTHONPATH=/root/whisper:$PYTHONPATH
export PYTHONPATH=/root/fairseq:$PYTHONPATH
export CUDA_VISIBLE_DEVICES=0
export TOKENIZERS_PARALLELISM=false
export OMP_NUM_THREADS=1
export LD_LIBRARY_PATH=/home/v-wenxichen/anaconda3/envs/slam/lib:$LD_LIBRARY_PATH

run_dir=/home/v-wenxichen/SLAM-LLM
cd $run_dir
code_dir=examples/s2s

speech_encoder_path="small"   # whisper small
llm_path="Qwen/Qwen2-0.5B"

output_dir=/home/v-wenxichen/exp/s2s/2024_09_23/s2s_train_test
ckpt_path=$output_dir/asr_epoch_1_step_1000
split=test
val_data_path=/home/v-wenxichen/data/s2s/test/${split}.jsonl
decode_log=$ckpt_path/decode_${split}.log

# -m debugpy --listen 5678 --wait-for-client
python -m debugpy --listen 5678 --wait-for-client $code_dir/inference_s2s_batch.py \
        --config-path "conf" \
        --config-name "prompt.yaml" \
        hydra.run.dir=$ckpt_path \
        ++model_config.llm_name=qwen2-0.5b \
        ++model_config.llm_path=$llm_path \
        ++model_config.llm_dim=896 \
        ++model_config.encoder_name=whisper \
        ++model_config.encoder_projector_ds_rate=5 \
        ++model_config.encoder_path=$speech_encoder_path \
        ++model_config.encoder_dim=768 \
        ++model_config.encoder_projector=linear \
        ++dataset_config.dataset=speech_dataset_s2s \
        ++dataset_config.val_data_path=$val_data_path \
        ++dataset_config.input_type=mel \
        ++dataset_config.mel_size=80 \
        ++dataset_config.inference_mode=true \
        ++train_config.model_name=s2s \
        ++train_config.freeze_encoder=true \
        ++train_config.freeze_llm=false \
        ++train_config.batching_strategy=custom \
        ++train_config.num_epochs=1 \
        ++train_config.val_batch_size=1 \
        ++train_config.num_workers_dataloader=2 \
        ++train_config.output_dir=$output_dir \
        ++decode_log=$decode_log \
        ++ckpt_path=$ckpt_path/model.pt \

# bash /home/v-wenxichen/SLAM-LLM/examples/s2s/scripts/inference_cwx.sh