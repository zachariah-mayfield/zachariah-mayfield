# job_search_auto_apply/web_app.py
# web_app.py for the Flask UI-based version

import logging
from flask import Flask, request, jsonify
from modules.location import get_coordinates, get_nearby_companies
from modules.jobs import find_remote_jobs, search_career_pages, filter_jobs_by_keywords
from modules.apply import auto_apply_jobs
from modules.utils import load_user_config
from modules.logger import get_logger

# Initialize logger
logger = get_logger(__name__)

app = Flask(__name__)

@app.route('/')
def index():
    return jsonify({"message": "Welcome to the Job Search API"})

@app.route('/search_jobs', methods=['POST'])
def search_jobs():
    try:
        req = request.json
        zip_code = req['zip_code']
        radius = req.get('radius', 30)
        keywords = req.get('keywords', ['Python', 'DevOps'])
        remote = req.get('remote', False)
        auto_apply = req.get('auto_apply', False)

        logger.info(f"Job search request: {req}")
        config = load_user_config()

        lat, lon = get_coordinates(zip_code)
        companies = get_nearby_companies(lat, lon, radius)
        
        all_jobs = []
        if remote:
            all_jobs += find_remote_jobs(keywords)
        if companies:
            all_jobs += search_career_pages(companies)

        matched_jobs = filter_jobs_by_keywords(all_jobs, keywords)

        if auto_apply:
            auto_apply_jobs(matched_jobs, config)

        logger.info(f"Found {len(matched_jobs)} matching jobs")
        return jsonify(matched_jobs)
    
    except Exception as e:
        logger.error("Error during job search", exc_info=True)
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)
