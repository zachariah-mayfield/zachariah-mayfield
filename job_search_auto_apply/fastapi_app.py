from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field, ValidationError
from typing import List, Optional
import requests
from modules.location import get_coordinates, get_nearby_companies
from modules.jobs import find_remote_jobs, search_career_pages, filter_jobs_by_keywords
from modules.apply import auto_apply_jobs
from modules.utils import load_user_config
from modules.logger import get_logger

# Initialize logger
logger = get_logger(__name__)

app = FastAPI()

class JobSearchRequest(BaseModel):
    zip_code: str
    radius: int = Field(default=30, ge=1, le=100)
    keywords: List[str] = Field(default_factory=lambda: ["Python", "DevOps"])
    remote: bool = False
    auto_apply: bool = False

@app.get("/")
def read_root():
    return {"message": "Welcome to the Job Search API"}

@app.post("/search_jobs")
def search_jobs(req: JobSearchRequest):
    try:
        logger.info(f"Job search request: {req}")
        config = load_user_config()

        try:
            lat, lon = get_coordinates(req.zip_code)
        except requests.RequestException as e:
            logger.error("Network error when retrieving coordinates", exc_info=True)
            raise HTTPException(status_code=503, detail="Failed to retrieve location data")

        try:
            companies = get_nearby_companies(lat, lon, req.radius)
        except Exception as e:
            logger.error("Error fetching nearby companies", exc_info=True)
            raise HTTPException(status_code=500, detail="Failed to get nearby companies")

        all_jobs = []
        try:
            if req.remote:
                all_jobs += find_remote_jobs(req.keywords)
            if companies:
                all_jobs += search_career_pages(companies)
        except requests.RequestException as e:
            logger.error("Network error when searching for jobs", exc_info=True)
            raise HTTPException(status_code=503, detail="Network error during job search")
        except Exception as e:
            logger.error("Unexpected error when retrieving jobs", exc_info=True)
            raise HTTPException(status_code=500, detail="Failed to retrieve jobs")

        try:
            matched = filter_jobs_by_keywords(all_jobs, req.keywords)
        except Exception as e:
            logger.error("Error filtering jobs", exc_info=True)
            raise HTTPException(status_code=500, detail="Failed to filter jobs")

        if req.auto_apply:
            try:
                auto_apply_jobs(matched, config)
            except Exception as e:
                logger.error("Auto-apply failed", exc_info=True)
                raise HTTPException(status_code=500, detail="Failed to auto-apply to jobs")

        logger.info(f"Found {len(matched)} matching jobs")
        return matched

    except ValidationError as ve:
        logger.error("Validation error in request data", exc_info=True)
        raise HTTPException(status_code=422, detail=ve.errors())

    except Exception as e:
        logger.exception("Unhandled exception in /search_jobs")
        raise HTTPException(status_code=500, detail="Internal server error")
