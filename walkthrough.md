# Role-Based Access Control (RBAC) Implementation

I have implemented the requested levelling system (Level 1, 2, 3) for the Storage and Students tabs.

## Changes Made

### 1. User Session Management
- Created `lib/user_session.dart` to store the current user's level.
- Updated `lib/login.dart` to fetch the user's level from the `users` table in Supabase upon successful login (and biometric auth).

### 2. Storage Tab (`lib/storage_list.dart`)
- **Level 1**: Can only Download. (Upload, Rename, Delete are hidden)
- **Level 2**: Can Download, Rename, and Upload. (Delete is hidden)
- **Level 3**: Can Download, Rename, Upload, and Delete.

### 3. Students Tab (`lib/home_screen.dart`)
- **Level 1**: Can only View data. (Add, Edit, Delete are hidden)
- **Level 2**: Can View, Add, and Edit data. (Delete is hidden)
- **Level 3**: Can do all CRUD operations (View, Add, Edit, Delete).

### 4. Supabase Setup
- Created `supabase_setup.sql` in the project root.
- This file contains the SQL commands to:
    - Create the `users` table with a `level` column.
    - Set up Row Level Security (RLS).
    - Create a trigger to automatically add a `users` entry with `level = 1` when a new user signs up.

## How to Use

1.  **Run the SQL**: Open your Supabase Dashboard, go to the SQL Editor, and copy-paste the contents of `supabase_setup.sql`. Run it.
2.  **Set User Levels**: By default, new users are **Level 1**. To change a user's level, go to the Table Editor in Supabase, open the `users` table, and change the `level` column (1, 2, or 3).
3.  **Test**: Log out and log back in to see the changes take effect.

## Files Modified
- `lib/user_session.dart` (New)
- `lib/login.dart`
- `lib/storage_list.dart`
- `lib/home_screen.dart`
- `supabase_setup.sql` (New)
