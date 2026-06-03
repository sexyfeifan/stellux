//! Authentication routes

use axum::{
    routing::{get, post},
    Router,
};

use crate::handlers::auth;
use crate::AppState;

/// Create authentication routes (public)
pub fn routes() -> Router<AppState> {
    Router::new()
        .route("/auth/login", post(auth::login))
        .route("/auth/refresh", post(auth::refresh_token))
        .route("/auth/check-admin", get(auth::check_admin_exists))
        .route("/auth/setup", post(auth::setup_admin))
}

/// Create admin authentication routes (requires auth)
pub fn admin_routes() -> Router<AppState> {
    Router::new()
        .route("/auth/change-password", post(auth::change_password))
}
