#!/usr/bin/env node

/**
 * Setup script to prepare template files for the new GitHub repository
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { execSync } from 'child_process';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.join(__dirname, '..');
const templateRepoDir = path.join(rootDir, '..', 'svelte-tauri-template');

// Files to include in template repo
const filesToInclude = [
  'template',
  'cli',
  'plugins',
  'TEMPLATE_ARCHITECTURE.md',
  'TEMPLATE_USAGE.md',
  'TEMPLATE_SUMMARY.md',
  'IMPLEMENTATION_COMPLETE.md',
  'README_TEMPLATE.md',
  '.gitignore',
  'package.json',
  'package-lock.json',
  'tsconfig.json',
  'svelte.config.js',
  'vite.config.ts',
  'eslint.config.js',
  '.adp-config.json',
  '.github/workflows',
  'scripts/bump-version.js',
  'scripts/generate-update-manifest.js',
  'scripts/update-changelog.js',
  'TAURI_SETUP.md',
  'DISTRIBUTION.md',
  'CODE_SIGNING.md',
  'MOBILE_SETUP.md',
  'CI_CD_SETUP.md',
  'TESTFLIGHT_SETUP.md',
  'AUTO_UPDATE_SETUP.md',
  'ADP_INTEGRATION.md',
  'PACKAGE_STRATEGY.md',
  'RELEASE_WORKFLOW.md',
  'docs'
];

// Files to exclude
const filesToExclude = [
  'src',
  'src-tauri',
  'build',
  'node_modules',
  '.svelte-kit',
  'CHANGELOG.md',
  'README.md', // Use README_TEMPLATE.md instead
  'signing-test.txt'
];

function copyFile(src, dest) {
  const destDir = path.dirname(dest);
  if (!fs.existsSync(destDir)) {
    fs.mkdirSync(destDir, { recursive: true });
  }
  
  const stats = fs.statSync(src);
  if (stats.isDirectory()) {
    if (!fs.existsSync(dest)) {
      fs.mkdirSync(dest, { recursive: true });
    }
    const files = fs.readdirSync(src);
    files.forEach(file => {
      if (filesToExclude.includes(file)) {
        return;
      }
      copyFile(path.join(src, file), path.join(dest, file));
    });
  } else {
    fs.copyFileSync(src, dest);
  }
}

function setupTemplateRepo() {
  console.log('🚀 Setting up template repository...\n');
  
  // Create directory if it doesn't exist
  if (!fs.existsSync(templateRepoDir)) {
    fs.mkdirSync(templateRepoDir, { recursive: true });
  }
  
  // Copy files
  console.log('📁 Copying template files...');
  filesToInclude.forEach(file => {
    const src = path.join(rootDir, file);
    const dest = path.join(templateRepoDir, file);
    
    if (fs.existsSync(src)) {
      console.log(`  ✓ ${file}`);
      copyFile(src, dest);
    } else {
      console.log(`  ⚠️  ${file} not found, skipping...`);
    }
  });
  
  // Create README.md from README_TEMPLATE.md
  const readmeTemplate = path.join(templateRepoDir, 'README_TEMPLATE.md');
  const readme = path.join(templateRepoDir, 'README.md');
  if (fs.existsSync(readmeTemplate)) {
    fs.copyFileSync(readmeTemplate, readme);
    console.log('  ✓ Created README.md from template');
  }
  
  // Initialize git repo
  console.log('\n📦 Initializing git repository...');
  process.chdir(templateRepoDir);
  
  try {
    execSync('git init', { stdio: 'inherit' });
    execSync('git add .', { stdio: 'inherit' });
    execSync('git commit -m "Initial commit: Svelte 5 + Tauri 2 cross-platform template"', { stdio: 'inherit' });
    
    console.log('\n✅ Template repository prepared!');
    console.log('\n📝 Next steps:');
    console.log(`  cd ${path.relative(rootDir, templateRepoDir)}`);
    console.log('  git remote add origin https://github.com/kayodebristol/svelte-tauri-template.git');
    console.log('  git branch -M main');
    console.log('  git push -u origin main');
    
  } catch (error) {
    console.error('❌ Error setting up git repository:', error.message);
    console.log('\nYou can manually initialize the repository:');
    console.log(`  cd ${path.relative(rootDir, templateRepoDir)}`);
    console.log('  git init');
    console.log('  git add .');
    console.log('  git commit -m "Initial commit"');
    console.log('  git remote add origin https://github.com/kayodebristol/svelte-tauri-template.git');
    console.log('  git push -u origin main');
  }
}

setupTemplateRepo();


