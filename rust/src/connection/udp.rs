use std::collections::HashMap;
use std::sync::mpsc::{Receiver, Sender};
use std::sync::{mpsc, Arc, Mutex};

use std::net::UdpSocket;
use std::time::Duration;
use std::{io, thread};

use once_cell::sync::Lazy;
use rand::Rng;

use crate::audio::decode;
use crate::{audio, communication, logger};
use crate::{connection, util};

static SEND_SENDER: Lazy<Mutex<Sender<Vec<u8>>>> = Lazy::new(|| {
    let (sender, _) = mpsc::channel();
    Mutex::new(sender)
});

static SEND_RECEIVER: Lazy<Mutex<Receiver<Vec<u8>>>> = Lazy::new(|| {
    let (_, receiver) = mpsc::channel();
    Mutex::new(receiver)
});

pub fn send(data: Vec<u8>) {
    SEND_SENDER
        .lock()
        .expect("channel broken")
        .send(data)
        .expect("sending broken");
}

pub fn init() {
    // Sending channel
    let (sender, receiver) = mpsc::channel();
    let mut actual_sender = match SEND_SENDER.try_lock() {
        Ok(sender) => sender,
        Err(_) => {
            logger::send_log(
                logger::TAG_CONNECTION,
                "Failed to acquire lock on SEND_SENDER",
            );
            return;
        }
    };
    *actual_sender = sender;
    let mut actual_receiver = match SEND_RECEIVER.try_lock() {
        Ok(receiver) => receiver,
        Err(_) => {
            logger::send_log(
                logger::TAG_CONNECTION,
                "Failed to acquire lock on SEND_RECEIVER",
            );
            return;
        }
    };
    *actual_receiver = receiver;

    drop(actual_sender);
    drop(actual_receiver);
}

// So you can test locally without having to worry about a key exchange
static TEST_KEY: &str = "6HDUlw4Gyeu8pVpSD54YHW6gJ7fJilD5MR63MNiFdJI=";

pub fn connect_read(address: &str) {
    let mut input = String::new();
    io::stdin()
        .read_line(&mut input)
        .expect("Failed to read line");
    input = input.trim().to_string();
    let mut args = input.split(":");
    if args.clone().count() == 2 {
        connect_recursive(
            args.nth(0).unwrap().to_string(),
            args.nth(0).unwrap().to_string(),
            TEST_KEY.to_string(),
            address,
            0,
            true,
        );
        return;
    }
    connect_recursive(
        args.nth(0).unwrap().to_string(),
        args.nth(0).unwrap().to_string(),
        args.nth(0).unwrap().to_string(),
        address,
        0,
        true,
    )
}

pub fn connect_recursive(
    client_id: String,
    verification_key: String,
    encryption_key: String,
    address: &str,
    tries: u8,
    listen: bool,
) {
    if tries > 5 {
        logger::send_log(logger::TAG_CONNECTION, "Could not connect");
        return;
    }

    // Bind to a local address
    let socket = match UdpSocket::bind(format!(
        "0.0.0.0:{}",
        rand::thread_rng().gen_range(3000..4000)
    )) {
        Ok(s) => s,
        Err(_) => {
            logger::send_log(logger::TAG_CONNECTION, "Could not bind socket");
            return;
        }
    };

    // Connect to a remote address
    match socket.connect(address) {
        Ok(_) => {}
        Err(_) => {
            logger::send_log(
                logger::TAG_CONNECTION,
                "Could not connect to remote address",
            );
            return;
        }
    }
    // Set config
    let config = Arc::new(connection::Config {
        test: false,
        client_id: client_id,
        verification_key: util::crypto::parse_key(verification_key),
        encryption_key: util::crypto::parse_sodium_key(encryption_key),
        connection: true,
    });

    // Start threads
    send_thread(socket.try_clone().expect("Could not clone socket"));
    audio::microphone::record(config.clone());
    audio::decode::decode_play_thread(config.clone());
    let init_packet = super::init_packet(&config);
    send(init_packet);

    // Listen for udp traffic
    thread::spawn(move || {
        let mut buf: [u8; 8192] = [0u8; 8192];
        loop {
            let size = socket.recv(&mut buf).expect("Detected disconnect");
            let _channel_map = HashMap::<String, String>::new();

            decode::send_packet(buf[0..size].to_vec());
        }
    });

    if listen {
        communication::start_listening();
    }
}

// Starts a thread that sends data from the sender channel
fn send_thread(socket: UdpSocket) {
    thread::spawn(move || loop {
        if connection::should_stop() {
            break;
        }

        let data_result = match SEND_RECEIVER.lock() {
            Ok(receiver) => receiver,
            Err(receiver) => receiver.into_inner(),
        }
        .recv_timeout(Duration::from_secs(1));
        if data_result.is_err() {
            continue;
        }

        match socket.send(&data_result.unwrap()) {
            Ok(_) => {}
            Err(_) => {
                logger::send_log(logger::TAG_CONNECTION, "Could not send");
                return;
            }
        }
    });
}
