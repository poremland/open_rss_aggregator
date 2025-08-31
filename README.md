# Open Rss Aggregator

> Open Rss Aggregator is a Ruby on Rails API-first application designed for RSS feed aggregation. It provides a RESTful API for managing and accessing RSS feeds and their items. This project has been updated to leverage modern Ruby on Rails practices, including JWT-based authentication with One-Time Passwords (OTP) for secure access.

> The application is built to be self-contained and API-driven. Authentication is handled via JWT tokens issued after successful OTP verification, which are sent to the user's registered email address.

## Setup

### Prerequisites

*   **Ruby**: Version 3.4.4 (recommended to use [RVM](https://rvm.io/) or [rbenv](https://github.com/rbenv/rbenv))
*   **Bundler**: Gem manager for Ruby.
*   **Database**: MySQL (recommended) or SQLite3 (for development/testing).
*   **Mail Server**: An SMTP server for sending OTP emails.

### Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/poremland/open_rss_aggregator.git
    cd open_rss_aggregator
    ```

2.  **Install Ruby dependencies**:
    ```bash
    bundle install
    ```

3.  **Configure the application**:
    Copy the example configuration files:
    ```bash
    cp config/config.yml.example config/config.yml
    cp config/database.yml.example config/database.yml
    cp config/storage.yml.example config/storage.yml
    ```
    Edit `config/config.yml` and `config/database.yml` with your specific settings:
    *   **`config/config.yml`**:
        *   `mail_server`, `mail_server_port`, `mail_server_enable_tls`, `mail_domain`, `mail_user`, `mail_password`: Configure your SMTP server details for sending OTP emails.
    *   **`config/database.yml`**: Configure your database connection details (e.g., MySQL credentials).

4.  **Setup the database**:
    ```bash
    rake db:create db:migrate db:seed
    ```

## Running the Application

The application uses [Puma](https://puma.io/) as its web server.

To start the Puma server in production mode (recommended for deployment):

```bash
bundle exec puma -C config/puma.rb
```

Alternatively, you can use the provided worker script which also manages the Puma process:

```bash
./lib/scripts/open.rss.aggregator.worker.sh start
```

The application will typically run on port `8778` (configurable in `config/puma.rb`).

## Updating Server URL in Frontend Assets

This project has a React frontend assets (located in `public/_expo/static/js/web/`) and will need the JavaScript files to be updated to point to your API server URL. This can be done using the provided Python script: `lib/scripts/update_server_in_js_files.py`.

This script uses `sed` to perform a find-and-replace operation on all `.js` files within a specified directory.

**Usage:**

```bash
python3 lib/scripts/update_server_in_js_files.py public/_expo/static/js/web/ "s/https:\/\/YOUR.DOMAIN.COM/https:\/\/EXAMPLE.DOMAIN.COM/g"
```

**Explanation:**

*   `python3 lib/scripts/update_server_in_js_files.py`: Executes the Python script.
*   `public/_expo/static/js/web/`: This is the target directory where the JavaScript files to be updated are located.
*   `"s/https:\/\/YOUR.DOMAIN.COM/https:\/\/EXAMPLE.DOMAIN.COM/g"`: This is the `sed` expression.

**Important:**

*   Replace `https://EXAMPLE.DOMAIN.COM` with the correct URL of your backend server.


## Authentication

Open Rss Aggregator now uses a JWT (JSON Web Token) based authentication system with OTP (One-Time Password) verification.

1.  **Request OTP**: Send a request to `/api/request_otp` with your username (email address). The system will send an OTP to that email.
2.  **Login with OTP**: Send a request to `/api/login` with your username and the received OTP. If successful, the API will return a JWT token.
3.  **Access Protected Endpoints**: Include the JWT token in the `Authorization` header of your subsequent API requests (e.g., `Authorization: Bearer YOUR_JWT_TOKEN`).
4.  **Refresh Token**: You can refresh your JWT token by sending a request to `/api/refresh_token` with your current token.

## Scheduled Tasks

The `lib/scripts/open.rss.aggregator.worker.sh` bash script can be used for scheduled tasks like syncing feeds and purging old feed items. You will need to update the script to replace `/YOUR/PATH/TO/open-rss-aggregator` with the actual full path to your application directory.

### Syncing Feeds

This command syncs all RSS feeds for all users. It should be run periodically (e.g., every 30 minutes).

```bash
*/30 * * * * /YOUR/PATH/TO/open-rss-aggregator/lib/scripts/open.rss.aggregator.worker.sh sync
```

### Purging Old Feeds

This command purges old feed items from the database. It should be run less frequently (e.g., daily).

```bash
13 11 * * * /YOUR/PATH/TO/open-rss-aggregator/lib/scripts/open.rss.aggregator.worker.sh purge
```
