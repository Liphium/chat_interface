use serde::{Deserialize, Serialize};
use serde_json::Value;

use crate::{util::{self, crypto}, audio::decode::{AudioPacket, self}, logger};

#[derive(Deserialize, Serialize)]
struct Event {
    name: String,
    sender: String,
    data: Value
}

pub fn receive_packet(config: &super::Config, data: &Vec<u8>) -> Result<(), String> {

    // Split voice and sender data
    let (enc_sender_id, voice) = data.split_at(38);
    let sender_id = crypto::decrypt(&config.verification_key, enc_sender_id);

    let decrypted = util::crypto::decrypt_sodium(&config.encryption_key, voice);
    if decrypted.is_err() {
        logger::send_log(logger::TAG_CONNECTION, "error decrypting a packet, maybe just a UDP packet drop error?");
        return Ok(());
    }
    decode::send_packet(AudioPacket{
        data: decrypted.unwrap(),
        id: String::from_utf8(sender_id).unwrap(),
    });

    return Ok(())
}