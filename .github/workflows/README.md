# Docker Build Workflows

This directory contains GitHub Actions workflows for building Docker images for the B3 Trading Platform.

## Workflows

### 1. `docker-image.yml` - Simple Docker Build
A straightforward workflow that builds all three service images:
- **Backend** (FastAPI)
- **Frontend** (Next.js) 
- **Market Data Service** (Python)

**Features:**
- Matrix build strategy for parallel builds
- Multi-platform support (linux/amd64, linux/arm64)
- Proper tagging with commit SHA and branch names
- GitHub Actions cache optimization
- Ready for registry push (commented out)

### 2. `docker-build-test.yml` - Advanced Build with Testing
A more comprehensive workflow that includes:
- Parallel service builds
- Image artifact storage
- Integration testing setup
- Build result summary

**Features:**
- Fail-safe matrix builds
- Image artifacts for downstream jobs
- Integration test framework
- Comprehensive metadata and labeling

## Configuration

### Registry Settings
Both workflows are configured to use GitHub Container Registry (ghcr.io):
```yaml
env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}
```

### Enabling Registry Push
To enable pushing images to the registry, uncomment these sections:

1. **Login step:**
```yaml
- name: Log in to Container Registry
  uses: docker/login-action@v3
  with:
    registry: ${{ env.REGISTRY }}
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}
```

2. **Push setting:**
```yaml
push: true  # Change from false to true
```

## Image Tags
Images are tagged with:
- Branch name (e.g., `main`, `develop`)  
- PR number (e.g., `pr-123`)
- Commit SHA (e.g., `main-abc1234`)
- `latest` for main branch builds

## Usage

### Local Testing
```bash
# Test individual service builds
docker build -t b3-backend ./backend
docker build -t b3-frontend ./frontend  
docker build -t b3-market-data ./services/market-data

# Test with docker-compose
docker-compose up --build
```

### CI/CD Integration
The workflows automatically run on:
- Push to `main` branch
- Pull requests to `main` branch

### Using Pre-built Images
Use the provided `docker-compose.ci.yml` to run with pre-built images:
```bash
docker-compose -f docker-compose.yml -f docker-compose.ci.yml up
```

## Security
- Workflows use minimal required permissions
- Images are scanned and labeled with proper metadata
- Secrets are properly managed through GitHub secrets