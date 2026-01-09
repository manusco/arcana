# Terminal Command Boundaries

## Safe to Auto-Run
- Read commands: ls, cat, git status, git log
- Test commands: npm test, pytest
- Dev servers: npm run dev, yarn dev

## Requires Approval
- Write operations: git commit, git push
- Install operations: npm install, pip install
- File deletion: rm, git rm

## Forbidden
- System-level destruction
- Irreversible operations without confirmation
