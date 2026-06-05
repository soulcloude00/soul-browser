import { chromium } from 'playwright';

(async () => {
  // headless: false makes the browser actually pop open on your screen!
  const browser = await chromium.launch({ headless: false, slowMo: 500 });
  const context = await browser.newContext();
  const page = await context.newPage();
  
  try {
    console.log("Navigating to local site...");
    await page.goto('http://localhost:5173');
    await page.waitForSelector('nav', { timeout: 5000 });
  } catch (e) {
    console.error("Failed to load page. Is the dev server running?", e);
    await browser.close();
    process.exit(1);
  }

  console.log("=== You are now looking at LIGHT MODE ===");
  await page.waitForTimeout(1000);

  console.log("Clicking theme toggle to switch to DARK MODE...");
  await page.click('[aria-label="Toggle theme"]');
  
  console.log("Browser will stay open! Feel free to click around and test the dark mode toggle yourself.");
  // Wait indefinitely so the browser stays open!
  await new Promise(() => {});
})();
