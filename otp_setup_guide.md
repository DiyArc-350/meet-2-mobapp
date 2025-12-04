# How to Activate OTP in Supabase

To make the OTP (One-Time Password) feature work for both **Sign Up** and **Reset Password**, you need to configure your Supabase project correctly.

## 1. Enable Email Provider

1.  Go to your **Supabase Dashboard**.
2.  Navigate to **Authentication** -> **Providers**.
3.  Click on **Email**.
4.  Ensure **Enable Email provider** is toggled **ON**.
5.  Ensure **Confirm email** is toggled **ON**. This ensures that when a user signs up, they are sent a confirmation email (OTP).

## 2. Configure Email Templates

You can customize the emails that are sent to your users.

1.  Navigate to **Authentication** -> **Configuration** -> **Email Templates**.

### For Sign Up (Confirm Email)
-   Select **Confirm Your Email**.
-   Ensure the `{{ .Token }}` variable is present in the email body. This is the 6-digit OTP code.
-   Example Subject: `Confirm your signup`
-   Example Body:
    ```html
    <h2>Confirm your signup</h2>
    <p>Your confirmation code is: <strong>{{ .Token }}</strong></p>
    <p>Enter this code in the app to complete your registration.</p>
    ```

### For Reset Password
-   Select **Reset Password**.
-   Ensure the `{{ .Token }}` variable is present.
-   Example Subject: `Reset Password Request`
-   Example Body:
    ```html
    <h2>Reset Password</h2>
    <p>Your password reset code is: <strong>{{ .Token }}</strong></p>
    <p>Enter this code in the app to reset your password.</p>
    ```

## 3. Verify Code Implementation

Your code is already set up to handle this!

### Registration (`lib/register_page.dart`)
-   **Step 1**: `supabase.auth.signUp(email: ..., password: ...)` triggers the "Confirm Your Email" email.
-   **Step 2**: The user enters the code.
-   **Step 3**: `supabase.auth.verifyOTP(email: ..., token: ..., type: OtpType.signup)` verifies the code and activates the user.

### Reset Password (`lib/reset_password.dart`)
-   **Step 1**: `supabase.auth.resetPasswordForEmail(email)` triggers the "Reset Password" email.
-   **Step 2**: The user enters the code.
-   **Step 3**: `supabase.auth.verifyOTP(email: ..., token: ..., type: OtpType.recovery)` verifies the code and logs the user in.
-   **Step 4**: `supabase.auth.updateUser(UserAttributes(password: ...))` sets the new password.

## 4. Testing
1.  **Register**: Try registering a new email. Check your inbox (and spam folder) for the code.
2.  **Reset Password**: Go to the Reset Password page, enter your email. Check your inbox for the code.
