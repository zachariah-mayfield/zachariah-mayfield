import os
import subprocess
import json
from pathlib import Path

def install_requirements():
    print("Installing Python requirements...")
    subprocess.run(["pip", "install", "-r", "requirements.txt"], check=True)

def setup_playwright():
    print("Installing Playwright browsers...")
    subprocess.run(["playwright", "install"], check=True)

def validate_user_config():
    config_path = Path("config/user_profile.json")
    if not config_path.exists():
        raise FileNotFoundError("Missing config/user_profile.json. Please create it first.")
    
    with open(config_path) as f:
        config = json.load(f)
    
    resume = Path(config.get("resume_path", ""))
    if not resume.exists():
        print(f"⚠️  Resume file not found at {resume}. Please update your path in user_profile.json.")
    else:
        print("✅ Resume path found.")

    print("✅ user_profile.json loaded successfully.")

def main():
    install_requirements()
    setup_playwright()
    validate_user_config()
    print("\n✅ Environment setup complete. You're ready to run `main.py`!")

if __name__ == "__main__":
    main()
