use aes_gcm::{
    aead::{Aead, OsRng},
    AeadCore, Aes256Gcm, KeyInit, Nonce,
};
use alkali::{
    mem::FullAccess,
    symmetric::cipher::{self},
    AlkaliError,
};
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

// Encrypt using sodium
pub fn encrypt_sodium(
    key: &cipher::Key<FullAccess>,
    plaintext: &[u8],
) -> Result<Vec<u8>, AlkaliError> {
    let mut encrypted = vec![0u8; plaintext.len() + cipher::MAC_LENGTH];
    let nonce = cipher::generate_nonce().expect("nonce couldn't be generated");
    let error: Option<AlkaliError> =
        match cipher::encrypt(plaintext, key, Some(&nonce), &mut encrypted) {
            Ok(_) => None,
            Err(e) => Some(e),
        };
    if error.is_some() {
        return Err(error.unwrap());
    }

    let mut output = nonce.to_vec();
    output.extend_from_slice(encrypted.as_slice());
    Ok(output)
}

// Decrypt using sodium
pub fn decrypt_sodium(
    key: &cipher::Key<FullAccess>,
    ciphertext: &[u8],
) -> Result<Vec<u8>, AlkaliError> {
    let mut output = vec![0u8; ciphertext.len() - cipher::NONCE_LENGTH - cipher::MAC_LENGTH];
    let nonce = &ciphertext[0..cipher::NONCE_LENGTH];
    let ciphertext = &ciphertext[cipher::NONCE_LENGTH..];
    let mut nonce_array = [0u8; cipher::NONCE_LENGTH];
    nonce_array.copy_from_slice(nonce);
    let error = match cipher::decrypt(ciphertext, key, &nonce_array, &mut output) {
        Ok(_) => None,
        Err(e) => Some(e),
    };

    if error.is_some() {
        return Err(error.unwrap());
    }
    Ok(output)
}

pub fn parse_key(key: String) -> Vec<u8> {
    general_purpose::STANDARD
        .decode(key)
        .expect("Couldn't parse key")
}

pub fn parse_sodium_key(to_parse: String) -> cipher::Key<FullAccess> {
    let mut key = cipher::Key::<FullAccess>::new_empty().unwrap();
    let bytes = general_purpose::STANDARD
        .decode(to_parse.as_bytes())
        .unwrap();
    key.copy_from_slice(&bytes);
    key
}
