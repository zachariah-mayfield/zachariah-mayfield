# -----------------------------
# modules/jobs.py
# -----------------------------

import requests

def find_remote_jobs(keywords):
    # Placeholder API call for remote jobs search
    return [{"title": f"{kw} Remote Job", "company": "RemoteCo"} for kw in keywords]

def search_career_pages(companies):
    # Placeholder search for career pages on company websites
    return [{"title": f"Job at {company}", "company": company} for company in companies]

def filter_jobs_by_keywords(jobs, keywords):
    filtered_jobs = [job for job in jobs if any(kw.lower() in job['title'].lower() for kw in keywords)]
    return filtered_jobs



### OLD CODE ###

# import re

# def find_remote_jobs(keywords):
#     return [
#         {"title": "Remote DevOps Engineer", "company": "RemoteCo", "url": "https://remoteco.com/jobs/devops"},
#     ]

# def search_career_pages(companies):
#     # Simulate job listings
#     return [
#         {"title": "IT Support Analyst", "company": company['name'], "url": company['url'] + "/job1"}
#         for company in companies
#     ]

# def filter_jobs_by_keywords(jobs, keywords):
#     return [job for job in jobs if any(re.search(k, job['title'], re.IGNORECASE) for k in keywords)]

### OLD CODE ###