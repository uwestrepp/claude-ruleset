---
max_turns: 6
timeout_seconds: 240
allowed_tools: [Skill]
runs: 3
---
Any showstoppers in this? We will migrate the session store from files to Redis
by switching the handler in config, deploying at 02:00, and letting existing file
sessions expire naturally over the next 24 hours. No maintenance window.
