# Core history settings
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=50000
export SAVEHIST=50000

# Fix for Kitty: Save commands instantly as they are typed
setopt INC_APPEND_HISTORY

# Share history instantly across multiple open Kitty windows
setopt SHARE_HISTORY

# Prevent duplicate consecutive commands from cluttering history
setopt HIST_IGNORE_DUPS


# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
# Created by newuser for 5.9.2
source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export PATH=/home/zhokken/.local/bin:$PATH

export PATH=$PATH:/home/zhokken/.spicetify
export PATH=$PATH:~/.spicetify

. "$HOME/.local/share/../bin/env"

#
# start-bonsai() {
#     BONSAI_CTX="${BONSAI_CTX:-8192}" \
#     BONSAI_NGL="${BONSAI_NGL:-99}" \
#     BONSAI_MMPROJ_CPU="${BONSAI_MMPROJ_CPU:-1}" \
#     BONSAI_GGUF="models/yourunai/crack-ptq1/Bonsai-2-27B-PTQ1_0-CRACK.gguf" \
#     BONSAI_MMPROJ="models/yourunai/crack-ptq1/Ternary-Bonsai-2-27B-mmproj-Q8_0.gguf" \
#     ./scripts/start_llama_server.sh \
#         --chat-template-kwargs '{"reasoning_effort":"medium"}' \
#         "$@"
# }
# start-spark() {
#     # 1,048,576 represents the exact full 1M context window bound
#     SPARK_CTX="${SPARK_CTX:-1048576}"
#
#     # Send all layers to the GPU. Adjust downward if you hit VRAM allocation limits.
#     SPARK_NGL="${SPARK_NGL:-99}"
#
#     SPARK_GGUF="Spark-X2.5-4B-Q4_K_M.gguf"
#
#     echo "Launching Spark-X2.5 with a ${SPARK_CTX} token context window..."
#
#     ./scripts/start_llama_server.sh \
#         -m "$SPARK_GGUF" \
#         -c "$SPARK_CTX" \
#         --ngl "$SPARK_NGL" \
#         --port 8080 \
#         "$@"
}

