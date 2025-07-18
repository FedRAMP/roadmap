REPO="FedRAMP/Roadmap"
LAST_WEEK=$(date -v-12d +%Y-%m-%d)

echo "## Changelog // $(date '+%Y-%m-%d')"
echo ""

# Get all issues updated in the last week
gh issue list \
    --limit 200 \
    --state all \
    --repo "$REPO" \
    --search "updated:>$LAST_WEEK" \
    --json number,title,updatedAt,url,state \
    --jq '.[]' | while read -r issue; do
    
    NUMBER=$(echo "$issue" | jq -r .number)
    TITLE=$(echo "$issue" | jq -r .title)
    STATE=$(echo "$issue" | jq -r .state)
    URL=$(echo "$issue" | jq -r .url)
        # Get the most recent comment for each issue
    COMMENT=$(gh issue view "$NUMBER" \
        --repo "$REPO" \
        --json comments \
        --jq '.comments[-1] | select(.) | {body:.body,created:.createdAt}')
    
    if [ ! -z "$COMMENT" ]; then
        BODY=$(printf '%s\n' "$COMMENT" | jq -r .body)
        CREATED=$(printf '%s\n' "$COMMENT" | jq -r .created | cut -dT -f1)
        
        echo "### $STATE Issue [#$NUMBER: $TITLE]($URL)"
        echo ""
        echo "Latest comment ($CREATED):"
        echo ""
        echo "$BODY"
        echo ""
    fi
done