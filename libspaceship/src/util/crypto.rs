use aes_gcm::{Aes256Gcm, AeadCore, aead::{OsRng, Aead}, KeyInit, Nonce};
use alkali::{mem::FullAccess, symmetric::auth::Key};
use base64::{engine::general_purpose, Engine};

// Encrypts a byte array using AES-GCM encryption mode
pub fn encrypt(key: &[u8], plaintext: &[u8]) -> Vec<u8> {
    
    // Get cipher from key
    let aes_key = aes_gcm::Key::<Aes256Gcm>::from_slice(key);
    let cipher = Aes256Gcm::new(&aes_key);
    
    // Encrypt plaintext
    let nonce = Aes256Gcm::generate_nonce(&mut OsRng);
    let mut ciphertext = cipher.encrypt(&nonce, plaintext.as_ref()).unwrap();

    let mut vec = nonce.to_vec();
    vec.append(&mut ciphertext);

    return vec;
}

// Decrypts a byte array encrypted using AES-GCM encryption mode
pub fn decrypt(key: &[u8], ciphertext: &[u8]) -> Vec<u8> {
    
    // Get cipher from key
    let aes_key = aes_gcm::Key::<Aes256Gcm>::from_slice(key);
    let cipher = Aes256Gcm::new(&aes_key);
    
    // Decrypt ciphertext
    let nonce = Nonce::from_slice(&ciphertext[0..12]);
    let plaintext = cipher.decrypt(&nonce, ciphertext[12..].as_ref()).unwrap();

    return plaintext;
}

pub fn parse_key(key: String) -> Vec<u8> {
    general_purpose::STANDARD.decode(key).expect("Couldn't parse key")
}

pub fn parse_sodium_key(to_parse: String) -> Key<FullAccess> {
    let mut key = Key::<FullAccess>::new_empty().unwrap();
    let bytes = general_purpose::STANDARD.decode(to_parse.as_bytes()).unwrap();
    key.copy_from_slice(&bytes);
    key
}
