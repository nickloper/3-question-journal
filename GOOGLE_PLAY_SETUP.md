# Google Play Console Setup Guide

This guide will walk you through setting up in-app purchases (subscriptions) for the 3 Question Journal app in Google Play Console.

## Prerequisites

1. A Google Play Console account ($25 one-time fee)
2. The app APK built and ready for upload
3. Your app must be published (at least in internal testing track)

## Step 1: Upload Your App

1. Go to [Google Play Console](https://play.google.com/console)
2. Create a new app or select your existing app
3. Navigate to **Production** (or **Internal testing** for testing)
4. Click **Create new release**
5. Upload the APK from GitHub Actions artifacts
6. Complete the required store listing information
7. Publish to at least Internal Testing track

## Step 2: Create Subscription Products

### Important: Products must be created BEFORE testing subscriptions

1. In Google Play Console, go to **Monetize** → **Subscriptions**
2. Click **Create subscription**

### Product 1: Monthly Subscription

- **Product ID**: `journal_plus_monthly` (MUST match exactly)
- **Name**: Journal Plus (Monthly)
- **Description**: Access all premium features with a monthly subscription
- **Billing period**: 1 month
- **Base price**: $2.99 USD
- **Grace period**: 3 days (recommended)
- **Free trial**: Optional (e.g., 7 days free trial)

Click **Save** and then **Activate**

### Product 2: Annual Subscription

- **Product ID**: `journal_plus_annual` (MUST match exactly)
- **Name**: Journal Plus (Annual)
- **Description**: Access all premium features with an annual subscription. Save 30% compared to monthly!
- **Billing period**: 1 year
- **Base price**: $24.99 USD
- **Grace period**: 3 days (recommended)
- **Free trial**: Optional (e.g., 7 days free trial)

Click **Save** and then **Activate**

## Step 3: Test Your Subscriptions

### Add Test Users

1. Go to **Settings** → **License testing**
2. Add email addresses of testers (must be Gmail accounts)
3. Set **License Test Response** to "RESPOND_NORMALLY" for real purchase testing
   - Or use "LICENSED" for immediate access without payment

### Testing Process

1. Download the APK from GitHub Actions artifacts
2. Install on your Android device: `adb install app-release.apk`
3. Open the app and navigate to the Premium screen
4. Tap on a subscription plan
5. Complete the purchase flow with your test account
6. Verify:
   - Purchase completes successfully
   - Premium status is unlocked
   - History screen shows unlimited entries
   - "Restore" button works for existing subscriptions

### Important Testing Notes

- Test purchases using test accounts are FREE (no real charges)
- Test purchases will show as "Test" in the purchase dialog
- Use the "Restore" button to verify subscription restoration works
- Test cancellation and renewal scenarios

## Step 4: Verify Premium Features

After purchasing, verify these features work:

✅ Unlimited history access (no 30-day limit)
✅ "Upgrade" banners disappear
✅ "Premium" badge appears (if you add one)
✅ Restore purchases works correctly

## Step 5: Production Release

Once testing is complete:

1. Move app from Internal Testing to Production
2. Subscriptions automatically work in production
3. Real users will be charged the actual prices
4. Monitor subscriptions in **Monetize** → **Subscription reports**

## Troubleshooting

### "Product not found" error

- Ensure product IDs match exactly: `journal_plus_monthly` and `journal_plus_annual`
- Wait 2-4 hours after creating products (Google Play can be slow to propagate)
- Ensure products are ACTIVATED (not just saved)
- App must be published to at least Internal Testing track

### Purchases not completing

- Check that billing permission is in AndroidManifest.xml
- Verify `in_app_purchase` package is installed
- Check device logs for errors: `adb logcat | grep -i purchase`

### "App not eligible for billing" error

- App must be published (not just uploaded)
- Billing setup must be complete in Google Play Console
- Developer account must be in good standing

## Revenue Share

Google takes a 15% commission on subscription revenue (up to $1M per year), then 30% after that.

For $24.99/year annual subscription:
- You receive: ~$21.24/year (after 15% commission)
- Google keeps: ~$3.75/year

## Pricing Strategy

Current pricing:
- Monthly: $2.99/month = $35.88/year
- Annual: $24.99/year (30% savings)

This is competitive with similar journaling apps:
- Day One: $34.99/year
- Five Minute Journal: $49.99/year

## Next Steps

After billing is working:
1. Add cloud sync (Firebase integration)
2. Implement advanced analytics
3. Add PDF export functionality
4. Enable multiple photos per entry
5. Build custom themes
6. Add passcode lock

## Useful Links

- [Google Play Billing Documentation](https://developer.android.com/google/play/billing)
- [Testing In-App Purchases](https://developer.android.com/google/play/billing/test)
- [Subscription Best Practices](https://developer.android.com/google/play/billing/subscriptions)
