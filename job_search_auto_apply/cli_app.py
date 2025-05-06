import click
from modules.location import get_coordinates, get_nearby_companies
from modules.jobs import find_remote_jobs, search_career_pages, filter_jobs_by_keywords
from modules.apply import auto_apply_jobs
from modules.utils import load_user_config

@click.command()
@click.option('--zip-code', prompt='Your ZIP code', help='ZIP code for job search location')
@click.option('--radius', default=30, help='Search radius in miles', show_default=True)
@click.option('--keywords', default='Python, DevOps', help='Comma separated list of keywords')
@click.option('--remote', is_flag=True, help='Include remote jobs')
@click.option('--auto-apply', is_flag=True, help='Automatically apply to matching jobs')
def search_jobs(zip_code, radius, keywords, remote, auto_apply):
    try:
        keywords = keywords.split(",")
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

        click.echo(f"Found {len(matched_jobs)} matching jobs.")
    except Exception as e:
        click.echo(f"Error: {e}")

if __name__ == '__main__':
    search_jobs()
