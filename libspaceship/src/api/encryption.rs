use libcgc::{
    container::{auth_asymmetric, auth_symmetric},
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

/// Decrypt a symmetric container
pub async fn unencrypt_symmetric_container(
    key: SymmetricKey,
    verifying_key: VerifyingKey,
    ciphertext: Vec<u8>,
    salt: Option<&Vec<u8>>,
) -> Option<Vec<u8>> {
    let mut key_map = binding::symmetric_key_map().await;
    let real_key = key_map.get_mut(&key.id)?;
    let mut vk_map = binding::verifying_key_map().await;
    let real_vk = vk_map.get_mut(&verifying_key.id)?;

    auth_symmetric::unpack(real_key, real_vk, &ciphertext, salt)
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

/// Encrypt using an asymmetric container
pub async fn encrypt_asymmetric_container(
    public_key: PublicKey,
    signing_key: SigningKey,
    message: Vec<u8>,
    salt: Option<&Vec<u8>>,
) -> Option<Vec<u8>> {
    let mut public_key_map = binding::public_key_map().await;
    let real_public_key = public_key_map.get_mut(&public_key.id)?;
    let mut signing_key_map = binding::signing_keys_map().await;
    let real_signing_key = signing_key_map.get_mut(&signing_key.id)?;

    auth_asymmetric::pack(real_public_key, real_signing_key, &message, salt)
}

/// Decrypt an asymmetric container
pub async fn decrypt_asymmetric_container(
    secret_key: SecretKey,
    verifying_key: VerifyingKey,
    ciphertext: Vec<u8>,
    salt: Option<&Vec<u8>>,
) -> Option<Vec<u8>> {
    let mut secret_key_map = binding::secret_key_map().await;
    let real_secret_key = secret_key_map.get_mut(&secret_key.id)?;
    let mut verifying_key_map = binding::verifying_key_map().await;
    let real_verifying_key = verifying_key_map.get_mut(&verifying_key.id)?;

    auth_asymmetric::unpack(real_secret_key, real_verifying_key, &ciphertext, salt)
}

/// Encode a symmetric key.
pub async fn encode_symmetric_key(key: SymmetricKey) -> Option<Vec<u8>> {
    let mut map = binding::symmetric_key_map().await;
    let key = map.get_mut(&key.id)?;
    Some(key.encode())
}

/// Encode and drop a symmetric key from the underlying hash map.
pub async fn encode_and_drop_symmetric_key(key: SymmetricKey) -> Option<Vec<u8>> {
    let mut map = binding::symmetric_key_map().await;
    let mut key = map.remove(&key.id)?;
    Some(key.encode())
}

/// Decode a symmetric key from bytes.
pub async fn decode_symmetric_key(data: Vec<u8>) -> Option<SymmetricKey> {
    if let Some(real_key) = symmetric::SymmetricKey::decode(data) {
        Some(SymmetricKey {
            id: binding::store_symmetric_key(real_key).await,
        })
    } else {
        None
    }
}

/// Encode a signing key.
pub async fn encode_signing_key(key: SigningKey) -> Option<Vec<u8>> {
    let mut map = binding::signing_keys_map().await;
    let key = map.get_mut(&key.id)?;
    Some(key.encode())
}

/// Encode and drop a signing key from the underlying hash map.
pub async fn encode_and_drop_signing_key(key: SigningKey) -> Option<Vec<u8>> {
    let mut map = binding::signing_keys_map().await;
    let mut key = map.remove(&key.id)?;
    Some(key.encode())
}

/// Decode a signing key from bytes.
pub async fn decode_signing_key(data: Vec<u8>) -> Option<SigningKey> {
    if let Some(real_key) = signature::SigningKey::decode(data) {
        Some(SigningKey {
            id: binding::store_signing_key(real_key).await,
        })
    } else {
        None
    }
}

/// Encode a verifying key.
pub async fn encode_verifying_key(key: VerifyingKey) -> Option<Vec<u8>> {
    let mut map = binding::verifying_key_map().await;
    let key = map.get_mut(&key.id)?;
    Some(key.encode())
}

/// Encode and drop a verifying key from the underlying hash map.
pub async fn encode_and_drop_verifying_key(key: VerifyingKey) -> Option<Vec<u8>> {
    let mut map = binding::verifying_key_map().await;
    let key = map.remove(&key.id)?;
    Some(key.encode())
}

/// Decode a verifying key from bytes.
pub async fn decode_verifying_key(data: Vec<u8>) -> Option<VerifyingKey> {
    if let Some(real_key) = signature::VerifyingKey::decode(data) {
        Some(VerifyingKey {
            id: binding::store_verifying_key(real_key).await,
        })
    } else {
        None
    }
}

/// Encode a public key.
pub async fn encode_public_key(key: PublicKey) -> Option<Vec<u8>> {
    let mut map = binding::public_key_map().await;
    let key = map.get_mut(&key.id)?;
    Some(key.encode())
}

/// Encode and drop a public key from the underlying hash map.
pub async fn encode_and_drop_public_key(key: PublicKey) -> Option<Vec<u8>> {
    let mut map = binding::public_key_map().await;
    let key = map.remove(&key.id)?;
    Some(key.encode())
}

/// Decode a public key from bytes.
pub async fn decode_public_key(data: Vec<u8>) -> Option<PublicKey> {
    if let Some(real_key) = asymmetric::PublicKey::decode(data) {
        Some(PublicKey {
            id: binding::store_public_key(real_key).await,
        })
    } else {
        None
    }
}

/// Encode a secret key.
pub async fn encode_secret_key(key: SecretKey) -> Option<Vec<u8>> {
    let mut map = binding::secret_key_map().await;
    let key = map.get_mut(&key.id)?;
    Some(key.encode())
}

/// Encode and drop a secret key from the underlying hash map.
pub async fn encode_and_drop_secret_key(key: SecretKey) -> Option<Vec<u8>> {
    let mut map = binding::secret_key_map().await;
    let key = map.remove(&key.id)?;
    Some(key.encode())
}

/// Decode a secret key from bytes.
pub async fn decode_secret_key(data: Vec<u8>) -> Option<SecretKey> {
    if let Some(real_key) = asymmetric::SecretKey::decode(data) {
        Some(SecretKey {
            id: binding::store_secret_key(real_key).await,
        })
    } else {
        None
    }
}
