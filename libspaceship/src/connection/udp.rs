use std::sync::mpsc::{Receiver, Sender};
use std::sync::{mpsc, Mutex, Arc};

use std::{io, thread};
use std::net::UdpSocket;

use once_cell::sync::Lazy;
use rand::Rng;

use crate::connection::receiver;
use crate::{communication, audio};
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
    SEND_SENDER.lock().expect("channel broken").send(data).expect("sending broken");
}

pub fn init() {
    // Sending channel
    let (sender, receiver) = mpsc::channel();
    let mut actual_sender = SEND_SENDER.lock().unwrap();
    *actual_sender = sender;
    let mut actual_receiver = SEND_RECEIVER.lock().unwrap();
    *actual_receiver = receiver;

    drop(actual_sender);
    drop(actual_receiver);
}

pub fn connect_read(address: &str) {
    let mut input = String::new();
    io::stdin().read_line(&mut input).expect("Failed to read line");
    input = input.trim().to_string();
    let mut args = input.split(":");
    connect_recursive(args.nth(0).unwrap().to_string(), args.nth(0).unwrap().to_string(), args.nth(0).unwrap().to_string(), address, 0, false)
}

pub fn connect_recursive(client_id: String, verification_key: String, encryption_key: String, address: &str, tries: u8, listen: bool) {

    if tries > 5 {
        util::print_log("Could not connect");
        return;
    }

    // Bind to a local address
    let socket = match UdpSocket::bind(format!("0.0.0.0:{}", rand::thread_rng().gen_range(3000..4000))) {
        Ok(s) => s,
        Err(_) => {
            util::print_log("Could not bind socket");
            return;
        }
    };

    // Connect to a remote address
    match socket.connect(address) {
        Ok(_) => {}
        Err(_) => {
            util::print_log("Could not connect to remote address");
            return; 
        }
    }
    // Set config
    let config = Arc::new(connection::Config {
        test: false,
        client_id: client_id,
        verification_key: util::crypto::parse_key(verification_key),
        encryption_key: util::crypto::parse_key(encryption_key),
        connection: true
    });

    // Start threads
    send_thread(socket.try_clone().expect("Could not clone socket"));
    audio::microphone::record(config.clone());
    //audio::decode::decode_play_thread();

    // Listen for udp traffic
    thread::spawn(move || {
        let mut buf: [u8; 8192] = [0u8; 8192];
        loop {
            let size = socket.recv(&mut buf).expect("Detected disconnect");

            match receiver::receive_packet(&config, &buf[0..size].to_vec()) {
                Ok(_) => (),
                Err(message) => util::print_log(format!("{}", message).as_str())
            }
        } 
    });

    if listen {
        communication::start_listening();
    }
}

// Starts a thread that sends data from the sender channel
fn send_thread(socket: UdpSocket) {

    thread::spawn(move || {
        loop {
            let data = SEND_RECEIVER.lock().expect("brokey").recv().expect("Packet sending channel broke");

            match socket.send(&data) {
                Ok(_) => {}
                Err(_) => {
                    util::print_log("Could not send"); 
                    return;
                }
            }
        }
    });
}