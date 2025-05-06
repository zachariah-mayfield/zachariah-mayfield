# -----------------------------
# modules/apply.py
# -----------------------------


from selenium import webdriver

def auto_apply_jobs(jobs, config):
    # Placeholder for auto-apply using Selenium
    driver = webdriver.Chrome()
    for job in jobs:
        # Logic to apply for job
        driver.get(job['company'])
        # Assuming the driver clicks an "Apply" button
        apply_button = driver.find_element_by_id("apply_button")
        apply_button.click()
    driver.quit()







### OLD CODE ###

# def auto_apply_jobs(jobs, config):
#     for job in jobs:
#         print(f"[SIMULATION] Applying to {job['title']} at {job['company']} using resume {config['resume_path']}")

### OLD CODE ###