# How to Push Project to GitHub

Follow these steps to push your F# project to GitHub.

## Step 1: Create a GitHub Repository

1. Go to [GitHub.com](https://github.com) and sign in
2. Click the **"+"** icon in the top right → **"New repository"**
3. Fill in:
   - **Repository name**: `fsharp-student-grades` (or your preferred name)
   - **Description**: "F# Student Grades Management System"
   - **Visibility**: Public or Private (your choice)
   - **DO NOT** check "Initialize with README" (we already have files)
4. Click **"Create repository"**

## Step 2: Navigate to Your Project Directory

Open Command Prompt or PowerShell in your project folder:

```bash
cd "C:\Users\Admin\Desktop\F# Project\F# project"
```

## Step 3: Initialize Git (if not already done)

```bash
git init
```

## Step 4: Add All Files (with .gitignore)

The `.gitignore` file will automatically exclude build artifacts:

```bash
git add .
```

You may see warnings about line endings (LF/CRLF) - this is normal on Windows.

## Step 5: Commit Your Changes

```bash
git commit -m "Initial commit: F# Student Grades Management System"
```

## Step 6: Add GitHub Remote

Replace `YOUR_USERNAME` and `YOUR_REPO_NAME` with your actual GitHub username and repository name:

```bash
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
```

**Example:**
```bash
git remote add origin https://github.com/johndoe/fsharp-student-grades.git
```

## Step 7: Push to GitHub

```bash
git branch -M main
git push -u origin main
```

You'll be prompted for your GitHub username and password (or Personal Access Token).

### If You Need to Use a Personal Access Token:

1. Go to GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate new token with `repo` permissions
3. Use the token as your password when pushing

## Step 8: Verify

Go to your GitHub repository page and refresh - you should see all your files!

---

## Troubleshooting

### Error: "remote origin already exists"
```bash
git remote remove origin
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
```

### Error: "failed to push some refs"
```bash
git pull origin main --allow-unrelated-histories
git push -u origin main
```

### Error: Authentication failed
- Use a Personal Access Token instead of password
- Or set up SSH keys for GitHub

### Want to exclude sensitive files?
Edit `.gitignore` and add:
```
appsettings.json
appsettings.Development.json
```

Then remove them from tracking:
```bash
git rm --cached "F# project/appsettings.json"
git commit -m "Remove sensitive config files"
```

---

## Quick Command Summary

```bash
# Navigate to project
cd "C:\Users\Admin\Desktop\F# Project\F# project"

# Initialize (if needed)
git init

# Add files
git add .

# Commit
git commit -m "Initial commit"

# Add remote (replace with your repo URL)
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git

# Push
git branch -M main
git push -u origin main
```

---

## Next Steps After Pushing

1. ✅ Add a description to your GitHub repository
2. ✅ Add topics/tags (e.g., `fsharp`, `aspnet-core`, `web-api`)
3. ✅ Consider adding a license file
4. ✅ Update README.md with more details if needed

