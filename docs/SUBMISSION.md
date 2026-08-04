# Submission checklist

## Repository evidence

- CI workflow is green for lint/typecheck, MongoDB-backed tests and Docker build.
- Deploy workflow push or manual run with `deploy=false` is green without cloud access.
- Repository is private and source files are at root.
- No `.env`, credentials, AWS keys or generated `dist/` content is committed.

## Real deployment evidence (only if required)

- Docker Hub shows both immutable SHA and `latest` tags.
- ALB DNS responds on port 80.
- `/health` returns status `ok` and database `connected`.
- `/version` returns the deployed Git SHA.
- A created item persists across requests.
- Target group shows a healthy target.
- EC2 security group has no port 22 and allows port 3000 only from the ALB security group.
- GitHub uses OIDC and has no static AWS access-key secrets.

After capturing evidence, complete every relevant item in `CLEANUP.md` and attach the final empty inventory output.
