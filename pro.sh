prompt_git() {
    local branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
    if [[ -z "$branch" ]]; then
        return 0  # git リポジトリでなければプロンプトに何も追加しない
    fi

    local marks=""
    local status=$(git status --porcelain)

    # 各状態に応じて記号を追加
    [[ $status =~ \?\? ]] && marks+="?"  # untracked files
    [[ $status =~ ^A  ]] && marks+="+"  # staged files
    [[ $status =~ ^ M ]] && marks+="!"  # modified files
    [[ $status =~ ^R  ]] && marks+=">>" # renamed files
    [[ $status =~ ^ D ]] && marks+="x"  # deleted files
    [[ $(git stash list) ]] && marks+="$"  # stashes exist

    # ahead, behind, diverged の状態を確認
    local ahead=$(git rev-list --count @{upstream}..HEAD 2> /dev/null)
    local behind=$(git rev-list --count HEAD..@{upstream} 2> /dev/null)
    if [[ $ahead -gt 0 && $behind -gt 0 ]]; then
        marks+="<>"
    elif [[ $ahead -gt 0 ]]; then
        marks+="^"
    elif [[ $behind -gt 0 ]]; then
        marks+="v"
    fi

    # プロンプトにブランチと状態記号を表示
    echo " [$branch$marks]"
}

# PS1 はプロンプトの表示形式を定義する変数
export PS1="\$(prompt_git)\$ "
