# FinAI Mobile App - Test Cases

**Version**: 1.0  
**Date**: August 25, 2026  
**Application**: FinAI Mobile App (Parent-Child Finance Management)

---

## Table of Contents

1. [Authentication Tests](#authentication-tests)
2. [Parent Dashboard Tests](#parent-dashboard-tests)
3. [Child Management Tests](#child-management-tests)
4. [Child Dashboard Tests](#child-dashboard-tests)
5. [Navigation Tests](#navigation-tests)
6. [Error Handling Tests](#error-handling-tests)
7. [Performance Tests](#performance-tests)
8. [Security Tests](#security-tests)

---

## Authentication Tests

### TC-AUTH-001: Valid Parent Login

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-AUTH-001 |
| **Test Name** | Valid Parent Login |
| **Test Type** | Functional |
| **Priority** | Critical |
| **Precondition** | App launched, on login screen |

**Test Steps**:
1. Enter valid parent email
2. Enter valid parent password
3. Tap "Sign in" button
4. Wait for authentication

**Expected Result**:
- ✅ Login successful
- ✅ User redirected to parent dashboard
- ✅ Dashboard loads with parent financial data
- ✅ "My Children's Savings" section visible
- ✅ Auth token saved securely

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Notes**: 

---

### TC-AUTH-002: Valid Child Login

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-AUTH-002 |
| **Test Name** | Valid Child Login |
| **Test Type** | Functional |
| **Priority** | Critical |
| **Precondition** | App launched, on child login screen |

**Test Steps**:
1. Select "Child" on user type selection
2. Enter valid child email
3. Enter valid child password
4. Tap "Sign in" button

**Expected Result**:
- ✅ Login successful
- ✅ User redirected to child dashboard (not parent dashboard)
- ✅ Child's financial data loads
- ✅ Child sees savings goals and progress
- ✅ Auth token saved securely

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Notes**: 

---

### TC-AUTH-003: Invalid Email Format

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-AUTH-003 |
| **Test Name** | Invalid Email Format |
| **Test Type** | Validation |
| **Priority** | High |
| **Precondition** | App on login screen |

**Test Steps**:
1. Enter invalid email (e.g., "notanemail")
2. Tap "Sign in" button

**Expected Result**:
- ✅ Form validation triggered
- ✅ Error message: "Please enter a valid email"
- ✅ Sign in button not triggered
- ✅ User remains on login screen

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Notes**: 

---

### TC-AUTH-004: Empty Email Field

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-AUTH-004 |
| **Test Name** | Empty Email Field |
| **Test Type** | Validation |
| **Priority** | High |
| **Precondition** | App on login screen |

**Test Steps**:
1. Leave email field empty
2. Enter valid password
3. Tap "Sign in" button

**Expected Result**:
- ✅ Form validation triggered
- ✅ Error message: "Email is required"
- ✅ Sign in button not triggered
- ✅ User remains on login screen

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Notes**: 

---

### TC-AUTH-005: Empty Password Field

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-AUTH-005 |
| **Test Name** | Empty Password Field |
| **Test Type** | Validation |
| **Priority** | High |
| **Precondition** | App on login screen |

**Test Steps**:
1. Enter valid email
2. Leave password field empty
3. Tap "Sign in" button

**Expected Result**:
- ✅ Form validation triggered
- ✅ Error message: "Password is required"
- ✅ Sign in button not triggered
- ✅ User remains on login screen

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Notes**: 

---

### TC-AUTH-006: Wrong Password

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-AUTH-006 |
| **Test Name** | Wrong Password |
| **Test Type** | Functional |
| **Priority** | High |
| **Precondition** | App on login screen with valid account existing |

**Test Steps**:
1. Enter valid email
2. Enter wrong password
3. Tap "Sign in" button
4. Wait for server response

**Expected Result**:
- ✅ Login fails
- ✅ Error message: "Invalid email or password"
- ✅ User remains on login screen
- ✅ Can retry login

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Notes**: 

---

### TC-AUTH-007: Non-existent Email

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-AUTH-007 |
| **Test Name** | Non-existent Email |
| **Test Type** | Functional |
| **Priority** | High |
| **Precondition** | App on login screen |

**Test Steps**:
1. Enter non-existent email
2. Enter any password
3. Tap "Sign in" button
4. Wait for server response

**Expected Result**:
- ✅ Login fails
- ✅ Error message: "User not found" or "Invalid email or password"
- ✅ User remains on login screen
- ✅ Can retry login

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Notes**: 

---

### TC-AUTH-008: Password Visibility Toggle

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-AUTH-008 |
| **Test Name** | Password Visibility Toggle |
| **Test Type** | Functional |
| **Priority** | Medium |
| **Precondition** | App on login screen |

**Test Steps**:
1. Enter password in password field
2. Password should be masked (dots/asterisks)
3. Tap eye icon to show password
4. Password should now be visible
5. Tap eye icon again to hide password

**Expected Result**:
- ✅ Password masked by default
- ✅ Eye icon visible
- ✅ Password visible after tapping eye icon
- ✅ Password hidden after tapping eye icon again
- ✅ Actual password text unchanged

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Notes**: 

---

## Parent Dashboard Tests

### TC-DASHBOARD-001: Parent Dashboard Load

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-DASHBOARD-001 |
| **Test Name** | Parent Dashboard Load |
| **Test Type** | Functional |
| **Priority** | Critical |
| **Precondition** | Parent logged in successfully |

**Test Steps**:
1. Wait for dashboard to load
2. Verify all sections present
3. Check data displayed correctly

**Expected Result**:
- ✅ Dashboard loads within 2 seconds
- ✅ Financial Health Score visible
- ✅ Key metrics (Income, Expense, Savings, Debt) displayed
- ✅ Budget Progress section visible
- ✅ Savings Goals section visible
- ✅ AI Recommendations visible
- ✅ "My Children's Savings" section visible (green card)

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Notes**: 

---

### TC-DASHBOARD-002: Financial Health Score Display

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-DASHBOARD-002 |
| **Test Name** | Financial Health Score Display |
| **Test Type** | Functional |
| **Priority** | High |
| **Precondition** | Parent dashboard loaded |

**Test Steps**:
1. Observe Financial Health Score section
2. Verify score out of 100
3. Verify score color coding (green/yellow/red)
4. Verify risk level badge

**Expected Result**:
- ✅ Score displayed as number /100
- ✅ Score color matches health (green=good, yellow=medium, red=poor)
- ✅ Risk level badge shown (Low Risk, Medium Risk, High Risk)
- ✅ Progress bar corresponds to score
- ✅ Top risk driver displayed

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Notes**: 

---

### TC-DASHBOARD-003: My Children's Savings Section

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-DASHBOARD-003 |
| **Test Name** | My Children's Savings Section |
| **Test Type** | Functional |
| **Priority** | Critical |
| **Precondition** | Parent dashboard loaded, parent has children |

**Test Steps**:
1. Scroll to find "My Children's Savings" section
2. Verify section styling (green card)
3. Verify section title and description
4. Verify "View Children Dashboard" button visible
5. Tap "View Children Dashboard" button

**Expected Result**:
- ✅ Section visible with green styling
- ✅ Title: "My Children's Savings"
- ✅ Description text present
- ✅ "View All" button visible
- ✅ "View Children Dashboard" button with icon present
- ✅ Button is clickable and navigates to child selector

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Notes**: 

---

### TC-DASHBOARD-004: Bottom Navigation

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-DASHBOARD-004 |
| **Test Name** | Bottom Navigation |
| **Test Type** | Functional |
| **Priority** | Medium |
| **Precondition** | Parent dashboard loaded |

**Test Steps**:
1. Observe bottom navigation bar
2. Check current tab is highlighted (Dashboard)
3. Tap other navigation items
4. Verify navigation works

**Expected Result**:
- ✅ Bottom navigation visible
- ✅ Current tab (Dashboard) highlighted
- ✅ Other tabs accessible
- ✅ Tapping tabs navigates to correct screens
- ✅ State preserved when navigating back

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Notes**: 

---

## Child Management Tests

### TC-CHILD-001: View Children List

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-CHILD-001 |
| **Test Name** | View Children List |
| **Test Type** | Functional |
| **Priority** | Critical |
| **Precondition** | Parent logged in, on dashboard |

**Test Steps**:
1. Tap "View Children Dashboard" button
2. Wait for child selector to load
3. Observe list of children

**Expected Result**:
- ✅ Child Profile Selector screen loads
- ✅ List of all parent's children displayed
- ✅ Each child shows: name, age, profile picture, savings total
- ✅ "Switch" button visible for each child
- ✅ No loading errors

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Notes**: 

---

### TC-CHILD-002: Switch Between Children

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-CHILD-002 |
| **Test Name** | Switch Between Children |
| **Test Type** | Functional |
| **Priority** | Critical |
| **Precondition** | Parent on child selector, multiple children exist |

**Test Steps**:
1. Tap "Switch" button on first child
2. Wait for child dashboard to load
3. Verify first child's data displayed
4. Go back to child selector
5. Tap "Switch" button on second child
6. Verify second child's data displayed

**Expected Result**:
- ✅ Dashboard updates with correct child data
- ✅ Child name matches selected child
- ✅ Child's savings goals displayed
- ✅ Switching between children works smoothly
- ✅ No data corruption between switches
- ✅ Correct child data for each selection

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Notes**: 

---

### TC-CHILD-003: Child Dashboard Load

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-CHILD-003 |
| **Test Name** | Child Dashboard Load |
| **Test Type** | Functional |
| **Priority** | Critical |
| **Precondition** | Parent selected a child |

**Test Steps**:
1. Observe child dashboard loading
2. Wait for API data to load
3. Verify all sections present

**Expected Result**:
- ✅ Dashboard loads within 2 seconds
- ✅ Child's name displayed
- ✅ Savings goals section visible
- ✅ Financial information displayed
- ✅ Total savings amount shown
- ✅ Progress bars for savings goals visible

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Notes**: 

---

### TC-CHILD-004: Pull-to-Refresh Child Data

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-CHILD-004 |
| **Test Name** | Pull-to-Refresh Child Data |
| **Test Type** | Functional |
| **Priority** | High |
| **Precondition** | Child dashboard loaded |

**Test Steps**:
1. Swipe down on dashboard
2. Observe refresh indicator
3. Wait for data to refresh
4. Verify updated data

**Expected Result**:
- ✅ Pull-to-refresh trigger detects gesture
- ✅ Loading spinner appears
- ✅ API request sent to fetch latest data
- ✅ Data refreshes within 1-2 seconds
- ✅ Loading indicator disappears
- ✅ Child data updates if changed

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Notes**: 

---

## Child Dashboard Tests

### TC-CHILDDASH-001: Savings Goals Display

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-CHILDDASH-001 |
| **Test Name** | Savings Goals Display |
| **Test Type** | Functional |
| **Priority** | High |
| **Precondition** | Child dashboard loaded with savings goals |

**Test Steps**:
1. Observe savings goals section
2. Verify each goal shows:
   - Goal title
   - Target amount
   - Current amount
   - Progress bar
   - Percentage saved
3. Verify goal icons match category

**Expected Result**:
- ✅ All goals displayed with correct data
- ✅ Progress bars accurately reflect savings percentage
- ✅ Category icons appropriate (e.g., game icon for gaming)
- ✅ Amounts formatted correctly (currency symbol, decimals)
- ✅ No errors in data display

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Notes**: 

---

### TC-CHILDDASH-002: Financial Alerts

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-CHILDDASH-002 |
| **Test Name** | Financial Alerts |
| **Test Type** | Functional |
| **Priority** | Medium |
| **Precondition** | Child dashboard loaded with alerts |

**Test Steps**:
1. Observe alerts section
2. Verify alert messages display
3. Verify alert icons/colors

**Expected Result**:
- ✅ Alerts displayed if present
- ✅ Alert titles and descriptions clear
- ✅ Alert severity indicated (warning/info/success)
- ✅ Alerts properly formatted
- ✅ No missing alert data

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Notes**: 

---

### TC-CHILDDASH-003: Total Savings Amount

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-CHILDDASH-003 |
| **Test Name** | Total Savings Amount |
| **Test Type** | Functional |
| **Priority** | High |
| **Precondition** | Child dashboard loaded |

**Test Steps**:
1. Observe total savings amount displayed
2. Verify amount is formatted correctly
3. Verify calculation matches sum of all goals

**Expected Result**:
- ✅ Total savings clearly displayed
- ✅ Amount formatted with currency symbol
- ✅ Amount matches sum of individual goal amounts
- ✅ Updates when goals are modified
- ✅ Displayed prominently on dashboard

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Notes**: 

---

## Navigation Tests

### TC-NAV-001: Intro to User Type Selection

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-NAV-001 |
| **Test Name** | Intro to User Type Selection |
| **Test Type** | Navigation |
| **Priority** | High |
| **Precondition** | App launched at intro screen |

**Test Steps**:
1. Tap "Get Started" button
2. Observe navigation

**Expected Result**:
- ✅ Navigates to User Type Selection screen
- ✅ "Parent" and "Child" buttons visible
- ✅ Screen fully loads without errors

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Notes**: 

---

### TC-NAV-002: Parent Flow Navigation

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-NAV-002 |
| **Test Name** | Parent Flow Navigation |
| **Test Type** | Navigation |
| **Priority** | Critical |
| **Precondition** | On user type selection screen |

**Test Steps**:
1. Tap "Parent" button
2. Verify navigates to parent login
3. Login as parent
4. Verify navigates to parent dashboard
5. Tap "View Children Dashboard"
6. Verify navigates to child selector

**Expected Result**:
- ✅ All navigation steps succeed
- ✅ No navigation errors
- ✅ Correct screens load in sequence
- ✅ Back buttons work at each step
- ✅ Route transitions smooth

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Notes**: 

---

### TC-NAV-003: Child Flow Navigation

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-NAV-003 |
| **Test Name** | Child Flow Navigation |
| **Test Type** | Navigation |
| **Priority** | Critical |
| **Precondition** | On user type selection screen |

**Test Steps**:
1. Tap "Child" button
2. Verify navigates to child login
3. Login as child
4. Verify navigates directly to child dashboard

**Expected Result**:
- ✅ Navigation to child login succeeds
- ✅ Navigation to child dashboard succeeds
- ✅ Parent dashboard NOT shown
- ✅ Child sees their own data
- ✅ No navigation errors

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Notes**: 

---

### TC-NAV-004: Back Button Navigation

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-NAV-004 |
| **Test Name** | Back Button Navigation |
| **Test Type** | Navigation |
| **Priority** | High |
| **Precondition** | On login screen |

**Test Steps**:
1. Tap back button
2. Verify returns to user type selection
3. Tap back button again
4. Verify returns to intro screen

**Expected Result**:
- ✅ Back button navigates to previous screen
- ✅ Maintains history correctly
- ✅ No data loss on back navigation
- ✅ Screen state preserved

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Notes**: 

---

## Error Handling Tests

### TC-ERROR-001: Network Offline - Login

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-ERROR-001 |
| **Test Name** | Network Offline - Login |
| **Test Type** | Error Handling |
| **Priority** | High |
| **Precondition** | App on login screen, device offline |

**Test Steps**:
1. Enable airplane mode on device
2. Try to login
3. Wait for error handling

**Expected Result**:
- ✅ Error message displayed: "No internet connection"
- ✅ Clear explanation provided
- ✅ Retry button visible
- ✅ User can enable connection and retry
- ✅ Login succeeds after connection restored

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Notes**: 

---

### TC-ERROR-002: Network Timeout

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-ERROR-002 |
| **Test Name** | Network Timeout |
| **Test Type** | Error Handling |
| **Priority** | High |
| **Precondition** | App attempting API call, slow/unstable network |

**Test Steps**:
1. Simulate slow network
2. Attempt API call (login or dashboard load)
3. Wait for timeout

**Expected Result**:
- ✅ Timeout detected (after 10 seconds)
- ✅ Error message: "Request timed out"
- ✅ Retry button visible
- ✅ User can retry immediately
- ✅ Success on retry with good connection

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Notes**: 

---

### TC-ERROR-003: Server Error 500

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-ERROR-003 |
| **Test Name** | Server Error 500 |
| **Test Type** | Error Handling |
| **Priority** | High |
| **Precondition** | Server returns 500 error |

**Test Steps**:
1. Trigger API call while server returns 500
2. Observe error handling

**Expected Result**:
- ✅ Error message: "Server error occurred"
- ✅ User-friendly message (not technical error)
- ✅ Retry button visible
- ✅ User can retry later
- ✅ No app crash

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Notes**: 

---

### TC-ERROR-004: Invalid Token

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-ERROR-004 |
| **Test Name** | Invalid/Expired Token |
| **Test Type** | Error Handling |
| **Priority** | High |
| **Precondition** | Token expired or invalid |

**Test Steps**:
1. Wait for token to expire or manually invalidate
2. Attempt API call
3. Observe error handling

**Expected Result**:
- ✅ Unauthorized error detected
- ✅ User redirected to login screen
- ✅ Clear message: "Session expired, please login again"
- ✅ User can login again
- ✅ App doesn't crash

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Notes**: 

---

### TC-ERROR-005: Empty API Response

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-ERROR-005 |
| **Test Name** | Empty/Invalid API Response |
| **Test Type** | Error Handling |
| **Priority** | Medium |
| **Precondition** | API returns empty or malformed response |

**Test Steps**:
1. Simulate empty API response
2. Attempt data display

**Expected Result**:
- ✅ Graceful handling of empty data
- ✅ No crashes
- ✅ Empty state message displayed if appropriate
- ✅ Retry option available
- ✅ User can recover

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Notes**: 

---

## Performance Tests

### TC-PERF-001: Login Response Time

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-PERF-001 |
| **Test Name** | Login Response Time |
| **Test Type** | Performance |
| **Priority** | Medium |
| **Precondition** | App on login screen, good network connection |

**Test Steps**:
1. Note current time
2. Enter credentials and tap login
3. Note time when dashboard appears

**Expected Result**:
- ✅ Login completes within 5 seconds
- ✅ Dashboard appears within 2-3 seconds after authentication
- ✅ Loading indicator displays during wait
- ✅ No app freezing

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Actual Time**: _____ seconds

**Notes**: 

---

### TC-PERF-002: Dashboard Load Time

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-PERF-002 |
| **Test Name** | Dashboard Load Time |
| **Test Type** | Performance |
| **Priority** | Medium |
| **Precondition** | App navigating to dashboard, good network |

**Test Steps**:
1. Note current time when navigating
2. Wait for dashboard to fully load
3. Note time when all data visible

**Expected Result**:
- ✅ Dashboard loads within 2 seconds
- ✅ Data visible without blank sections
- ✅ Smooth scrolling
- ✅ No stuttering

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Actual Time**: _____ seconds

**Notes**: 

---

### TC-PERF-003: Child Dashboard Load Time

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-PERF-003 |
| **Test Name** | Child Dashboard Load Time |
| **Test Type** | Performance |
| **Priority** | Medium |
| **Precondition** | Parent selecting child, good network |

**Test Steps**:
1. Note time when child selected
2. Wait for child dashboard to load
3. Note time when all data visible

**Expected Result**:
- ✅ Child dashboard loads within 2 seconds
- ✅ Savings goals visible
- ✅ Financial data visible
- ✅ Smooth transitions

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Actual Time**: _____ seconds

**Notes**: 

---

### TC-PERF-004: Memory Usage

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-PERF-004 |
| **Test Name** | Memory Usage |
| **Test Type** | Performance |
| **Priority** | Low |
| **Precondition** | App running for extended period |

**Test Steps**:
1. Check device memory before app launch
2. Launch app
3. Navigate through multiple screens
4. Check memory after 10 minutes
5. Check for memory leaks by navigating repeatedly

**Expected Result**:
- ✅ Memory usage reasonable
- ✅ No constant memory increase
- ✅ Memory released after screen navigation
- ✅ No excessive memory consumption
- ✅ App remains responsive

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Initial Memory**: _____ MB
**Final Memory**: _____ MB
**Change**: _____ MB

**Notes**: 

---

## Security Tests

### TC-SEC-001: Token Secure Storage

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-SEC-001 |
| **Test Name** | Token Secure Storage |
| **Test Type** | Security |
| **Priority** | Critical |
| **Precondition** | App logged in |

**Test Steps**:
1. Login successfully
2. Check token storage location (Android Keystore)
3. Verify token is encrypted
4. Attempt to access token directly

**Expected Result**:
- ✅ Token stored in secure storage (not plain text)
- ✅ Token cannot be read directly from shared preferences
- ✅ Token encrypted using platform security (Keystore)
- ✅ Token not visible in app files

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Notes**: 

---

### TC-SEC-002: Password Not Stored

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-SEC-002 |
| **Test Name** | Password Not Stored |
| **Test Type** | Security |
| **Priority** | Critical |
| **Precondition** | App logged in |

**Test Steps**:
1. Login with password
2. Check app's local storage
3. Search for stored password

**Expected Result**:
- ✅ Password never stored locally
- ✅ Only token stored
- ✅ Password only sent to server over HTTPS
- ✅ No password in logs

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Notes**: 

---

### TC-SEC-003: HTTPS Connection

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-SEC-003 |
| **Test Name** | HTTPS Connection |
| **Test Type** | Security |
| **Priority** | Critical |
| **Precondition** | App making API calls |

**Test Steps**:
1. Monitor network traffic using proxy/Charles
2. Check API endpoints
3. Verify connection protocol

**Expected Result**:
- ✅ All API calls use HTTPS
- ✅ No HTTP connections to sensitive endpoints
- ✅ Certificate validation enabled
- ✅ No mixed HTTP/HTTPS content

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Notes**: 

---

### TC-SEC-004: Auth Token Expiration

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-SEC-004 |
| **Test Name** | Auth Token Expiration |
| **Test Type** | Security |
| **Priority** | High |
| **Precondition** | App logged in |

**Test Steps**:
1. Login successfully
2. Wait for token to expire (or manually expire)
3. Attempt API call
4. Observe handling

**Expected Result**:
- ✅ Expired token detected
- ✅ User redirected to login
- ✅ Error message displayed
- ✅ Refresh token used if available
- ✅ User must login again if refresh fails

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Notes**: 

---

### TC-SEC-005: Certificate Pinning

| Attribute | Value |
|-----------|-------|
| **Test ID** | TC-SEC-005 |
| **Test Name** | Certificate Pinning |
| **Test Type** | Security |
| **Priority** | Medium |
| **Precondition** | App making API calls |

**Test Steps**:
1. Attempt Man-in-the-Middle attack with proxy certificate
2. Observe connection handling

**Expected Result**:
- ✅ Connection rejected with proxy certificate
- ✅ Certificate validation error shown
- ✅ App refuses to continue
- ✅ Only valid certificate accepted

**Actual Result**: 
- [ ] Pass
- [ ] Fail

**Notes**: 

---

## Test Summary

### Test Execution Report

| Category | Total | Pass | Fail | N/A |
|----------|-------|------|------|-----|
| Authentication | 8 | | | |
| Parent Dashboard | 4 | | | |
| Child Management | 4 | | | |
| Child Dashboard | 3 | | | |
| Navigation | 4 | | | |
| Error Handling | 5 | | | |
| Performance | 4 | | | |
| Security | 5 | | | |
| **TOTAL** | **37** | | | |

---

## Test Environment

| Item | Value |
|------|-------|
| **Device** | |
| **OS Version** | |
| **App Version** | 1.0 |
| **Build Date** | |
| **Tester** | |
| **Date** | |
| **Network** | Good / Moderate / Poor |
| **Backend URL** | http://140.238.242.80/api |

---

## Defects Found

| ID | Title | Severity | Steps to Reproduce | Expected | Actual | Status |
|----|-------|----------|-------------------|----------|--------|--------|
| | | | | | | |
| | | | | | | |

---

## Sign-Off

| Role | Name | Date | Signature |
|------|------|------|-----------|
| QA Lead | | | |
| Dev Lead | | | |
| PM | | | |

---

*Test Cases Document - FinAI Mobile App*  
*Version 1.0 - August 25, 2026*
