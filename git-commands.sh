#!/bin/bash

# Git Commands Script
# This script contains common git operations as functions

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display menu
show_menu() {
    echo -e "${GREEN}=== Git Commands Script ===${NC}"
    echo "1. Initialize repository"
    echo "2. Clone repository"
    echo "3. Check status"
    echo "4. Add files"
    echo "5. Commit changes"
    echo "6. Push to remote"
    echo "7. Pull from remote"
    echo "8. Create branch"
    echo "9. Switch branch"
    echo "10. Merge branch"
    echo "11. View commit history"
    echo "12. Show current branch"
    echo "13. List all branches"
    echo "14. Stash changes"
    echo "15. Apply stash"
    echo "16. Show remotes"
    echo "17. Add remote"
    echo "18. Delete remote"
    echo "19. Delete .git folder (remove git tracking)"
    echo "0. Exit"
    echo ""
}

# Initialize a new git repository
init_repo() {
    echo -e "${YELLOW}Initializing git repository...${NC}"
    git init
    echo -e "${GREEN}Repository initialized!${NC}"
}

# Clone a repository
clone_repo() {
    read -p "Enter repository URL: " repo_url
    git clone "$repo_url"
    echo -e "${GREEN}Repository cloned!${NC}"
}

# Check repository status
check_status() {
    echo -e "${YELLOW}Checking repository status...${NC}"
    git status
}

# Add files to staging
add_files() {
    echo "What would you like to add?"
    echo "1. All files"
    echo "2. Specific file"
    read -p "Choice: " add_choice
    
    if [ "$add_choice" = "1" ]; then
        git add .
        echo -e "${GREEN}All files added to staging!${NC}"
    else
        read -p "Enter filename: " filename
        git add "$filename"
        echo -e "${GREEN}File added to staging!${NC}"
    fi
}

# Commit changes
commit_changes() {
    read -p "Enter commit message: " commit_msg
    git commit -m "$commit_msg"
    echo -e "${GREEN}Changes committed!${NC}"
}

# Push to remote
push_to_remote() {
    read -p "Enter branch name (default: main): " branch
    branch=${branch:-main}
    git push origin "$branch"
    echo -e "${GREEN}Changes pushed!${NC}"
}

# Pull from remote
pull_from_remote() {
    read -p "Enter branch name (default: main): " branch
    branch=${branch:-main}
    git pull origin "$branch"
    echo -e "${GREEN}Changes pulled!${NC}"
}

# Create new branch
create_branch() {
    read -p "Enter new branch name: " branch_name
    git branch "$branch_name"
    echo -e "${GREEN}Branch '$branch_name' created!${NC}"
}

# Switch branch
switch_branch() {
    read -p "Enter branch name to switch to: " branch_name
    git checkout "$branch_name"
    echo -e "${GREEN}Switched to branch '$branch_name'!${NC}"
}

# Merge branch
merge_branch() {
    read -p "Enter branch name to merge into current branch: " branch_name
    git merge "$branch_name"
    echo -e "${GREEN}Branch '$branch_name' merged!${NC}"
}

# View commit history
view_history() {
    read -p "How many commits to show? (default: 10): " num
    num=${num:-10}
    git log --oneline -n "$num"
}

# Show current branch
show_current_branch() {
    echo -e "${YELLOW}Current branch:${NC}"
    git branch --show-current
}

# List all branches
list_branches() {
    echo -e "${YELLOW}All branches:${NC}"
    git branch -a
}

# Stash changes
stash_changes() {
    read -p "Enter stash message (optional): " stash_msg
    if [ -z "$stash_msg" ]; then
        git stash
    else
        git stash save "$stash_msg"
    fi
    echo -e "${GREEN}Changes stashed!${NC}"
}

# Apply stash
apply_stash() {
    git stash list
    read -p "Enter stash index to apply (default: 0): " stash_idx
    stash_idx=${stash_idx:-0}
    git stash apply "stash@{$stash_idx}"
    echo -e "${GREEN}Stash applied!${NC}"
}

# Show remotes
show_remotes() {
    echo -e "${YELLOW}Remote repositories:${NC}"
    git remote -v
}

# Add remote
add_remote() {
    read -p "Enter remote name (e.g., origin): " remote_name
    read -p "Enter remote URL: " remote_url
    git remote add "$remote_name" "$remote_url"
    echo -e "${GREEN}Remote '$remote_name' added!${NC}"
}

# Delete remote
delete_remote() {
    echo -e "${YELLOW}Current remotes:${NC}"
    git remote -v
    echo ""
    read -p "Enter remote name to delete: " remote_name
    git remote remove "$remote_name"
    echo -e "${GREEN}Remote '$remote_name' deleted!${NC}"
}

# Delete .git folder
delete_git_folder() {
    echo -e "${RED}WARNING: This will completely remove git tracking from this directory!${NC}"
    echo -e "${RED}All commit history and branches will be lost!${NC}"
    read -p "Are you sure? Type 'yes' to confirm: " confirm
    
    if [ "$confirm" = "yes" ]; then
        rm -rf .git
        echo -e "${GREEN}.git folder deleted! Repository is no longer tracked by git.${NC}"
    else
        echo -e "${YELLOW}Operation cancelled.${NC}"
    fi
}

# Main loop
while true; do
    show_menu
    read -p "Enter your choice: " choice
    echo ""
    
    case $choice in
        1) init_repo ;;
        2) clone_repo ;;
        3) check_status ;;
        4) add_files ;;
        5) commit_changes ;;
        6) push_to_remote ;;
        7) pull_from_remote ;;
        8) create_branch ;;
        9) switch_branch ;;
        10) merge_branch ;;
        11) view_history ;;
        12) show_current_branch ;;
        13) list_branches ;;
        14) stash_changes ;;
        15) apply_stash ;;
        16) show_remotes ;;
        17) add_remote ;;
        18) delete_remote ;;
        19) delete_git_folder ;;
        0) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
        *) echo -e "${RED}Invalid choice. Please try again.${NC}" ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
    clear
done
