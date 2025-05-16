use libcgc::{
    container::auth_symmetric,
    crypto::{asymmetric, signature, symmetric},
};

use crate::binding;

// All keys used by libcgc
pub struct SymmetricKey {
    pub id: u32,
}
pub struct SigningKey {
    pub id: u32,
}
pub struct VerifyingKey {
    pub id: u32,
}
pub struct PublicKey {
    pub id: u32,
}
pub struct SecretKey {
    pub id: u32,
}

pub struct SignatureKeyPair {
    pub signing_id: u32,
    pub verify_id: u32,
}

pub struct AsymmetricKeyPair {
    pub public_id: u32,
    pub private_id: u32,
}

/// Generate a new random symmetric key.
pub async fn generate_symmetric_key() -> SymmetricKey {
    let key = symmetric::SymmetricKey::generate();
    SymmetricKey {
        id: binding::store_symmetric_key(key).await,
    }
}

/// Encrypt a message with a symmetric key.
pub async fn encrypt_symmetric(key: SymmetricKey, message: Vec<u8>) -> Option<Vec<u8>> {
    let mut map = binding::symmetric_key_map().await;
    let real_key = map.get_mut(&key.id)?;
    real_key.encrypt(&message)
}

/// Decrypt a message with a symmetric key.
pub async fn decrypt_symmetric(key: SymmetricKey, ciphertext: Vec<u8>) -> Option<Vec<u8>> {
    let mut map = binding::symmetric_key_map().await;
    let real_key = map.get_mut(&key.id)?;
    real_key.decrypt(&ciphertext)
}

/// Encrypt using a symmetric container
pub async fn encrypt_symmetric_container(
    key: SymmetricKey,
    signing_key: SigningKey,
    message: Vec<u8>,
    salt: Option<&Vec<u8>>,
) -> Option<Vec<u8>> {
    let mut map = binding::symmetric_key_map().await;
    let real_key = map.get_mut(&key.id)?;
    let mut map = binding::signing_keys_map().await;
    let real_sign_key = map.get_mut(&signing_key.id)?;

    return auth_symmetric::pack(real_key, real_sign_key, &message, salt);
}

/// Generate a new signature key pair.
pub async fn generate_signature_keypair() -> SignatureKeyPair {
    let keypair = signature::SignatureKeyPair::generate();
    SignatureKeyPair {
        signing_id: binding::store_signing_key(keypair.signature_key).await,
        verify_id: binding::store_verifying_key(keypair.verify_key).await,
    }
}

/// Generate a new asymmetric key pair (public/secret).
pub async fn generate_asymmetric_keypair() -> AsymmetricKeyPair {
    let keypair = asymmetric::AsymmetricKeyPair::generate();
    AsymmetricKeyPair {
        public_id: binding::store_public_key(keypair.public_key).await,
        private_id: binding::store_secret_key(keypair.secret_key).await,
    }
}
