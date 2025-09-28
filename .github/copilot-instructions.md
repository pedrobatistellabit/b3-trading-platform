# Copilot Instructions: Docker Image Build Workflow

## Goal
Create or fix the Docker image build workflow for this repository.

## Instructions
1. Ensure there is a working Dockerfile in the project root or as needed for building the application.
2. Add or update a GitHub Actions workflow (for example, .github/workflows/docker-build.yml) to:
    - Build the Docker image on push and pull request events.
    - Push the image to GitHub Packages (ghcr.io) upon successful build on main branch.
3. Use the default `GITHUB_TOKEN` for permissions to push to GitHub Packages.
4. Document the workflow usage and requirements in the repository README if necessary.

## Example Workflow (docker-build.yml)
```yaml
name: Build and Push Docker Image

on:
  push:
    branches: [main]
  pull_request:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      - name: Log in to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - name: Build and Push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: ${{ github.ref == 'refs/heads/main' }}
          tags: ghcr.io/${{ github.repository }}:latest
```