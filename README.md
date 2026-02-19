# GitHub Actions Deployment to EC2

This project demonstrates automated deployment of a static website to an AWS EC2 instance using GitHub Actions.

## Project Overview

A simple static website (`index.html`, `style.css`, `main.js`) is automatically deployed to an EC2 instance running nginx whenever code is pushed to the `labs/dev` branch.

## Infrastructure

- **Cloud Provider**: AWS
- **Compute**: EC2 instance (Ubuntu 24.04 LTS)
- **Web Server**: nginx
- **CI/CD**: GitHub Actions
- **Deployment Method**: SSH/SCP

## Architecture

1. Code is pushed to GitHub repository
2. GitHub Actions workflow is triggered
3. Files are copied to EC2 via SCP
4. Files are moved to `/usr/site/` directory
5. nginx serves files from `/usr/site/`

## Setup

### Prerequisites

- AWS EC2 instance with nginx installed
- SSH key pair configured
- GitHub repository secrets configured:
  - `EC2_HOST`: EC2 instance IP address
  - `EC2_USER`: SSH username (typically `ubuntu`)
  - `EC2_SSH_KEY`: Private SSH key content

### Server Configuration

The EC2 instance should have:
- nginx installed and running
- Directory `/usr/site/` created with proper permissions
- nginx configuration file `/etc/nginx/sites-available/ec2-static` pointing to `/usr/site/`

## Problems Encountered and Solutions

### Problem 1: Files Not Being Copied

**Issue**: The workflow was copying the entire repository (`source: ./`), including unnecessary files like `.git`, `.github`, `.env`, and `infra/` directories.

**Solution**: Changed the source to only copy specific files needed for the static site:
```yaml
source: "index.html,style.css,main.js"
```

### Problem 2: Incorrect File Copy Command

**Issue**: Using `cp -r .../*` doesn't properly handle hidden files and directories, and can fail if no files match the pattern.

**Solution**: Switched to `rsync` for more reliable file copying:
```bash
sudo rsync -av /home/${{ secrets.EC2_USER }}/temp/ /usr/site/
```

### Problem 3: nginx Showing Default Page

**Issue**: nginx was still serving the default welcome page instead of the deployed files. This was caused by:
- Default nginx configuration still being active
- Conflicting server configurations (`conflicting server name "_" on 0.0.0.0:80`)

**Solution**: Added steps to disable default configuration and ensure the custom configuration is active:
```bash
sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /etc/nginx/sites-available/ec2-static /etc/nginx/sites-enabled/ec2-static
```

### Problem 4: File Permissions

**Issue**: Files copied to `/usr/site/` might not have correct permissions for nginx to serve them.

**Solution**: Added explicit permission setting in the workflow:
```bash
sudo chown -R www-data:www-data /usr/site/
sudo chmod -R 755 /usr/site/
```

## Workflow Steps

1. **Checkout repository**: Gets the latest code
2. **Prepare SSH**: Sets up SSH keys and known_hosts
3. **Copy files via SSH**: Uses SCP to transfer files to temporary directory
4. **Execute remote SSH commands**:
   - Creates `/usr/site/` directory if needed
   - Copies files from temp to production directory
   - Sets correct file permissions
   - Configures nginx (disables default, enables custom config)
   - Reloads nginx
   - Cleans up temporary files

## Key Learnings

- Always specify exact files to deploy instead of copying entire repository
- Use `rsync` instead of `cp` for more reliable file operations
- Ensure nginx default configuration is disabled when using custom configs
- Set proper file permissions for web server user (`www-data`)
- Always test nginx configuration before reloading (`nginx -t`)

## Files Structure

```
.
├── .github/
│   └── workflows/
│       └── deploy.yml          # GitHub Actions workflow
├── infra/
│   └── terraform/              # Infrastructure as Code
├── index.html                  # Main HTML file
├── style.css                   # Stylesheet
├── main.js                     # JavaScript file
└── README.md                   # This file
```
