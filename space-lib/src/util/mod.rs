use rand::distributions::{Alphanumeric, DistString};
use serde_json::json;

use crate::communication;

pub mod hasher;
pub mod crypto;

pub fn random_string(length: usize) -> String {
    return Alphanumeric.sample_string(&mut rand::thread_rng(), length);
}

pub fn print_log(message: &str) {
    println!("l:{}", message);
}

pub fn print_action(action: communication::Event) {
    println!("a:{}", json!(action));
}