use base64::{engine::general_purpose, Engine};

pub fn sha256_string(input: &str) -> String {
    use sha2::{Sha256, Digest};

    let mut hasher = Sha256::new();
    hasher.update(input);
    let result = hasher.finalize();

    let mut buf = String::new();
    general_purpose::STANDARD_NO_PAD.encode_string(result, &mut buf);
    
    return buf;
}

pub fn sha256(input: Vec<u8>) -> Vec<u8> {
    use sha2::{Sha256, Digest};

    let mut hasher = Sha256::new();
    hasher.update(input);
    let result = hasher.finalize();
    
    return result.to_vec();
}

pub fn sha512(input: &str) -> String {
    use sha2::{Sha512, Digest};

    let mut hasher = Sha512::new();
    hasher.update(input);
    let result = hasher.finalize();

    let mut buf = String::new();
    general_purpose::STANDARD_NO_PAD.encode_string(result, &mut buf);
    
    return buf;
}