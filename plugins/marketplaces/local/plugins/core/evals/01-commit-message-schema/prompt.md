---
max_turns: 6
timeout_seconds: 180
allowed_tools: [Skill]
runs: 3
---
Draft the commit message for the change below. The repository is not available in
this session, so work from the description alone and do not ask follow-up
questions.

Ticket: PROJ-1234

Files changed:

- `src/Service/InvoiceMailer.php` — the constructor gained a new nullable
  parameter `?LoggerInterface $logger = null`, used to log send failures.
- `tests/Service/InvoiceMailerTest.php` — one new case asserting that sending
  still succeeds when no logger is injected.
