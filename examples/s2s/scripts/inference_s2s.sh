#!/bin/bash
# export PYTHONPATH=/root/whisper:$PYTHONPATH
export PYTHONPATH=/root/fairseq:$PYTHONPATH
export CUDA_VISIBLE_DEVICES=0
export TOKENIZERS_PARALLELISM=false
export OMP_NUM_THREADS=1
export LD_LIBRARY_PATH=/home/v-wenxichen/anaconda3/envs/slam/lib:$LD_LIBRARY_PATH
export PYDEVD_WARN_SLOW_RESOLVE_TIMEOUT=2
export CUDA_LAUNCH_BLOCKING=1

run_dir=/home/v-wenxichen/SLAM-LLM
cd $run_dir
code_dir=examples/s2s

speech_encoder_path="small"   # whisper small
llm_path="Qwen/Qwen2-0.5B"
codec_decoder_path="hubertsiuzdak/snac_24khz"

ckpt_path=/valleblob/v-wenxichen/exp/s2s/s2s_train_v0_gpu4_btz4_fp16/s2s_epoch_4_step_2946
split=test

# val_data_path=/home/v-wenxichen/data/s2s/test/${split}.jsonl
val_data_path="gpt-omni/VoiceAssistant-400K"
load_from_cache_file=true

repetition_penalty=1.2
max_new_tokens=100

decode_log=$ckpt_path/decode_${split}_rp${repetition_penalty}
decode_text_only=true

# -m debugpy --listen 5678 --wait-for-client
python $code_dir/inference_s2s_batch.py \
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
        ++model_config.codec_decoder_path=$codec_decoder_path \
        ++model_config.codec_decode=true \
        ++dataset_config.dataset=speech_dataset_s2s \
        ++dataset_config.val_data_path=$val_data_path \
        ++dataset_config.train_data_path=$val_data_path \
        ++dataset_config.input_type=mel \
        ++dataset_config.mel_size=80 \
        ++dataset_config.inference_mode=true \
        ++dataset_config.manifest_format=datasets \
        ++dataset_config.split_size=0.00002 \
        ++dataset_config.load_from_cache_file=$load_from_cache_file \
        ++train_config.model_name=s2s \
        ++train_config.freeze_encoder=true \
        ++train_config.freeze_llm=false \
        ++train_config.batching_strategy=custom \
        ++train_config.num_epochs=1 \
        ++train_config.val_batch_size=1 \
        ++train_config.num_workers_dataloader=2 \
        ++decode_log=$decode_log \
        ++ckpt_path=$ckpt_path/model.pt \
        ++decode_text_only=$decode_text_only \
        ++decode_config.repetition_penalty=$repetition_penalty \
        ++decode_config.max_new_tokens=$max_new_tokens \

# bash /home/v-wenxichen/SLAM-LLM/examples/s2s/scripts/inference_s2s.sh