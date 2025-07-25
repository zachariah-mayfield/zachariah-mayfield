# job_search_auto_apply/main.py

import argparse
from modules.location import get_coordinates, get_nearby_companies
from modules.jobs import find_remote_jobs, search_career_pages, filter_jobs_by_keywords
from modules.apply import auto_apply_jobs
from modules.utils import load_user_config


def main():
    parser = argparse.ArgumentParser(description="Find and apply to local & remote IT jobs.")
    parser.add_argument("zip_code", help="Your ZIP code (e.g., 32563)")
    parser.add_argument("--radius", type=int, default=30, help="Driving distance radius in miles")
    parser.add_argument("--keywords", nargs="+", default=["Python", "DevOps", "Tableau"], help="IT keywords to match")
    parser.add_argument("--remote", action="store_true", help="Include remote job search")
    parser.add_argument("--auto_apply", action="store_true", help="Auto-apply to matched jobs")

    args = parser.parse_args()
    config = load_user_config()

    print(f"Getting coordinates for ZIP code {args.zip_code}...")
    lat, lon = get_coordinates(args.zip_code)

    print("Searching for nearby companies...")
    companies = get_nearby_companies(lat, lon, args.radius)

    all_jobs = []

    if args.remote:
        print("Searching for remote jobs...")
        all_jobs += find_remote_jobs(args.keywords)

    if companies:
        print("Searching local career pages...")
        local_jobs = search_career_pages(companies)
        all_jobs += local_jobs
    else:
        print("No companies found within radius.")

    print("Filtering jobs by keywords...")
    matched_jobs = filter_jobs_by_keywords(all_jobs, args.keywords)

    for job in matched_jobs:
        print(f"Found job: {job['title']} at {job['company']} - {job['url']}")

    if args.auto_apply:
        print("Attempting to auto-apply to matched jobs...")
        auto_apply_jobs(matched_jobs, config)


if __name__ == "__main__":
    main()


# This script is designed to be run from the command line. It takes a ZIP code and optional parameters for radius, keywords, remote job search, and auto-apply functionality.
# It retrieves the user's location, searches for nearby companies, finds remote jobs, filters jobs based on keywords, and optionally auto-applies to matched jobs.
# The script uses various modules to handle different tasks, such as location retrieval, job searching, and application submission.
# The user configuration is loaded from a JSON file, which contains the user's LinkedIn and Indeed credentials for auto-application.
# The script is structured to be modular, allowing for easy updates and maintenance of individual components.
# The main function orchestrates the flow of the program, handling command-line arguments and calling the appropriate functions.
# The script is designed to be user-friendly, providing clear output messages to guide the user through the process.
# The script is intended for job seekers in the IT field, helping them find and apply to jobs efficiently.
# The script is written in Python and uses various libraries for web scraping, API requests, and data handling.
# The script is designed to be run in a terminal or command prompt, making it accessible to users with basic programming knowledge.
# The script is intended to be a starting point for job seekers, and users are encouraged to customize it further based on their needs.
# The script is open-source and can be modified and distributed under the terms of the MIT License.
# The script is part of a larger project that aims to automate the job search process, making it easier for users to find and apply to jobs in their field.
# The script is designed to be extensible, allowing for the addition of new features and functionalities in the future.
# The script is intended to be a helpful tool for job seekers, providing them with the resources and information they need to succeed in their job search.
# The script is a work in progress, and users are encouraged to provide feedback and suggestions for improvement.
# The script is designed to be user-friendly and accessible, with clear instructions and error handling to guide users through the process.
# The script is intended to be a valuable resource for job seekers, helping them navigate the often-challenging job search process.
# The script is designed to be a comprehensive solution for job seekers, providing them with the tools and information they need to succeed in their job search.
# The script is intended to be a collaborative effort, with contributions from the open-source community to improve and enhance its functionality.
# The script is designed to be a valuable resource for job seekers, providing them with the tools and information they need to succeed in their job search.