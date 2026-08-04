# Student API — Lab 9

Production-style Express and TypeScript CRUD API used by a GitHub Actions CI/CD pipeline. The submission follows the required repository layout: application files and the `Dockerfile` are at repository root.

## Repository layout

```text
.
|-- .github/workflows/
|   |-- ci.yml                 # lint, type check, MongoDB-backed tests, image build
|   `-- deploy.yml             # Docker Hub push and OIDC/SSM deployment
|-- docs/
|   |-- AWS_SETUP.md           # console/CLI infrastructure checklist
|   |-- CLEANUP.md             # safe teardown order and verification
|   `-- SUBMISSION.md          # evidence and submission checklist
|-- scripts/
|   `-- aws-inventory.sh       # read-only lab resource inventory
|-- src/                       # API source
|-- tests/                     # Vitest integration tests
|-- Dockerfile
`-- LAB.md.docx                # original assignment
```

## Local validation

```bash
cp .env.example .env
npm ci
npm run lint
npm run typecheck
docker run -d --name student-api-mongo -p 27017:27017 mongo:7
MONGODB_URI=mongodb://localhost:27017/student-api-test npm test
docker build --build-arg COMMIT_SHA=local -t student-api:local .
docker rm -f student-api-mongo
```

Do not commit `.env`. AWS access keys are neither required nor supported by the workflows; deployment authentication uses GitHub OIDC.

## Cloud-free completion mode

Every push runs the `Build, push and deploy` workflow in cloud-free validation mode. A manual run also validates only by default. Docker Hub push and AWS deployment happen only when the workflow is started manually with `deploy=true`, after all required secrets and infrastructure have been configured.

See [docs/AWS_SETUP.md](docs/AWS_SETUP.md) before a real deployment and [docs/CLEANUP.md](docs/CLEANUP.md) immediately afterward.
