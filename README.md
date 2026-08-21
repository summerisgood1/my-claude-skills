# My Claude skills

Skills I wrote myself, for Claude Code and any other agent that reads
`SKILL.md`. Everything else I use comes from plugins — see
[`claude-setup`](https://github.com/summerisgood1/claude-setup).

```bash
git clone git@github.com:summerisgood1/my-claude-skills.git ~/src/my-claude-skills
cd ~/src/my-claude-skills && ./install.sh
```

`install.sh` symlinks each skill into `~/.claude/skills/` and
`~/.agents/skills/`, so updating is `git pull`.

| Skill | What it's for |
| --- | --- |
| `prototyping` | Building a no-backend UI prototype that mirrors a real app, so new design work can move back into the app unchanged. |
