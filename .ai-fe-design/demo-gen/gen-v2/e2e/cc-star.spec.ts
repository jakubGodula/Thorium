// gen-v2 — executable "expected demo path" for CC* (Playwright).
// Doubles as the acceptance test AND the live-demo script a presenter can follow.
// Run inside a generated demo:  npx playwright test e2e/cc-star.spec.ts
// Assumes the app on :5173 and the Prism mock on :4010 (npm run demo).
//
// Each step screenshots into screenshots/cc/* for review + visual regression.

import { test, expect } from '@playwright/test';

const APP = process.env.DEMO_URL ?? 'http://localhost:5173';

test.describe('CC* — observed pod: healthy → attacked → NOT WORTHY → alert', () => {
  test('plays the full critical demo path', async ({ page }) => {
    // 0. Land on the SOC console
    await page.goto(APP + '/#/overview');
    await page.getByRole('button', { name: /Run CC\* scenario|Run demo/i }).click();

    // 1. Connect: the observed pod appears (AgentRegistered)
    await expect(page.getByText('alma9-edge-01')).toBeVisible();
    await page.screenshot({ path: 'screenshots/cc/1-connected.png', fullPage: true });

    // 2. Healthy: OK telemetry + on-chain interaction visible
    await expect(page.getByText(/Healthy/i)).toBeVisible();
    await expect(page.getByText(/is_active=true/i)).toBeVisible();
    await page.screenshot({ path: 'screenshots/cc/2-healthy.png', fullPage: true });

    // 3. Attack: simulate kernel/DDoS (scenario advances)
    // (the stepper fires the attack; UI begins to react)
    await page.screenshot({ path: 'screenshots/cc/3-attack.png', fullPage: true });

    // 4. NOT WORTHY: marked + auto-isolated; critical banner appears
    const banner = page.getByRole('alert').filter({ hasText: /NOT WORTHY/i });
    await expect(banner).toBeVisible();
    await expect(banner).toContainText(/CRITICAL/i);
    await expect(page.getByText(/Auto-isolated in 2s|isolated/i)).toBeVisible();
    await page.screenshot({ path: 'screenshots/cc/4-not-worthy.png', fullPage: true });

    // 5. NOT-OK telemetry/logs clearly visible for the pod
    await expect(page.getByText(/is_active=false/i)).toBeVisible();

    // 6. Incident Command drawer: kill-chain timeline + on-chain evidence
    await banner.getByRole('button', { name: /View incident/i }).click();
    const drawer = page.getByRole('dialog', { name: /Incident Command/i });
    await expect(drawer).toBeVisible();
    await expect(drawer).toContainText(/TRIGGER_ISOLATION/i);
    await expect(drawer).toContainText(/IncidentReport/i);
    await page.screenshot({ path: 'screenshots/cc/5-incident-drawer.png', fullPage: true });

    // 7. Response hints present (placeholders OK)
    for (const label of [/Notify on-call/i, /Slack/i, /isolate|freeze|kill/i, /Claude Code/i]) {
      await expect(drawer.getByText(label)).toBeVisible();
    }
    await page.screenshot({ path: 'screenshots/cc/6-response.png', fullPage: true });
  });
});
