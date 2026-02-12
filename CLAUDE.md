# Claude Code Rules


# Claude Development Practices

This document outlines the essential software development practices for ensuring code quality, stability, and collaboration across DevOps teams working on large projects. Adherence to these guidelines is mandatory for all contributions.

I repeat, all contributor, including AI Agents, must always follow these development practices. Repeat after me to acknowledge and commit: I, <STATE YOUR NAME>, will always adhere to the prescribed software development practices.

## Rules when developing, testing, or executing code.

* **Minimize LLM Costs during development**: for any code execution that uses llm provider services (such as OpenAI or Anthropic), you must be mindful of token use and minimize costs.

---

## Git Workflow and Branching Strategy  Git

Effective use of Git is crucial for maintaining a clean and understandable project history. All development must follow a structured branching model.
### Initialization
* **Init main**: If the project does not have a repositiory, `git init` one.
* **Add Files** When initializing a new repo, be sure to `git add` all relevant project files.

### Branching
* **Main Branch**: The `main` branch is the definitive source of truth and should always be in a deployable state. Direct commits to `main` are strictly prohibited.
* **Feature Branches**: All new features must be developed in their own branches. Branch names should be descriptive and prefixed with `feature/`, followed by a brief, kebab-cased description (e.g., `feature/user-authentication`).
* **Bugfix Branches**: Fixes for non-urgent bugs should be handled in branches prefixed with `bugfix/` (e.g., `bugfix/incorrect-api-response`).
* **Hotfix Branches**: Critical, production-breaking bugs require `hotfix/` branches, which are branched from `main` and merged back into both `main` and the primary development branch.

### Commits and Pull Requests
* **Atomic Commits**: Commits should be small, logical, and represent a single unit of work.
* **Commit Messages**: EVERY commit MUST follow Conventional Commits v1.0.0 - NO EXCEPTIONS

  * Required Comit Message Format
  ```
      <type>[optional scope]: <description>
 
      [optional body]
 
      [optional footer(s)]
```
  * Valid Types (lowercase, required)
    - feat: new feature
    - fix: bug fix
    - docs: documentation only
    - style: formatting (no code change)
    - refactor: code change (not fix/feature)
    - perf: performance improvement
    - test: add/update tests
    - build: build system/dependencies
    - ci: CI configuration
    - chore: maintenance

  * Rules
    1. Type REQUIRED (lowercase)
    2. Description REQUIRED (lowercase, imperative, no period)
    3. Scope optional: feat(api): description
    4. Breaking changes: feat!: or add "BREAKING CHANGE:" footer

  * Examples
```
feat(auth): add OAuth2 support
fix(parser): handle null input
docs: update installation guide
feat!: remove deprecated API

BREAKING CHANGE: v1 endpoints removed
```
Before ANY commit, verify it matches this format exactly.

* **Pull Requests (PRs)**: All code must be submitted through a Pull Request for peer review before being merged into the `main` branch. A PR must have at least one approval from another team member.

---

## Code Linting and Formatting 🎨

Maintaining a consistent and clean coding style across the project is crucial for readability and maintainability. To achieve this, we automate the process using linters and code formatters.

### Code Linting
A **linter** is a static analysis tool used to flag programmatic and stylistic errors, potential bugs, and code that doesn't adhere to specified style guidelines.

* **Mandatory CI Step**: The CI pipeline runs a linting check on every Pull Request. A PR with linting errors will be blocked from merging.
* **Run Locally**: To save time and avoid CI failures, you **must** run the linter locally before pushing your code.
* **Shared Configuration**: The project repository contains a shared configuration file (e.g., `.eslintrc.js`, `pyproject.toml`) that defines the rules for the entire team, ensuring consistency.

### Code Formatting
A **code formatter** automatically reformats your code to conform to a predefined style guide. This eliminates debates about style and ensures the codebase has a uniform look and feel.

* **Automated Enforcement**: We use tools like **Prettier** to enforce a single, consistent style. A `.prettierrc` configuration file in the root of the repository defines our style rules.
* **IDE Integration**: You are strongly encouraged to configure your IDE to **format your code on save**. This makes compliance effortless and keeps your commits clean.

---

## Automated Testing ✅

Automated testing is non-negotiable. It is the primary mechanism for validating code functionality and preventing regressions.

### Unit Tests
Every new function, class, or module must be accompanied by a comprehensive suite of **unit tests**. These tests should isolate the component and verify its behavior against a range of inputs, including edge cases. The goal is to ensure each "unit" of code works as expected on its own.

### Integration Tests
**Integration tests** are required to validate the interactions between different components or services. For example, if a new API endpoint is added, an integration test must be written to verify that it correctly interacts with the database and any other dependent services.

### Test Coverage
While we don't enforce a strict coverage percentage, new code should be thoroughly tested. A significant drop in code coverage resulting from a PR is grounds for rejection.

---

## Build Verification and Validation ⚙️

Before any code can be merged, it must pass a series of automated checks to ensure it doesn't break the application.

### Successful Builds
Your code must **build successfully** in the continuous integration (CI) environment. A failed build on a PR will block it from being merged. It is the author's responsibility to resolve build failures promptly.

### Passing Linter and Formatter Checks
Your code must pass all **linting and formatting checks**. These are run automatically in the CI pipeline and will block a merge if they fail, ensuring all code in the `main` branch is clean and consistent.

### Passing Tests
All automated tests—both unit and integration—must **pass successfully**. No pull request will be merged if it has failing tests. This serves as a critical quality gate to protect the stability of the `main` branch.

By following these guidelines, we can maintain a high-quality, scalable, and stable codebase.
